import 'package:test/test.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_email_storage/wuchuheng_email_storage.dart';

void main() {
  test('SMTP connecting test ', () async {
    final EmailAccount emailAccount = EmailAccount(
      imapHost: 'imap.163.com',
      smtpHost: 'smtp.163.com',
      password: 'JAYHEOQDHZEXKdfIVJ--',
      userName: 'tnmrlj@163.com',
    );
    await connect(emailAccount);
    print('ok');
  });
}
