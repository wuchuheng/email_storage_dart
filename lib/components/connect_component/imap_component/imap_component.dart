import 'dart:async';

import 'package:enough_mail/enough_mail.dart';
import 'package:wuchuheng_email_storage/components/connect_component/common/set_is_log_enabled.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import 'imap_component_controller.dart' as imapComponetController;

part 'imap_compoent_middleware.dart';

late Task<ImapChannelName> task;

enum ImapChannelName {
  connect,
  setIsLogEnabled,
  getPathListOrInitByPrefixList, // 获取IMAP上保存存储路径列表
}

// Connect to imap server with email account.
Future<void> connect({required EmailAccount emailAccount, required bool isLogEnabled}) async {
  task = await _createMiddleware();
  await setIsLogEnabled<ImapChannelName>(
      task: task, channelName: ImapChannelName.setIsLogEnabled, isLogEnabled: isLogEnabled);
  ChannelAbstract channel = task.createChannel(name: ImapChannelName.connect);
  Completer<void> comparable = Completer<void>();
  channel.listen((message, channel) async {
    comparable.complete();
    channel.close();
  });
  channel.send(emailAccount);

  return comparable.future;
}

// To get the list path or init the path from imap server.
Future<List<String>> getPathListOrInitByPrefixList({required List<String> initPathList}) async {
  Completer<List<String>> completer = Completer();
  task.createChannel(name: ImapChannelName.getPathListOrInitByPrefixList)
    ..listen((message, channel) async {
      assert(message is List<String>);
      completer.complete(message as List<String>);
      channel.close();
    })
    ..send(initPathList);

  return completer.future;
}
