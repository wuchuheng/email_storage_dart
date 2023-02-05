import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:wuchuheng_email_storage/modules/connect_module/imap_module/imap_notification_module/tcp_ping_module/dto/tcp_ping_parameter.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

part 'tcp_ping_controller.dart';

enum TcpPingChannelName {
  connect,
  onDisconnect,
  cancel,
}

Future<Task<TcpPingChannelName>> createTcpPingMiddlewareTask() async {
  return IsolateTask<TcpPingChannelName>((message, channel) async {
    switch (channel.name) {
      case TcpPingChannelName.connect:
        assert(message is TcpPingParameter);
        await _tcpPing(message as TcpPingParameter);
        channel.send('');
        break;
      case TcpPingChannelName.onDisconnect:
        assert(message is String);
        _onDisconnect(() => channel.send(''));
        break;
      case TcpPingChannelName.cancel:
        await _cancel();
        channel.send('');
        break;
    }
  });
}
