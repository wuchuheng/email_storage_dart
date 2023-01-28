import 'package:enough_mail/enough_mail.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_email_storage/utils/convert_path_util.dart';
import 'package:wuchuheng_isolate_channel/src/service/channel/channel_abstract.dart';

bool isLogEnabled = true;

/// To connect imap server from local to online.
Future<ImapClient> connect({
  required EmailAccount emailAccount,
  required ChannelAbstract channel,
}) async {
  final password = emailAccount.password;
  final userName = emailAccount.userName;
  ImapClient imapClient = ImapClient(isLogEnabled: isLogEnabled, logName: "ImapLog");

  await imapClient.connectToServer(
    emailAccount.imapHost,
    emailAccount.imapPort,
    isSecure: emailAccount.imapTls,
    timeout: const Duration(seconds: 60),
  );
  await imapClient.login(userName, password);
  channel.send('');

  return imapClient;
}

// Get the path list or init that on IMAP server.
Future<List<String>> getPathListOrInitByPrefixList({
  required List<String> initPathList,
  required EmailAccount emailAccount,
  required ImapClient imapClient,
}) async {
  final String prefix = emailAccount.storageName;
  final List<String> result = [];
  for (String path in initPathList) {
    path = convertPathToEmailPath(path: path, prefix: prefix);
    final List<Mailbox> boxes = await imapClient.listMailboxes(path: path);
    if (boxes.isNotEmpty) {
      for (Mailbox element in boxes) {
        path = convertEmailPathToPath(path: element.path, prefix: prefix);
        result.add(path);
      }
    } else {
      await imapClient.createMailbox(path);
      result.add(convertEmailPathToPath(path: path, prefix: prefix));
    }
  }

  return result;
}
