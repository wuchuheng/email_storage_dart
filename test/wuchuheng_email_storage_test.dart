import 'package:test/test.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_email_storage/wuchuheng_email_storage.dart';
import 'package:wuchuheng_env/wuchuheng_env.dart';

import 'config/clean_email_box.dart';
import 'config/set_up_env.dart';

void main() {
  late EmailAccount emailAccount;
  setUp(() async {
    setUpEnv();
    emailAccount = EmailAccount(
      imapHost: DotEnv.get('IMAP_HOST', ''),
      smtpHost: DotEnv.get('SMTP_HOST', ''),
      password: DotEnv.get('PASSWORD', ''),
      userName: DotEnv.get('USERNAME', ''),
      storageName: DotEnv.get('STORAGE_NAME', ''),
      localStoragePath: DotEnv.get('LOCAL_STORAGE_PATH', ''),
    );
    await cleanEmailBox(emailAccount: emailAccount);
  });

  test('EmailStorage connected testing ', () async {
    await connect(emailAccount: emailAccount, isLogEnabled: true);
  }, timeout: Timeout(Duration(seconds: 5 * 60)));
}
