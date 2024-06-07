import 'dart:async';
import 'dart:convert';

import 'package:wuchuheng_email_storage/src/exceptions/imap_response_exception.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/command.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/request/request.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/message.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';
import 'package:wuchuheng_email_storage/src/utilities/data_item_parser_util.dart';
import 'package:wuchuheng_email_storage/src/utilities/response.dart';
import 'package:wuchuheng_hooks/wuchuheng_hooks.dart';

import 'command_abstract.dart';

/// A class that implements the IMAP UID FETCH command.
///
/// The UID FETCH command retrieves data associated with a message in the mailbox using UIDs.
/// The data items to be fetched can be specified by the client.
///
/// For more information, see the IMAP protocol specification:
/// [RFC 3501 - INTERNET MESSAGE ACCESS PROTOCOL - VERSION 4rev1](https://datatracker.ietf.org/doc/html/rfc3501#section-6.4.8)
class UidFetch implements CommandAbstract<List<Message>> {
  /// The start UID of the messages to fetch.
  final int startUid;

  /// The end UID of the messages to fetch.
  final String endUid;

  /// The data items to fetch.
  final List<String> dataItems;

  final Hook<String> tcpDataSubscription;
  final void Function(String message) tcpWrite;
  late Unsubscribe _cancelRecieveData;
  late Request _request;

  /// Creates a new instance of the UidFetch command.
  ///
  /// The [startUid] argument is the start UID of the messages to fetch.
  /// The [endUid] argument is the end UID of the messages to fetch.
  /// The [dataItems] argument is the list of data items to fetch.
  UidFetch({
    required this.startUid,
    this.endUid = "",
    required this.dataItems,
    required this.tcpDataSubscription,
    required this.tcpWrite,
  }) {
    // 1. Check the data items list.
    if (dataItems.isEmpty) {
      throw ResponseException('The data items list cannot be empty.');
    }
    // 1.1 Check if the end sequence number is a wildcard.
    if (endUid.isNotEmpty && endUid != "*") {
      // Check the end sequence number must be a number.
      if (int.tryParse(endUid) == null) {
        throw ResponseException('The end sequence number must be a number.');
      }
      // Check if the end sequence number is greater than the start sequence number.
      if (int.parse(endUid) < startUid) {
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

  /// Executes the UID FETCH command.
  ///
  /// Returns a [Response] indicating the success or failure of the operation.
  @override
  Future<Response<List<Message>>> execute() async {
    // 1. Create a request object for the UID FETCH command.
    final partNumber =
        endUid.isNotEmpty ? '$startUid:$endUid' : startUid.toString();
    _request = Request(
      command: Command.UID,
      arguments: [
        'FETCH',
        partNumber,
        '(${dataItems.join(' ')})',
      ],
    );

    // 2. Write the UID FETCH command to the tcp socket.
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

      // 2. If the line starts with the tag of the current command, and then complete the current command with the response.
      if (line.startsWith(_request.tag)) {
        // 2.1 Parse the response data to a list of messages.
        final response = ResponseUtile.parseResponse(
          response: [_flush.last],
          tag: _request.tag,
        );

        _flush.removeLast();
        final List<Message> messages =
            DataItemParserUtil(dataItems: dataItems).parse(_flush);

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
}
