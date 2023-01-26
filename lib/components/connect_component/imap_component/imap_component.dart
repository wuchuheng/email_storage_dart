import 'dart:async';

import 'package:enough_mail/enough_mail.dart';
import 'package:wuchuheng_email_storage/components/connect_component/common/set_is_log_enabled.dart';
import 'package:wuchuheng_email_storage/dto/channel_name/channel_name.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import 'imap_component_controller.dart' as imapComponetController;

part 'imap_compoent_middleware.dart';

late ImapClient imapClient;

late Task task;

enum ChannelName { connect, isBoxExisted, setIsLogEnabled }

// Connect to imap server with email account.
Future<void> connect({required EmailAccount emailAccount, required bool isLogEnabled}) async {
  task = await _createMiddleware();
  await setIsLogEnabled(task: task, channelName: ChannelName.setIsLogEnabled.name, isLogEnabled: isLogEnabled);
  ChannelAbstract channel = task.createChannel(name: ChannelName.connect.name);
  Completer<void> comparable = Completer<void>();
  channel.listen((message, channel) async {
    comparable.complete();
    channel.close();
  });
  channel.send(emailAccount);

  return comparable.future;
}

Future<bool> isBoxExisted({required String boxName}) async {
  ChannelAbstract channel = task.createChannel(name: ChannelName.isBoxExisted.name);
  Completer<bool> completer = Completer();
  channel.listen((message, channel) async {
    assert(message == true || message == false);
    completer.complete(message);
    channel.close();
  });
  channel.send(boxName);

  return completer.future;
}
