// To connect smtp server from local to online.
import 'dart:async';

import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import '../common/set_is_log_enabled.dart';
import 'stmp_component_controller.dart' as smtpComponentController;

part 'smtp_component_middleware.dart';

late Task<ChannelName> task;

Future<void> connect({
  required EmailAccount emailAccount,
  required bool isLogEnabled,
}) async {
  task = await createMiddleware();
  await setIsLogEnabled<ChannelName>(task: task, channelName: ChannelName.setIsLogEnabled, isLogEnabled: isLogEnabled);
  ChannelAbstract channel = task.createChannel(name: ChannelName.connect);
  Completer<void> completer = Completer();
  channel.listen((message, channel) async {
    completer.complete();
    channel.close();
  });
  channel.send(emailAccount);

  return completer.future;
}
