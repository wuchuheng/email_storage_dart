import 'package:test/test.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_email_storage/wuchuheng_email_storage.dart';

import 'config/clean_email_box.dart';
import 'config/get_email_account.dart';

void main() {
  late EmailAccount emailAccount;
  setUp(() async {
    emailAccount = getEmailAccount();
  });

  test('EmailStorage connected testing ', () async {
    await cleanEmailBox(emailAccount: emailAccount);
    await connect(emailAccount: emailAccount, isLogEnabled: true);
  }, timeout: Timeout(Duration(seconds: 5 * 60)));

  test('Test to see if changes in the number of mailboxes can be detected', () async {});
}
