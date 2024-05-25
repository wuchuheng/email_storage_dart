import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/commands/command_abstract.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/command.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/imap_client.dart';

import '../dto/request/request.dart';

class Create implements CommandAbstract<void> {
  final String mailbox;
  final OnImapWriteType _write;
  late Response<List<String>> _response;

  Create({required this.mailbox, required OnImapWriteType write})
      : _write = write;

  @override
  Future<CommandAbstract> execute() async {
    final request = Request(command: Command.CREATE, arguments: [mailbox]);
    _response = await _write(request: request);

    return this;
  }

  @override
  Response<void> parse() {
    final Response<void> result = Response(
      tag: _response.tag,
      status: _response.status,
      message: _response.message,
      data: null,
    );

    return result;
  }
}
