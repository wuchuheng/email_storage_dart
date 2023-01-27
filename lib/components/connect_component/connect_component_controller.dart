import 'package:path/path.dart';
import 'package:wuchuheng_email_storage/utils/path_util.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import '../../dto/email_account/email_account.dart';
import '../../utils/convert_path_util.dart';
import 'imap_component/imap_component.dart' as imapComponent;
import 'smtp_component/smtp_component.dart' as smtpComponent;

String storageDirectoryPrefix = 'storage';
bool isLogEnabled = false;

Future<void> connect({required EmailAccount emailAccount, required ChannelAbstract channel}) async {
  final String path = join(emailAccount.localStoragePath, emailAccount.userName).toString();
  await checkPathOrCreate(path: path);
  await smtpComponent.connect(emailAccount: emailAccount, isLogEnabled: isLogEnabled);
  await imapComponent.connect(emailAccount: emailAccount, isLogEnabled: isLogEnabled);

  final String boxName = convertPathToStorageEmailPath(path: '/', prefix: emailAccount.storageName);
  final bool isExisted = await imapComponent.isBoxExisted(boxName: boxName);
  if (!isExisted) {
    await imapComponent.createBoxName(boxName: boxName);
  }

  channel.send('');
}
