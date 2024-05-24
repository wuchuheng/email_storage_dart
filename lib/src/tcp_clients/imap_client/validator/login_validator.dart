import '../../../exceptions/login_exception.dart';
import 'validator_abstract.dart';

class LoginValidator implements ValidatorAbstract {
  final String username;
  final String password;

  LoginValidator({required this.username, required this.password});

  @override
  void validate() {
    // 1. Check the username.
    if (username.isEmpty) {
      throw LoginException('The username is empty.');
    }
    // 2. Check the password.
    if (password.isEmpty) {
      throw LoginException('The password is empty.');
    }
  }
}
