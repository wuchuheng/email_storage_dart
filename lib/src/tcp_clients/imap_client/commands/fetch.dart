import 'dart:async';
import 'dart:convert';

import 'package:wuchuheng_email_storage/src/exceptions/imap_response_exception.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/command.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/request/request.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/message.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';
import 'package:wuchuheng_email_storage/src/utilities/response.dart';
import 'package:wuchuheng_hooks/wuchuheng_hooks.dart';

import '../../../config/config.dart';
import '../dto/mail.dart';
import 'command_abstract.dart';

/// A class that implements the IMAP FETCH command.
///
/// The FETCH command retrieves data associated with a message in the mailbox.
/// The data items to be fetched can be specified by the client.
///
/// For more information, see the IMAP protocol specification:
/// [RFC 3501 - INTERNET MESSAGE ACCESS PROTOCOL - VERSION 4rev1](https://datatracker.ietf.org/doc/html/rfc3501#section-6.4.5)
class Fetch implements CommandAbstract<List<Message>> {
  /// The start sequence number of the messages to fetch.
  final int startSequenceNumber;

  /// The end sequence number of the messages to fetch.
  final String endSequenceNumber;

  /// The data items to fetch.
  final List<String> dataItems;

  final Hook<String> tcpDataSubscription;
  final void Function(String message) tcpWrite;
  late Unsubscribe _cancelRecieveData;
  late Request _request;

  // Regular expressions to match the string it must be start with `* <sequence number> FETCH`
  final fetchRegex = RegExp(r'^\* \d+ FETCH \(');

  /// Creates a new instance of the Fetch command.
  ///
  /// The [startSequenceNumber] argument is the start sequence number of the messages to fetch.
  /// The [endSequenceNumber] argument is the end sequence number of the messages to fetch.
  /// The [dataItems] argument is the list of data items to fetch.
  Fetch({
    required this.startSequenceNumber,
    this.endSequenceNumber = "",
    required this.dataItems,
    required this.tcpDataSubscription,
    required this.tcpWrite,
  }) {
    // 1. Check the data items list.
    if (dataItems.isEmpty) {
      throw ResponseException('The data items list cannot be empty.');
    }
    // 1.1 Check if the end sequence number is a wildcard.
    if (endSequenceNumber != "*") {
      // Check the end sequence number must be a number.
      if (int.tryParse(endSequenceNumber) == null) {
        throw ResponseException('The end sequence number must be a number.');
      }
      // Check if the end sequence number is greater than the start sequence number.
      if (int.parse(endSequenceNumber) < startSequenceNumber) {
        throw ResponseException(
          'The end sequence number must be greater than or equal to the start sequence number.',
        );
      }
    }

    // 2. Bind the ReceiveData hook to the method to receive data from the server over the socket.
    _cancelRecieveData = tcpDataSubscription.subscribe((
      String data,
      Function() cancel,
    ) {
      try {
        _onData(data, cancel);
      } catch (e) {
        cancel();
        _responseCompleter.completeError(e);
      }
    });
  }

  /// A completer to wait for the response from the server.
  final Completer<Response<List<Message>>> _responseCompleter = Completer();

  /// Executes the FETCH command.
  ///
  /// Returns a [Response] indicating the success or failure of the operation.
  @override
  Future<Response<List<Message>>> execute() async {
    // 1. Create a request object for the FETCH command.
    final partNumber = endSequenceNumber.isNotEmpty
        ? '$startSequenceNumber:$endSequenceNumber'
        : startSequenceNumber.toString();
    _request = Request(
      command: Command.FETCH,
      arguments: [
        partNumber,
        '(${dataItems.join(' ')})',
      ],
    );

    // 2. Write the FETCH command to the tcp socket.
    tcpWrite(_request.toString());

    // 3. Wait for the response from the server.
    final result = await _responseCompleter.future;

    // 4. Unsubscribe from the ReceiveData hook.
    _cancelRecieveData.unsubscribe();

    // 5. return the response.
    return result;
  }

  /// A buffer to store the data received from the server.
  final List<String> _flush = [];

  /// Handles the data received from the server.
  ///
  /// This method is called whenever data is received from the server. It processes
  /// the data line by line and writes it to the `_flushBuffer`.
  ///
  /// [data] is the raw data received from the server.
  /// [_] is a placeholder for a callback function that is not used in this method.
  ///
  /// The method checks if each line starts with the tag of the current command.
  /// If it does, it indicates that the server
  /// @Stack: constructor / _onData
  void _onData(String data, Function() cancel) {
    for (final line in LineSplitter().convert(data)) {
      // 1. Write the line to the buffer.
      _flush.add(line);

      // 2. If the line starts with the tag of the current command, and then complete the current command. with the response.
      if (line.startsWith(_request.tag)) {
        // 2.1 Parse the response data to a list of mails.
        final response = ResponseUtile.parseResponse(
          response: [_flush.last],
          tag: _request.tag,
        );

        _flush.removeLast();
        final List<Message> messages = _parseResponse(_flush);

        // 2.2 Complete the response completer with the response.
        _responseCompleter.complete(
          Response(
            data: messages,
            tag: response.tag,
            status: response.status,
            message: response.message,
          ),
        );

        // 2.3 Cancel the subscription to the ReceiveData hook.
        cancel();
      }
    }
  }

  /// Parses the response data from the IMAP server after executing the FETCH command.
  ///
  /// This method takes a list of strings, where each string represents a line of the response data from the server.
  /// The response data is expected to be in the following format:
  ///
  /// ```
  /// * 1 FETCH (BODY[TEXT] {19}
  /// line1
  /// line2
  /// line3
  /// BODY[HEADER.FIELDS (SUBJECT DATE)] {64}
  /// SUBJECT: hello
  /// DATE: Wed, 29 May 2024 22:44:12.229361 +0800
  /// )
  /// ```
  ///
  /// Each FETCH response contains the body text and header fields (subject and date) of a message.
  /// This method parses this data and returns a list of [Mail] objects.
  ///
  /// Parameters:
  /// - `data`: The response data from the server, as a list of strings.
  ///
  /// Returns a list of [Mail] objects parsed from the response data.
  ///
  /// @Stack: construct / _onData
  List<Message> _parseResponse(List<String> data) {
    final List<Message> result = [];
    int i = 0;
    while (i < data.length) {
      String line = data[i];
      // 1. If the message is matched, and then extract the message from the response data.
      if (fetchRegex.hasMatch(line)) {
        // 1.2.1 Remove the `* <sequence number> FETCH (` from the line.
        line = line.replaceFirst(fetchRegex, '');
        final Message message = _parseMessage(
          data.sublist(i),
          onReadNextLine: () {
            i++;
          },
        );
        result.add(message);
      }

      i++;
    }

    return result;
  }

  /// Parses a message from a sublist of the server response data.
  ///
  /// This method takes a sublist of the server response data and a callback function `onReadNextLine`.
  /// The sublist should contain the lines of the response data that represent a single message.
  /// The `onReadNextLine` function is called when the next line of the response data is read.
  /// It takes the index of the line that was read and returns the index of the next line to read.
  ///
  /// The method extracts the data items and the UID from the response data and returns a `Message` object that holds this data.
  ///
  /// Parameters:
  /// - `sublist`: A sublist of the server response data that represents a single message.
  /// - `onReadNextLine`: A callback function that is called when the next line of the response data is read.
  ///
  /// Returns a `Message` object that holds the data items and the UID extracted from the response data.
  ///
  /// @Stack: constructor / _onData
  Message _parseMessage(
    List<String> data, {
    required void Function() onReadNextLine,
  }) {
    // 1. Extract the UID of the message.
    final int sequenceNumber = _extractSequenceNumber(data.first);

    // 2. Remove the matched string in the first line.
    data[0] = data.first.replaceFirst(fetchRegex, '');

    // The count of rest of the data items.
    int dataItemsLength = dataItems.length;

    final Message message = Message(
      sequenceNumber: sequenceNumber,
      dataItemMapResult: {},
    );

    // 3. If the UID was exisited in the query, and then extract the UID from the message.
    final uidRegex = RegExp(r'UID \d+');
    if (data.first.contains(uidRegex)) {
      // 3.1 Extract the UID from the first line, and push it to the data items.
      final match = uidRegex.firstMatch(data.first);
      final matchStr = match?.group(0) as String;
      final uid = int.parse(matchStr.split(' ')[1]);
      message.dataItemMapResult['UID'] = uid.toString();

      // 3.2 Remove the matched string from the first line.
      data[0] = data.first.replaceFirst(uidRegex, '');

      // 3.3 decrement the data items length.
      dataItemsLength--;
    }

    // 3. Extract the data items of the message.
    int nextLineIndex = 0;
    for (int i = 0; i < dataItemsLength; i++) {
      // 3.1 Extract the data items from the list of string, like:
      // ```BODY[TEXT] {19}
      // line1
      // line2
      // line3```
      // 3.1.1 Extract the length and the name of the data item.
      final dataItemInfo = data[nextLineIndex].split(' {');
      final name = dataItemInfo[0].trim();
      final length = int.parse(dataItemInfo[1].split('}')[0]);

      // 3.1.2 Extract the data item content by looping over the lines with the length.
      String value = '';
      int readedLength = 0;
      while (readedLength < length) {
        // 4.  Read the next line and call the `onReadNextLine` callback to get the index of the next line to read.
        nextLineIndex++;
        onReadNextLine();

        // 3.1.2.1  Add the next line to the value.
        final line = data[nextLineIndex] + EOF;
        value += line;
        readedLength += line.length;
      }

      // 3.1.3 Add the data item to the message.
      message.dataItemMapResult[name] = value;

      // 3.2 Check if the next data item is available and then increment the index.
      if (i + 1 < dataItems.length) {
        nextLineIndex++;
        onReadNextLine();
      }
    }

    return message;
  }

  int _extractSequenceNumber(String line) {
    // 1. Extract the match from the line.
    final match = fetchRegex.firstMatch(line);

    // 2. Get the capture group. like: `* 1 FETCH (`
    final String capture = match?.group(0) as String;

    // 3. Extract the UID from the capture group.
    final uid = int.parse(capture.split(' ')[1]);

    return uid;
  }
}
