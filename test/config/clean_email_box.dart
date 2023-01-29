import 'dart:io';

import 'package:enough_mail/enough_mail.dart';
import 'package:wuchuheng_email_storage/config/config.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_email_storage/modules/connect_module/connect_module_service/connect_module_local_path_service.dart';
import 'package:wuchuheng_email_storage/utils/convert_path_util.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

Future<void> cleanEmailBox({required EmailAccount emailAccount}) async {
  Logger.info('Before clean email box.', symbol: 'Testing');
  final String localCachePath = await ConnectModuleLocalPathService.getStoragePathOrCreate(emailAccount: emailAccount);
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
  bool isDelete = false;
  List<Mailbox> allBoxes = await imapClient.listMailboxes();
  for (String path in <String>[...rootPathList]) {
    path = convertPathToEmailPath(path: path, prefix: emailAccount.storageName);
    List<Mailbox> boxes = allBoxes.where((element) {
      if (element.path.length < path.length) return false;
      return element.path.substring(0, path.length) == path;
    }).toList();
    for (Mailbox box in boxes) {
      // To deleted all mail files
      await imapClient.selectMailboxByPath(box.path);
      final MessageSequence ms = MessageSequence.fromRangeToLast(1);
      final FetchImapResult imapData = await imapClient.uidFetchMessages(ms, 'BODY.PEEK[HEADER.FIELDS (subject)]');
      for (MimeMessage mm in imapData.messages) {
        final int uid = mm.uid!;
        final sequence = MessageSequence.fromId(uid, isUid: true);
        await imapClient.uidStore(sequence, ["\\Deleted"]);
        await imapClient.uidExpunge(sequence);
      }
      await imapClient.deleteMailbox(box);
      isDelete = true;
    }
  }
  if (isDelete) {
    await Future.delayed(Duration(seconds: 3));
  }
  await imapClient.closeMailbox();
  await imapClient.logout();
  imapClient.disconnect();

  Logger.info('After clean email box.', symbol: 'Testing');
}
