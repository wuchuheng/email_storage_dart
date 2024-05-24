import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/request/request.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/imap_client.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/validator/common_validator.dart';

import '../dto/command.dart';
import 'command_abstract.dart';

class Login implements CommandAbstract {
  final String username;
  final String password;
  final OnImapWriteType writeCommand;

  Login({
    required this.username,
    required this.password,
    required this.writeCommand,
  });

  late Response<List<String>> _response;
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
    return _response;
  }

  CommandAbstract validate() {
    checkResponseFormat(_response.data, _request.tag);

    return this;
  }
}
