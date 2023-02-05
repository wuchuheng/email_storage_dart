import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';

class OnNotificationParameter {
  EmailAccount emailAccount;
  void Function() onDisconnect;

  OnNotificationParameter({required this.emailAccount, required this.onDisconnect});
}
