import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/commands/command_abstract.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/command.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/request/request.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/imap_client.dart';

class DeleteCommand implements CommandAbstract<void> {
  final String mailbox;
  final OnImapWriteType onImapWrite;
  late final Response<List<String>> _response;

  DeleteCommand({required this.mailbox, required this.onImapWrite});

  @override
  Future<CommandAbstract> execute() async {
    // 1. Create the request.
    final Request request = Request(
      command: Command.DELETE,
      arguments: ['"$mailbox"'],
    );

    // 2. Send the request to the server.
    _response = await onImapWrite(request: request);

    // 3. return this.
    return this;
  }

  @override
  Response<void> parse() {
    return _response;
  }
}
