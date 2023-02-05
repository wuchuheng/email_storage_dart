import 'dart:async';

import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_email_storage/modules/connect_module/imap_module/imap_notification_module/dto/on_notification_parameter.dart';
import 'package:wuchuheng_email_storage/modules/connect_module/imap_module/imap_notification_module/imap_notification_module.dart';

import 'config/get_email_account.dart';

final timeout = 60 * 5;

bool isDisconnect = false;
void main() {
  late EmailAccount emailAccount;
  setUp(() {
    emailAccount = getEmailAccount();
  });
  test('onNotification', () async {
    final Future<void> Function() cancel = await notification(
      OnNotificationParameter(
        emailAccount: emailAccount,
        onDisconnect: () {
          isDisconnect = true;
        },
      ),
    );
    await cancel();
    await Future.delayed(Duration(seconds: timeout));
    expect(isDisconnect, true);
  }, timeout: Timeout(Duration(seconds: timeout)));
}
