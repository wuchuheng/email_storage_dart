import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/request/request.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/imap_client.dart';

import '../dto/command.dart';
import 'command_abstract.dart';

class Login implements CommandAbstract<void> {
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
  Future<Response<void>> execute() async {
    // 1. Create the request for the login command.
    _request = Request(
      command: Command.LOGIN,
      arguments: [username, password],
    );

    // 2. Write the request to the server.
    _response = await writeCommand(request: _request);

    return _response;
  }
}
