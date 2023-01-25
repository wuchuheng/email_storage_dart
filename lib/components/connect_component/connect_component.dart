import 'dart:async';
import 'dart:convert';

import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import '../../dto/channel_name/channel_name.dart';
import '../../dto/email_account/email_account.dart';
import '../../middleware/email_storage_middleware/email_storage_middleware.dart';
import '../../middleware/email_storage_middleware/email_storage_middleware_abstract.dart';
import 'connect_component_middleware.dart';

late Task task;

Future<EmailStorageMiddlewareAbstract> connect(EmailAccount emailAccount) async {
  task = await createConnectMiddleWareMiddleTask();
  final ChannelAbstract channel = task.createChannel(name: ChannelName.connect.name);
  Completer<void> completer = Completer();
  channel.listen((message, channel) async {
    completer.complete();
    channel.close();
  });
  channel.send(jsonEncode(emailAccount));
  await completer.future;

  return EmailStoreMiddleWare(task: task);
}
