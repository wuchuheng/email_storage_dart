import 'package:enough_mail/enough_mail.dart';

import '../../dto/email_account/email_account.dart';

abstract class SmtpServiceAbstract {
  Future<SmtpClient> connect(EmailAccount account);
}
