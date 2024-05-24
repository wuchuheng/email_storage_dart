import 'package:wuchuheng_email_storage/src/exceptions/login_exception.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/validator/validator_abstract.dart';

class LoginStatusValidator implements ValidatorAbstract {
  final bool isLogin;

  LoginStatusValidator({required this.isLogin});

  @override
  void validate() {
    // 1. Check the login status.
    if (!isLogin) {
      throw LoginException('The user is not logged in.');
    }
  }
}
