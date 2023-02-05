// Used to notify the inbox files changed.
import 'dart:async';

import 'package:wuchuheng_email_storage/modules/connect_module/imap_module/imap_notification_module/dto/on_notification_parameter.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import 'imap_notification_middleware.dart';

Task<ImapNotificationChannelName>? _task;

Future<Task<ImapNotificationChannelName>> _getTask() async {
  _task ??= await createMiddlewareTask();

  return _task!;
}

Future<Future<void> Function()> notification(OnNotificationParameter value) async {
  final Task<ImapNotificationChannelName> task = await _getTask();
  final channel = task.createChannel(name: ImapNotificationChannelName.notification);
  Completer<void> completer = Completer<void>();
  channel.listen((message, channel) async {
    completer.complete();
    channel.close();
  });
  channel.send(value.emailAccount);
  // Listen to disconnect event;
  final disconnectChannel = task.createChannel(name: ImapNotificationChannelName.onDisconnect);
  disconnectChannel.listen((message, channel) async {
    value.onDisconnect();
    channel.close();
  });
  disconnectChannel.send(''); // launch disconnect channel
  await completer.future;
  // declare cancel callback here.
  return () {
    final cancelChannel = task.createChannel(name: ImapNotificationChannelName.cancel);
    Completer<void> completer = Completer();
    cancelChannel.listen((message, channel) async {
      completer.complete();
      cancelChannel.close();
    });
    return completer.future;
  };
}
