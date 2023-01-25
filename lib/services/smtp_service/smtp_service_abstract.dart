import 'package:enough_mail/enough_mail.dart';

import '../../dto/email_account/email_account.dart';

abstract class SmtpServiceAbstract {
  late SmtpClient smtpClient;

  Future<SmtpClient> connect({required EmailAccount emailAccount, required bool isLogEnabled});
}
