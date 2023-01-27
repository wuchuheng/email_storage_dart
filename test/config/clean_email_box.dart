import 'dart:io';

import 'package:enough_mail/enough_mail.dart';
import 'package:path/path.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_email_storage/utils/convert_path_util.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

Future<void> cleanEmailBox({required EmailAccount emailAccount}) async {
  Logger.info('Before clean email box.', symbol: 'Testing');
  final String localCachePath = join(emailAccount.localStoragePath, emailAccount.userName).toString();
  final d = Directory(localCachePath);
  if (await d.exists()) await d.delete(recursive: true);
  final password = emailAccount.password;
  final userName = emailAccount.userName;
  ImapClient imapClient = ImapClient(isLogEnabled: true, logName: "ImapLog");

  await imapClient.connectToServer(
    emailAccount.imapHost,
    emailAccount.imapPort,
    isSecure: emailAccount.imapTls,
    timeout: const Duration(seconds: 60),
  );
  await imapClient.login(userName, password);
  final String path = convertPathToStorageEmailPath(path: '/', prefix: emailAccount.storageName);
  // to delete recursive box on imap protocol.
  List<Mailbox> boxes = await imapClient.listMailboxes(path: path);
  for (Mailbox box in boxes) {
    await imapClient.deleteMailbox(box);
  }
  Logger.info('After clean email box.', symbol: 'Testing');
}
