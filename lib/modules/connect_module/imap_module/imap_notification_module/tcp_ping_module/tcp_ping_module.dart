import 'dart:async';

import 'package:wuchuheng_email_storage/modules/connect_module/imap_module/imap_notification_module/tcp_ping_module/dto/tcp_ping_parameter.dart';
import 'package:wuchuheng_email_storage/modules/connect_module/imap_module/imap_notification_module/tcp_ping_module/tcp_ping_middleware.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

Task<TcpPingChannelName>? _task;
Future<Task<TcpPingChannelName>> _getTask() async {
  _task ??= await createTcpPingMiddlewareTask();
  return _task!;
}

Future<void> tcpPing(TcpPingParameter value) async {
  final task = await _getTask();
  final channel = task.createChannel(name: TcpPingChannelName.connect);
  Completer<void> completer = Completer<void>();
  channel.listen((message, channel) async {
    completer.complete();
  });
  channel.send(value);
  return completer.future;
}
