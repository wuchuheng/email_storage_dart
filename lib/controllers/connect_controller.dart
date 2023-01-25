import 'dart:convert';

import 'package:wuchuheng_email_storage/services/imap_service/imap_service_abstract.dart';
import 'package:wuchuheng_email_storage/services/smtp_service/smtp_service_abstract.dart';
import 'package:wuchuheng_email_storage/services/storage_check_service.dart';
import 'package:wuchuheng_email_storage/utils/convert_path_util.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import '../dto/email_account/email_account.dart';

const storageDirectoryPrefix = 'storage';
final bool isLogEnabled = true;

Future<void> connectController({
  required String message,
  required ChannelAbstract channel,
  required SmtpServiceAbstract smtpService,
  required ImapServiceAbstract imapService,
}) async {
  final emailAccount = EmailAccount.fromJson(
    jsonDecode(message),
  );
  await smtpService.connect(emailAccount: emailAccount, isLogEnabled: isLogEnabled);
  await imapService.connect(emailAccount: emailAccount, isLogEnabled: isLogEnabled);

  // Check storage directory
  checkOnlineStorage(
    smtpService: smtpService,
    emailPath: convertPathToEmailPath(
      '${emailAccount.storageName}/$storageDirectoryPrefix',
    ),
  );
  channel.send('');
}
