import '../config/config.dart';
import '../tcp_clients/imap_client/dto/response/message.dart';

/// Utility class for parsing data items in IMAP protocol responses.
///
/// This class provides methods for extracting specific pieces of information from server responses, such as sequence numbers, UIDs, and flags.
/// It is used in the context of the `UID FETCH` or `FETCh` command to parse the server response and construct [Message] objects.
///
/// Methods:
/// - `_extractSequenceNumber`: Extracts the sequence number from a server response line.
/// - `_tryExtractUid`: Tries to extract the UID from a server response line. If a UID is found, it is passed to the `onExtractUid` callback. The rest of the line, with the UID removed, is passed to the `onReturnRestOfLine` callback.
/// - `_tryExtractFlags`: Tries to extract the flags from a server response line. If flags are found, they are passed to the `onExtractFlags` callback. The rest of the line, with the flags removed, is passed to the `onReturnRestOfLine` callback.
class DataItemParserUtil {
  final List<String> dataItems;

  DataItemParserUtil({required this.dataItems});

  /// Parses the response data from the IMAP server after executing the `UID fetch command or `FETCH` command.
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
  /// This method parses this data and returns a list of [Message] objects.
  ///
  /// Parameters:
  /// - `data`: The response data from the server, as a list of strings.
  ///
  /// Returns a list of [Message] objects parsed from the response data.
  ///
  List<Message> parse(List<String> data) {
    // 1. Split the response data into separate messages.
    final sequenceNumberMapMessages = _splitMessages(data);

    final List<Message> result = [];
    // 2. Parse each message.
    for (final sequenceNumber in sequenceNumberMapMessages.keys) {
      final messages = sequenceNumberMapMessages[sequenceNumber]!;
      final message = _parseMessage(
        sequenceNumber,
        messages,
      );

      // 2.2 Add the message to the result list.
      result.add(message);
    }

    return result;
  }

  /// Splits the response data into separate messages.
  ///
  /// This method is used in the context of the `UID FETCH` command to split the server response into separate messages.
  /// Each message in the server response is represented as a list of strings, where each string is a line of the message.
  ///
  /// Parameters:
  /// - `data`: The response data from the server, as a list of strings.
  ///
  /// Returns a map where the keys are the sequence numbers of the messages and the values are the messages themselves, represented as lists of strings.
  /// @Stack:  parseResponse
  Map<int, List<List<String>>> _splitMessages(List<String> data) {
    // 1. Split the message from the response data.
    final result = <int, List<List<String>>>{};

    int i = 0;
    int? currentSequenceNumber;
    final flush = <String>[];
    // 1.1 A method to push the message to the result map.
    void pushMessageToResult(int sequenceNumber, List<String> messages) {
      if (!result.containsKey(sequenceNumber)) {
        result[sequenceNumber] = [];
      }

      // 1.1.1 Add the message to the result map.
      result[sequenceNumber]!.add(List<String>.from(flush));

      // 1.1.2 Clear the flush buffer.
      currentSequenceNumber = null;
      flush.clear();
    }

    // 2. Extract the messages from the response data.
    while (i < data.length) {
      final line = data[i];
      // 2.1 If the line starts with the sequence number, and then extract the sequence number.
      // And then collect the previous message into the map.
      if (fetchRegex.hasMatch(data[i])) {
        // 2.1.1  If the previous message is not empty, and then collect it into the map.
        if (currentSequenceNumber != null) {
          pushMessageToResult(currentSequenceNumber!, flush);
        }

        // 2.1.2 Extract the sequence number from the line.
        currentSequenceNumber = _extractSequenceNumber(data[i]);
      }
      // 2.2 Add the line to the flush buffer.
      flush.add(line);
      i++;

      // 1.3 If the line is the last line, and then collect the message into the map.
      if (i == data.length) {
        pushMessageToResult(currentSequenceNumber!, flush);
      }
    }

    return result;
  }

  Message _parseMessage(int sequenceNumber, List<List<String>> messages) {
    final message = Message(
      sequenceNumber: sequenceNumber,
      dataItemMapResult: {},
    );
    // 1. Extract the information from the message. the messageData like:
    // ```plaintext
    // * 8 FETCH (UID 152 FLAGS (\Seen))
    // * 8 FETCH (UID 152 BODY[TEXT] {11}
    // New email
    //  BODY[HEADER.FIELDS (SUBJECT DATE)] {63}
    // SUBJECT: hello
    // DATE: Wed, 5 Jun 2024 17:30:42.385757 +0800

    // )
    // U2 OK FETCH completed (took 26 ms)
    // ```
    for (List<String> messageData in messages) {
      String firstLine = messageData.first.replaceFirst(fetchRegex, '');
      // 1.1 Try to extract the UID from the first line.
      _tryExtractUid(
        line: firstLine,
        onExtractUid: (int uid) => message.dataItemMapResult['UID'] = '$uid',
        onReturnRestOfLine: (String newLine) => firstLine = newLine,
      );

      // 1.2 Try to extract the `FLAGS` from the first line.
      _tryExtractFlags(
        line: firstLine,
        onExtractFlags: (String flags) =>
            message.dataItemMapResult['FLAGS'] = flags,
        onReturnRestOfLine: (String newLine) => firstLine = newLine,
      );

      // 1.3 Try to extract the data items
      List<String> restOfLines = [
        firstLine,
        ...(messageData.length > 1 ? messageData.sublist(1) : [])
      ];
      for (final _ in dataItems) {
        // 1.3.1 If the data item is not included in the rest of the lines, and then break.
        if (restOfLines.first.split(' {').length == 1) {
          break;
        }
        // 1.3.2 Try to extract the data item from
        _extractDataItem(
            restOfLines: restOfLines,
            onResult: ({
              required String name,
              required String value,
              required List<String> newRestOfLines,
            }) {
              message.dataItemMapResult[name] = value;
              restOfLines = newRestOfLines;
            });
      }
    }

    return message;
  }

  // Regular expressions to match the string it must start with `* <sequence number> FETCH`
  final fetchRegex = RegExp(r'^\* \d+ FETCH \(');

  int _extractSequenceNumber(String line) {
    // 1. Extract the match from the line.
    final match = fetchRegex.firstMatch(line);

    // 2. Get the capture group. like: `* 1 FETCH (`
    final String capture = match?.group(0) as String;

    // 3. Extract the sequence number from the capture group.
    final sequenceNumber = int.parse(capture.split(' ')[1]);

    return sequenceNumber;
  }

  // @Stack:  parseResponse / _parseMessage
  void _tryExtractUid({
    required String line,
    required void Function(int uid) onExtractUid,
    required void Function(String restOfLine) onReturnRestOfLine,
  }) {
    final uidRegex = RegExp(r'UID \d+');
    if (uidRegex.hasMatch(line)) {
      final uidMatch = uidRegex.firstMatch(line);
      final uid = int.parse(uidMatch?.group(0)?.split(' ')[1] as String);
      onExtractUid(uid);
      onReturnRestOfLine(line.replaceFirst(uidMatch?.group(0) as String, ''));
    }
  }

  // @Stack:  parseResponse / _parseMessage
  void _tryExtractFlags({
    required String line,
    required String Function(String flags) onExtractFlags,
    required String Function(String newLine) onReturnRestOfLine,
  }) {
    final flagsRegex = RegExp(r'FLAGS \([^\)]+\)');
    // 1. Check if the line contains the `FLAGS` data item.
    // Extract the flags from the line.
    if (flagsRegex.hasMatch(line)) {
      // 1.1 Extract the flags from the line.
      final flagsMatch = flagsRegex.firstMatch(line);
      final flags = flagsMatch?.group(0) as String;
      final captureRegex = RegExp(r'\(([^\)]+)\)');
      final match = captureRegex.firstMatch(flags);
      final flagValue = match?.group(1) ?? '';

      // 1.1 Return the flags and the rest of the line by callback.
      onExtractFlags(flagValue);
      onReturnRestOfLine(line.replaceFirst(flagsRegex, ''));
    }
  }

// @Stack:  parseResponse / _parseMessage
  void _extractDataItem({
    required List<String> restOfLines,
    required void Function({
      required String name,
      required List<String> newRestOfLines,
      required String value,
    }) onResult,
  }) {
    int readLineIndex = 0;
    // 1. Extract the name and length of the data item.
    final dataItemInfo = restOfLines.first.split(' {');
    final String name = dataItemInfo.first.trim();
    final int length = int.parse(dataItemInfo.last.split('}').first);
    readLineIndex++;

    // 2 Extract the value of the data item.
    String value = '';
    while (value.length < length) {
      // 2.1 Add the line to the value.
      value += restOfLines[readLineIndex] + EOF;
      readLineIndex++;

      if (value.length > length) {
        // 2.2 Remove the last EOF character from the value.
        value = value.substring(0, value.length - 1);
      }
    }

    // 3. Return the name, value, and the rest of the lines by callback.
    onResult(
      name: name,
      value: value,
      newRestOfLines: restOfLines.sublist(readLineIndex),
    );
  }
}
