import 'dart:io';

import 'package:enough_mail/enough_mail.dart';
import 'package:wuchuheng_email_storage/components/connect_component/connect_component_service/connect_component_local_path_service.dart';
import 'package:wuchuheng_email_storage/config/config.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_email_storage/utils/convert_path_util.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

Future<void> cleanEmailBox({required EmailAccount emailAccount}) async {
  Logger.info('Before clean email box.', symbol: 'Testing');
  final String localCachePath =
      await ConnectComponentLocalPathService.getStoragePathOrCreate(emailAccount: emailAccount);
  final d = Directory(localCachePath);
  if (await d.exists()) {
    await d.delete(recursive: true);
  }
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
  // Delete all box on imap server.
  for (String path in <String>[...rootPathList]) {
    path = convertPathToEmailPath(path: path, prefix: emailAccount.storageName);
    List<Mailbox> boxes = await imapClient.listMailboxes(path: path);
    for (Mailbox box in boxes) {
      await imapClient.deleteMailbox(box);
    }
  }

  Logger.info('After clean email box.', symbol: 'Testing');
}
