import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/commands/command_abstract.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/command.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/imap_client.dart';

import '../dto/request/request.dart';

class Create implements CommandAbstract<void> {
  final String mailbox;
  final OnImapWriteType _write;

  Create({required this.mailbox, required OnImapWriteType write})
      : _write = write;

  @override
  Future<Response<void>> execute() async {
    final request = Request(command: Command.CREATE, arguments: [mailbox]);
    final response = await _write(request: request);

    return response;
  }
}
