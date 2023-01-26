import 'dart:convert';

import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import '../../dto/email_account/email_account.dart';
import '../../utils/convert_path_util.dart';
import 'imap_component/imap_component.dart' as imapComponent;
import 'smtp_component/smtp_component.dart' as smtpComponent;

const storageDirectoryPrefix = 'storage';
bool isLogEnabled = false;

Future<void> connect({required String message, required ChannelAbstract channel}) async {
  final emailAccount = EmailAccount.fromJson(
    jsonDecode(message),
  );
  await smtpComponent.connect(emailAccount: emailAccount, isLogEnabled: isLogEnabled);
  await imapComponent.connect(emailAccount: emailAccount, isLogEnabled: isLogEnabled);
  await imapComponent.isBoxExisted(
      boxName: convertPathToEmailPath(
    '${emailAccount.storageName}/$storageDirectoryPrefix',
  ));

  channel.send('');
}
