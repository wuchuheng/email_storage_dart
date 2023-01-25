import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail/src/smtp/smtp_client.dart';
import 'package:wuchuheng_email_storage/services/smtp_service/smtp_service_abstract.dart';

import '../../dto/email_account/email_account.dart';

final bool isLogEnabled = true;

class SmtpService implements SmtpServiceAbstract {
  @override
  late SmtpClient smtpClient;

  @override
  Future<SmtpClient> connect({required EmailAccount emailAccount, required bool isLogEnabled}) async {
    final password = emailAccount.password;
    final userName = emailAccount.userName;
    // Make an imap connection
    smtpClient = SmtpClient(emailAccount.smtpHost, isLogEnabled: isLogEnabled, logName: 'SMTP');
    await smtpClient.connectToServer(emailAccount.smtpHost, emailAccount.smtpPort,
        isSecure: emailAccount.smtpTls, timeout: Duration(seconds: 60));
    await smtpClient.ehlo();
    if (smtpClient.serverInfo.supportsAuth(AuthMechanism.plain)) {
      await smtpClient.authenticate(userName, password, AuthMechanism.plain);
    } else if (smtpClient.serverInfo.supportsAuth(AuthMechanism.login)) {
      await smtpClient.authenticate(userName, password, AuthMechanism.login);
    }

    return smtpClient;
  }
}
