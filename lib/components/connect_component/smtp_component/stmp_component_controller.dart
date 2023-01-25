import 'package:enough_mail/enough_mail.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

final bool isLogEnabled = true;

late SmtpClient smtpClient;
Future<void> connect({
  required EmailAccount emailAccount,
  required ChannelAbstract channel,
}) async {
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
  channel.send('');
}
