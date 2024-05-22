import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/commands/command_abstract.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/command.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/mailbox.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/request/request.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/validator/common_validator.dart';
import 'package:wuchuheng_email_storage/src/utilities/response.dart';

import '../../../utilities/mailbox_util.dart';

class Select<T> implements CommandAbstract {
  final String mailbox;
  late List<String> _response;

  late Request _request;

  Future<List<String>> Function({required Request request}) socketWrite;

  Select({required this.mailbox, required this.socketWrite});

  @override
  Future<CommandAbstract> fetch() async {
    // 1. Create a request message to select the mailbox with the given name.
    _request = Request(command: Command.SELECT, arguments: [mailbox]);

    // 2. Write the request message to the server with the socket write function.
    _response = await socketWrite(request: _request);

    return this;
  }

  @override
  Response<Mailbox> parse() {
    Response<List<String>> response = ResponseUtile.parseResponse(
      response: _response,
      tag: _request.tag,
    );

    final Mailbox mailbox = MailboxUtil.parseResponseToMailbox(_response);
    final Response<Mailbox> result = Response(
      data: mailbox,
      tag: response.tag,
      status: response.status,
      message: response.message,
      code: response.code,
    );

    return result;
  }

  @override
  CommandAbstract validate() {
    checkResponseFormat(_response, _request.tag);

    return this;
  }
}
