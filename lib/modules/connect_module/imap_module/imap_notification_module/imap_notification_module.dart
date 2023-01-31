// Used to notify the inbox files changed.
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import 'imap_notification_middleware.dart';

Task<ImapNotificationChannelName>? _task;

Future<Task<ImapNotificationChannelName>> _getTask() async {
  _task ??= await createMiddlewareTask();

  return _task!;
}

Future<void> onNotification({required EmailAccount emailAccount}) async {
  final Task<ImapNotificationChannelName> task = await _getTask();
  task.createChannel(name: ImapNotificationChannelName.onNotification).send(emailAccount);
}
