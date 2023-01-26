import 'package:enough_mail/enough_mail.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
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

/// To check the box online if existed
Future<void> isBoxExisted({required String boxName, required ChannelAbstract channel}) async {
  List<Mailbox> boxes = await imapClient.listMailboxes(path: boxName);
  assert(boxes.length < 2);
  channel.send(boxes.isNotEmpty);
}

/// To create box on imap protocol.
Future<void> createBoxName({required String boxName, required ChannelAbstract<ChannelName> channel}) async {
  await imapClient.createMailbox(boxName);
  channel.send('');
}
