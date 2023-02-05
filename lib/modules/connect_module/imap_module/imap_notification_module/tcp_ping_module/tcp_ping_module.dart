import 'dart:async';

import 'package:wuchuheng_email_storage/modules/connect_module/imap_module/imap_notification_module/tcp_ping_module/dto/tcp_ping_parameter.dart';
import 'package:wuchuheng_email_storage/modules/connect_module/imap_module/imap_notification_module/tcp_ping_module/tcp_ping_middleware.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

Task<TcpPingChannelName>? _task;
Future<Task<TcpPingChannelName>> _getTask() async {
  _task ??= await createTcpPingMiddlewareTask();
  return _task!;
}

/// TODO: 这里返回一个回调，用于取消操作。
Future<void> tcpPing(TcpPingParameter value) async {
  final task = await _getTask();
  final channel = task.createChannel(name: TcpPingChannelName.connect);
  Completer<void> completer = Completer<void>();
  channel.listen((message, channel) async {
    channel.close();
    completer.complete();
  });
  channel.send(value);
  final disconnectChannel = task.createChannel(name: TcpPingChannelName.onDisconnect);
  disconnectChannel.listen((message, channel) async {
    value.onDisconnect();
    channel.close();
  });
  disconnectChannel.send('');

  return completer.future;
}

/// TODO: 这里对外暴露的是回调而不是再声明一个，这里要删除
Future<void> cancel() async {
  final task = await _getTask();
  final cancelChannel = task.createChannel(name: TcpPingChannelName.cancel);
  Completer<void> completer = Completer();
  cancelChannel.listen((message, channel) async {
    completer.complete();
    channel.close();
  });
  cancelChannel.send('');
  return completer.future;
}
