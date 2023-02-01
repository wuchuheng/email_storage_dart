import 'dart:async';

import 'package:test/scaffolding.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_email_storage/modules/connect_module/imap_module/imap_notification_module/imap_notification_module.dart';

import 'config/get_email_account.dart';

void main() {
  late EmailAccount emailAccount;
  setUp(() {
    emailAccount = getEmailAccount();
  });
  test('onNotification', () async {
    print(DateTime.now());
    await onNotification(emailAccount: emailAccount);
    await Future.delayed(Duration(seconds: 2000));
  }, timeout: Timeout(Duration(seconds: 2000)));
}
