import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';

import '../../../exceptions/imap_response_exception.dart';
import 'response_parser_abstract.dart';

class LoginParser implements ResponseParserAbstract {
  final String tag;
  final List<String> response;

  LoginParser({required this.tag, required this.response});

  @override
  Response parse() {
    // 1. Check the format is correct.
    // 1.1 Check the response must be one line.
    if (response.length != 1) {
      throw ResponseException('The response is not in the correct format.');
    }

    // 1.2 Check the tag of the response.
    if (!response.first.startsWith(tag)) {
      throw ResponseException('The tag: $tag of the response is not correct.');
    }

    // 2. Get the status of the response.
    String line = response.first.substring(tag.length + 1);
    final statusStr = line.split(' ').first;
    ResponseStatus status;
    switch (statusStr) {
      case 'OK':
        status = ResponseStatus.OK;
        break;
      case 'NO':
        status = ResponseStatus.NO;
        break;
      case 'BAD':
        status = ResponseStatus.BAD;
        break;
      // Throw an exception for the other status.
      default:
        throw ResponseException(
            'The status: $statusStr of the response is not correct.');
    }

    // 3. Get the message of the response.
    final String message = line.split(' ').sublist(1).join(' ');

    final result = Response<List<String>>(
      data: [],
      status: status,
      message: message,
      tag: tag,
    );

    return result;
  }
}
