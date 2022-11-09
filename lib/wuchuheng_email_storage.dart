import 'dart:convert';

import 'package:wuchuheng_email_storage/services/smtp_service/smtp_service.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import 'dto/email_account/email_account.dart';
import 'middleware/channel_name.dart';
import 'middleware/email_storage_middleware/email_storage_middleware.dart';
import 'middleware/email_storage_middleware/email_storage_middleware_abstract.dart';

/// Connecting to an online file system.
Future<EmailStorageMiddlewareAbstract> connect(EmailAccount emailAccount) async {
  Task task = await IsolateTask((message, channel) async {
    final ChannelName channelName = enumFromString<ChannelName>(ChannelName.values, channel.name);
    switch (channelName) {
      case ChannelName.connect:
        await SmtpService().connect(EmailAccount.fromJson(jsonDecode(message)));
        channel.send('');
        break;
    }
  });
  final ChannelAbstract channel = task.createChannel(name: ChannelName.connect.name);
  channel.send(jsonEncode(emailAccount));
  final result = await channel.listenToFuture();
  print(result);

  return EmailStoreMiddleWare();
}
