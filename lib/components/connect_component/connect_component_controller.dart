import 'package:wuchuheng_email_storage/components/connect_component/connect_component_service/connect_component_local_path_service.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import '../../dto/email_account/email_account.dart';
import '../../utils/convert_path_util.dart';
import 'imap_component/imap_component.dart' as imapComponent;
import 'smtp_component/smtp_component.dart' as smtpComponent;

bool isLogEnabled = false;

/// To connect email online and init local cache.
Future<void> connect({required EmailAccount emailAccount, required ChannelAbstract channel}) async {
  await smtpComponent.connect(emailAccount: emailAccount, isLogEnabled: isLogEnabled);
  await imapComponent.connect(emailAccount: emailAccount, isLogEnabled: isLogEnabled);
  final String path = convertPathToEmailStoragePath(path: '/', emailAccount: emailAccount);
  await imapComponent.checkPathExistedOrCreate(path: path);
  await ConnectComponentLocalPathService.getStoragePathOrCreate(emailAccount: emailAccount);
  channel.send('');
}
