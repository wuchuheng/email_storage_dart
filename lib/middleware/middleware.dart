import 'package:wuchuheng_email_storage/controllers/connect_controller.dart';
import 'package:wuchuheng_email_storage/services/imap_service/imap_service_abstract.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import '../dto/channel_name/channel_name.dart';
import '../services/imap_service/imap_service.dart';
import '../services/smtp_service/smtp_service.dart';
import '../services/smtp_service/smtp_service_abstract.dart';

late SmtpServiceAbstract smtpService;
late ImapServiceAbstract imapService;

/// This file is the interaction file for isolate between main thread and isolate thread.
Future<Task> createMiddleTask() async {
  Task task = await IsolateTask(
    (message, channel) async {
      final ChannelName channelName = enumFromString<ChannelName>(ChannelName.values, channel.name);
      switch (channelName) {
        case ChannelName.connect:
          smtpService = SmtpService();
          imapService = ImapService();
          await connectController(
            message: message,
            channel: channel,
            smtpService: smtpService,
            imapService: imapService,
          );
          break;
      }
    },
  );

  return task;
}
