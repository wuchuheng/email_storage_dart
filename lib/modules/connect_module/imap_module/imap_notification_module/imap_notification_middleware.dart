import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

part 'imap_notification_controller.dart';

enum ImapNotificationChannelName {
  onNotification,
}

Future<Task<ImapNotificationChannelName>> createMiddlewareTask() async {
  return await IsolateTask<ImapNotificationChannelName>((message, channel) async {
    switch (channel.name) {
      case ImapNotificationChannelName.onNotification:
        assert(message is EmailAccount);
        await _onNotification(emailAccount: message);
        break;
    }
  });
}
