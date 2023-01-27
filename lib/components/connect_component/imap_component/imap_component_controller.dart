import 'package:enough_mail/enough_mail.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_email_storage/utils/convert_path_util.dart';
import 'package:wuchuheng_isolate_channel/src/service/channel/channel_abstract.dart';

import 'imap_component.dart';

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

/// To check path existed or to create it.
Future<void> checkPathExistedOrCreate({required String path, required ChannelAbstract<ImapChannelName> channel}) async {
  path = convertPathToEmailPath(path);
  List<Mailbox> boxes = await imapClient.listMailboxes(path: path);
  assert(boxes.length < 2);
  if (boxes.isEmpty) await imapClient.createMailbox(path);
  channel.send('');
}
