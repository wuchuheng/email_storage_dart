// Used to notify the inbox files changed.
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_email_storage/modules/connect_module/imap_module/imap_notification_module/imap_notification_middleware.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

Task<ImapNotificationChannelName>? _task;

Future<Task<ImapNotificationChannelName>> _getTask() async {
  _task ??= await createMiddlewareTask();

  return _task!;
}

Future<void> onNotification({required EmailAccount emailAccount}) async {
  final Task<ImapNotificationChannelName> task = await _getTask();
  task.createChannel(name: ImapNotificationChannelName.onNotification).send('');
}
