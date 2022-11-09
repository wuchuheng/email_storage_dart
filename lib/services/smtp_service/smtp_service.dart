import 'package:enough_mail/src/smtp/smtp_client.dart';
import 'package:wuchuheng_email_storage/services/smtp_service/smtp_service_abstract.dart';

import '../../dto/email_account/email_account.dart';

class SmtpService implements SmtpServiceAbstract {
  @override
  Future<SmtpClient> connect(EmailAccount emailAccount) async {
    final password = emailAccount.password;
    final client = SmtpClient(emailAccount.smtpHost, isLogEnabled: true);
    await client.connectToServer(emailAccount.smtpHost, emailAccount.smtpPort,
        isSecure: emailAccount.smtpTls, timeout: Duration(seconds: 60));
    await client.ehlo();
    if (client.serverInfo.supportsAuth(AuthMechanism.plain)) {
      await client.authenticate('user.name', password, AuthMechanism.plain);
    } else if (client.serverInfo.supportsAuth(AuthMechanism.login)) {
      await client.authenticate('user.name', password, AuthMechanism.login);
    }
    return client;
  }
}
