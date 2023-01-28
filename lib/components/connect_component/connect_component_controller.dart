import 'package:wuchuheng_email_storage/components/connect_component/connect_component_service/connect_component_local_path_service.dart';
import 'package:wuchuheng_email_storage/components/connect_component/database_component/database.dart';
import 'package:wuchuheng_email_storage/config/config.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import '../../dto/email_account/email_account.dart';
import 'imap_component/imap_component.dart' as imapComponent;
import 'smtp_component/smtp_component.dart' as smtpComponent;

bool isLogEnabled = false;
late AppDb database;

/// To connect email online and init local cache.
Future<void> connect({required EmailAccount emailAccount, required ChannelAbstract channel}) async {
  // Ensure that the account is correct by connecting to the online server.
  await smtpComponent.connect(emailAccount: emailAccount, isLogEnabled: isLogEnabled);
  await imapComponent.connect(emailAccount: emailAccount, isLogEnabled: isLogEnabled);
  // Check or initialize the path of the online server.
  List<String> pathList = await imapComponent.getPathListOrInitByPrefixList(initPathList: rootPathList);
  // Get or initialize the local cache directory.
  final String localCachePath = await ConnectComponentLocalPathService.getStoragePathOrCreate(
    emailAccount: emailAccount,
  );
  database = AppDb(dbSavedPath: localCachePath);
  // await database.into(database.path).insert(PathData(name: path));
  channel.send('');
}
