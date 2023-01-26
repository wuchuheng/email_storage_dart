import 'dart:async';

import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

Future<void> setIsLogEnabled({required Task task, required String channelName, required bool isLogEnabled}) async {
  final ChannelAbstract channel = task.createChannel(name: channelName);
  Completer<void> completer = Completer();
  channel.listen((message, channel) async {
    completer.complete();
    channel.close();
  });
  channel.send(isLogEnabled);
  await completer.future;
}
