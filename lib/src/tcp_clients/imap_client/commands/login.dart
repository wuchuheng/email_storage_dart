import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/request/request.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/validator/common_validator.dart';

import '../../../exceptions/imap_response_exception.dart';
import '../dto/command.dart';
import 'command_abstract.dart';

class Login implements CommandAbstract {
  final String username;
  final String password;
  final Future<List<String>> Function({required Request request}) writeCommand;

  Login({
    required this.username,
    required this.password,
    required this.writeCommand,
  });

  late List<String> _response;
  late Request _request;

  @override
  Future<CommandAbstract> fetch() async {
    // 1. Create the request for the login command.
    _request = Request(
      command: Command.LOGIN,
      arguments: [username, password],
    );

    // 2. Write the request to the server.
    _response = await writeCommand(request: _request);

    return this;
  }

  @override
  Response parse() {
    // 1. Check the format is correct.
    // 1.1 Check the response must be one line.
    if (_response.length != 1) {
      throw ResponseException('The response is not in the correct format.');
    }

    // 1.2 Check the tag of the response.
    final tag = _request.tag;
    if (!_response.first.startsWith(tag)) {
      throw ResponseException('The tag: $tag of the response is not correct.');
    }

    // 2. Get the status of the response.
    String line = _response.first.substring(tag.length + 1);
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

  @override
  CommandAbstract validate() {
    checkResponseFormat(_response, _request.tag);

    return this;
  }
}
