import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_env/wuchuheng_env.dart';

import 'set_up_env.dart';

EmailAccount getEmailAccount() {
  setUpEnv();

  return EmailAccount(
    imapHost: DotEnv.get('IMAP_HOST', ''),
    smtpHost: DotEnv.get('SMTP_HOST', ''),
    password: DotEnv.get('PASSWORD', ''),
    userName: DotEnv.get('USERNAME', ''),
    storageName: DotEnv.get('STORAGE_NAME', ''),
    localStoragePath: DotEnv.get('LOCAL_STORAGE_PATH', ''),
    timeout: 1000,
  );
}
