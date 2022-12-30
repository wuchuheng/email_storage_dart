import 'dart:io';

import 'package:test/test.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_email_storage/wuchuheng_email_storage.dart';
import 'package:wuchuheng_env/wuchuheng_env.dart';

import 'config/set_up_env.dart';

void main() {
  setUp(() => setUpEnv());

  test('SMTP connecting test ', () async {
    final EmailAccount emailAccount = EmailAccount(
      imapHost: DotEnv.get('IMAP_HOST', ''),
      smtpHost: DotEnv.get('SMTP_HOST', ''),
      password: DotEnv.get('PASSWORD', ''),
      userName: DotEnv.get('USERNAME', ''),
    );
    await connect(emailAccount);
  });
}
