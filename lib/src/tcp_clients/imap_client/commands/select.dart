import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/commands/command_abstract.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/command.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/mailbox.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/request/request.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/imap_client.dart';

import '../../../utilities/mailbox_util.dart';

class Select<T> implements CommandAbstract {
  final String mailbox;
  late Response<List<String>> _response;

  late Request _request;

  OnImapWriteType socketWrite;

  Select({required this.mailbox, required this.socketWrite});

  @override
  Future<CommandAbstract> execute() async {
    // 1. Create a request message to select the mailbox with the given name.
    _request = Request(command: Command.SELECT, arguments: [mailbox]);

    // 2. Write the request message to the server with the socket write function.
    _response = await socketWrite(request: _request);

    return this;
  }

  @override
  Response<Mailbox> parse() {
    final Mailbox mailbox = MailboxUtil.parseResponseToMailbox(_response.data);
    final Response<Mailbox> result = Response(
      data: mailbox,
      tag: _response.tag,
      status: _response.status,
      message: _response.message,
      code: _response.code,
    );

    return result;
  }
}
