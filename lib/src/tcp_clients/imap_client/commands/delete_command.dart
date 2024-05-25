import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/commands/command_abstract.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/command.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/request/request.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/imap_client.dart';

class DeleteCommand implements CommandAbstract<void> {
  final String mailbox;
  final OnImapWriteType onImapWrite;

  DeleteCommand({required this.mailbox, required this.onImapWrite});

  @override
  Future<Response<void>> execute() async {
    // 1. Create the request.
    final Request request = Request(
      command: Command.DELETE,
      arguments: ['"$mailbox"'],
    );

    // 2. Send the request to the server.
    final result = await onImapWrite(request: request);

    // 3. return result.
    return result;
  }
}
