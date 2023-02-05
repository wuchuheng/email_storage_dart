import 'dart:async';

import 'package:test/scaffolding.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_email_storage/modules/connect_module/imap_module/imap_notification_module/imap_notification_module.dart';

import 'config/get_email_account.dart';

final timeout = 60 * 5;

void main() {
  late EmailAccount emailAccount;
  setUp(() {
    emailAccount = getEmailAccount();
  });
  test('onNotification', () async {
    await onNotification(emailAccount: emailAccount);
    await Future.delayed(Duration(seconds: timeout));
  }, timeout: Timeout(Duration(seconds: timeout)));
}
