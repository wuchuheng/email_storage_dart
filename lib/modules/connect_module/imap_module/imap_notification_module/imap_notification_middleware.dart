import 'package:wuchuheng_email_storage/modules/connect_module/imap_module/imap_notification_module/imap_notification_controller.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

enum ImapNotificationChannelName {
  onNotification,
}

Future<Task<ImapNotificationChannelName>> createMiddlewareTask() async {
  return await IsolateTask<ImapNotificationChannelName>((message, channel) async {
    switch (channel.name) {
      case ImapNotificationChannelName.onNotification:
        await onNotification();
        channel.send('');
        break;
    }
  });
}
