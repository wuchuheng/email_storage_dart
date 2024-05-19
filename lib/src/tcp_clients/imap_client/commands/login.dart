import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/request/request.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/validator/command_validator_abstract.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/validator/login_response_validator.dart';

import '../dto/command.dart';
import 'command_abstract.dart';

Future<Response<void>> login({
  required username,
  required password,
  required Future<List<String>> Function({required Request request})
      writeCommand,
}) async {
  // 3. Parse the response from the server.
  // final result = loginParser(response: response, tag: request.tag);

  // return result;
  throw UnimplementedError("");
}

class LoginCommand implements CommandAbstract {
  final String username;
  final String password;
  final Future<List<String>> Function({required Request request}) writeCommand;

  LoginCommand({
    required this.username,
    required this.password,
    required this.writeCommand,
  });

  @override
  Future<CommandValidatorAbstract> fetch() async {
    // 1. Create the request for the login command.
    final Request request = Request(
      command: Command.LOGIN,
      arguments: [username, password],
    );

    // 2. Write the request to the server.
    final response = await writeCommand(request: request);

    // 3. Return a validator to validate the response from the server.
    final result = LoginResponseValidator(response: response, tag: request.tag);

    return result;
  }
}
