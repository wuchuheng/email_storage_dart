import 'dart:async';

import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_email_storage/modules/connect_module/imap_module/imap_notification_module/tcp_ping_module/dto/tcp_ping_parameter.dart';
import 'package:wuchuheng_email_storage/modules/connect_module/imap_module/imap_notification_module/tcp_ping_module/tcp_ping_module.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

part 'imap_notification_controller.dart';

enum ImapNotificationChannelName {
  notification,
  cancel,
  onDisconnect,
}

Future<Task<ImapNotificationChannelName>> createMiddlewareTask() async {
  return await IsolateTask<ImapNotificationChannelName>((message, channel) async {
    switch (channel.name) {
      case ImapNotificationChannelName.notification:
        assert(message is EmailAccount);
        await _notification(emailAccount: message);
        channel.send('');
        break;
      case ImapNotificationChannelName.onDisconnect:
        _onDisconnect(() {
          channel.send('');
        });
        break;
      case ImapNotificationChannelName.cancel:
        await _cancel();
        channel.send('');
        break;
    }
  });
}
