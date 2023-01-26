import 'package:enough_mail/enough_mail.dart';
import 'package:wuchuheng_email_storage/components/connect_component/connect_component_controller.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_email_storage/utils/convert_path_util.dart';

Future<void> cleanEmailBox({required EmailAccount emailAccount}) async {
  final password = emailAccount.password;
  final userName = emailAccount.userName;
  ImapClient imapClient = ImapClient(isLogEnabled: false, logName: "ImapLog");

  await imapClient.connectToServer(
    emailAccount.imapHost,
    emailAccount.imapPort,
    isSecure: emailAccount.imapTls,
    timeout: const Duration(seconds: 60),
  );
  await imapClient.login(userName, password);
  final String path = convertPathToEmailPath('${emailAccount.storageName}/$storageDirectoryPrefix');
  // to delete recursive box on imap protocol.
  List<Mailbox> boxes = await imapClient.listMailboxes(path: path);
  for (Mailbox box in boxes) {
    await imapClient.deleteMailbox(box);
  }
}
