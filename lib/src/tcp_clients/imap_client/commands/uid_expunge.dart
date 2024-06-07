import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/commands/command_abstract.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';

import '../dto/command.dart';
import '../dto/request/request.dart';
import '../imap_client.dart';

class UidExpunge implements CommandAbstract<void> {
  final OnImapWriteType onWrite;
  final int startUid;
  final String endUid;

  UidExpunge({
    required this.onWrite,
    required this.startUid,
    required this.endUid,
  });

  @override
  Future<Response<void>> execute() async {
    // 1. Create a request for the `UID EXPUNGE` command.
    // 1.1 Define the sequence set of the UIDs.
    final uids = endUid.isEmpty ? startUid.toString() : '$startUid:$endUid';

    // 1.2 Create rquest.
    final request = Request(command: Command.UID, arguments: ['expunge', uids]);

    // 2. Write the request to the IMAP server.
    final Response res = await onWrite(request: request);

    // 3. Return the response.
    return res;
  }
}
