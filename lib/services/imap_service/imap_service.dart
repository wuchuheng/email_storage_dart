import 'package:enough_mail/src/imap/imap_client.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_email_storage/services/imap_service/imap_service_abstract.dart';

class ImapService implements ImapServiceAbstract {
  @override
  late ImapClient imapClient;

  @override
  Future<ImapClient> connect({required EmailAccount emailAccount, required bool isLogEnabled}) async {
    final password = emailAccount.password;
    final userName = emailAccount.userName;
    imapClient = ImapClient(isLogEnabled: true, logName: "ImapLog");

    await imapClient.connectToServer(
      emailAccount.imapHost,
      emailAccount.imapPort,
      isSecure: emailAccount.imapTls,
      timeout: const Duration(seconds: 60),
    );
    await imapClient.login(userName, password);

    return imapClient;
  }
}
