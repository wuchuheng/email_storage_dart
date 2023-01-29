import 'package:enough_mail/enough_mail.dart';
import 'package:wuchuheng_email_storage/config/config.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_email_storage/utils/convert_path_util.dart';
import 'package:wuchuheng_isolate_channel/src/service/channel/channel_abstract.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

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
  List<Mailbox> allBoxes = await imapClient.listMailboxes();
  for (String path in initPathList) {
    path = convertPathToEmailPath(path: path, prefix: prefix);
    List<Mailbox> boxes = allBoxes.where((element) {
      if (element.path.length < path.length) return false;
      return element.path.substring(0, path.length) == path;
    }).toList();
    if (boxes.isNotEmpty) {
      for (Mailbox element in boxes) {
        path = convertEmailPathToPath(path: element.path, prefix: prefix);
        result.add(path);
      }
    } else {
      try {
        await imapClient.createMailbox(path);
      } catch (e, t) {
        print(e);
        print(t);
      }
      path = convertEmailPathToPath(path: path, prefix: prefix);
      result.add(path);
    }
  }

  return result;
}

// Listening to operation log changed from IMAP server.
Future<void> listeningToOperationLog({
  required ChannelAbstract channel,
  required EmailAccount emailAccount,
  required ImapClient imapClient,
}) async {
  while (true) {
    final String path = convertPathToEmailPath(path: rootOperationLogPath, prefix: emailAccount.storageName);
    try {
      final box = await imapClient.selectMailboxByPath(path);
      Logger.info(box.messagesExists.toString());
      await Future.delayed(Duration(seconds: 1));
    } catch (e, track) {
      print(e);
    }
  }
}
