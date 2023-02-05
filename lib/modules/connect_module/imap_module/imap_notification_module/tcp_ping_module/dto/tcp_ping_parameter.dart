import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';

class TcpPingParameter {
  EmailAccount emailAccount;
  void Function() onDisconnect;
  TcpPingParameter({required this.emailAccount, required this.onDisconnect});
}
