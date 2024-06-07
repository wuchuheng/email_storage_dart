import 'dart:async';
import 'dart:convert';

import 'package:wuchuheng_email_storage/src/config/config.dart';
import 'package:wuchuheng_email_storage/src/exceptions/imap_response_exception.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/commands/command_abstract.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/command.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/request/request.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';
import 'package:wuchuheng_email_storage/src/utilities/response.dart';
import 'package:wuchuheng_hooks/wuchuheng_hooks.dart';

import '../dto/mail.dart';

class Append implements CommandAbstract<void> {
  final Hook<String> onServerDataSubscription;
  final String mailbox;
  final Mail mail;
  final void Function(String message) onTcpWrite;
  late Request _request;

  Append({
    required this.onServerDataSubscription,
    required this.mailbox,
    required this.mail,
    required this.onTcpWrite,
  });

  /// helloc
  /// Declare a response object to store the response from the server.
  final Completer<Response<List<String>>> _completerResponse = Completer();

  @override
  Future<Response<void>> execute() async {
    // 1. Subscribe to the data event from the IMAP Server.
    // 1.1 Bind the _onData method to ServerDataSubscription.
    final dataSubscription = onServerDataSubscription.subscribe(_onData);

    // 2. Create the request of the APPEND command.
    _request = Request(
      command: Command.APPEND,
      arguments: [mailbox, '()', '{${mail.size()}}'],
      continueInput: mail.toString(),
    );

    // 3. Send the request to the server.
    onTcpWrite(_request.toString());

    // 4. Wait for the response from the server.
    final Response<List<String>> result = await _completerResponse.future;

    // 5. Restore the state of the IMAP client.
    // 5.1　Unsubscribe from the data event from the IMAP Server.
    dataSubscription.unsubscribe();

    // 6. Return the response from the server.
    return result;
  }

  bool _isSendingMail = false;

  final List<String> _flush = [];

  /// Handles the data event from the IMAP Server.
  ///
  /// This method is called when the IMAP Server sends a response to the client.
  /// The response is a string and is parsed within this method.
  ///
  /// Parameters:
  /// - `value`: The response string from the IMAP Server.
  /// - `_`: An unused parameter, typically a callback or event that is not used in this method.
  void _onData(String value, Function() _) {
    // 1. Split the response string by the delimiter `\r\n`.
    final List<String> response = LineSplitter().convert(value);

    for (final line in response) {
      // 2. Store the response in the _flush list.
      _flush.add(line);

      // 3. Check if the response is a continuation response. and then send the mail to the server.
      // 3.1 If the response is a continuation response.
      if (line.startsWith('+')) {
        // 3.1.1 Check if the response is a continuation response for the APPEND command.
        if (_isSendingMail) {
          _completerResponse.completeError(
            ResponseException(
              "The response is not a continuation response for the APPEND command.",
            ),
          );
        }

        // 3.1.2 Send the mail to the server.
        onTcpWrite(_request.continueInput + EOF);
        _isSendingMail = true;
        continue;
      }

      // 4. Check if the response is a tagged response. and then complete the command.
      // 4.1 If the response is a tagged response.
      if (line.startsWith(_request.tag)) {
        try {
          final response = ResponseUtile.parseResponse(
            response: _flush,
            tag: _request.tag,
          );
          _completerResponse.complete(response);
        } catch (e) {
          _completerResponse.completeError(e);
        }
      }
    }
  }
}
