import 'package:enough_mail/enough_mail.dart';

import '../../dto/email_account/email_account.dart';

abstract class ImapServiceAbstract {
  late ImapClient imapClient;

  Future<ImapClient> connect({required EmailAccount emailAccount, required bool isLogEnabled});
}
