import 'dart:convert';

import 'package:wuchuheng_email_storage/middleware/middleware.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import 'dto/channel_name/channel_name.dart';
import 'dto/email_account/email_account.dart';
import 'middleware/email_storage_middleware/email_storage_middleware.dart';
import 'middleware/email_storage_middleware/email_storage_middleware_abstract.dart';

/// Connecting to email with smtp and imap protocols.
Future<EmailStorageMiddlewareAbstract> connect(EmailAccount emailAccount) async {
  Task task = await createMiddleTask();
  final ChannelAbstract channel = task.createChannel(name: ChannelName.connect.name);
  channel.send(jsonEncode(emailAccount));
  await channel.listenToFuture();

  return EmailStoreMiddleWare(task: task);
}
