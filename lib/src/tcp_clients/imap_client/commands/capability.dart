import 'package:wuchuheng_email_storage/src/exceptions/imap_response_exception.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/command.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/request/request.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/capability_response.dart';

Future<CapabilityResponse> capability({
  required Future<List<String>> Function({
    required Request request,
  }) writeCommand,
}) async {
  // 1. create the request for the capability command
  final Request request = Request(command: Command.CAPABILITY);

  // 2. write the request to the server
  final response = await writeCommand(request: request);
  // 2.1 Check if the response is not a format, like:
  // ```
  // *  IMAP4rev1 STARTTLS AUTH GSSAPI
  // A1 OK capability completed
  // ```
  if (response.isEmpty) {
    throw ResponseException('The response is empty.');
  }
  if (response.length != 2) {
    throw ResponseException('The response is not in the correct format.');
  }

  // 3. handle the response from the server
  final result = response.first.split(' ').sublist(1);
  // 3.1 Check the `IMAP4rev1` capability is supported
  final mustBeSupportedCapabilitie = 'IMAP4rev1';
  if (!result.contains(mustBeSupportedCapabilitie)) {
    throw ResponseException(
      'The server does not support the $mustBeSupportedCapabilitie capability.',
    );
  }

  // 4. return the capability response
  return result;
}
