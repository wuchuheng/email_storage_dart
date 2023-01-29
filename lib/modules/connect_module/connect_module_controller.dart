import 'package:wuchuheng_email_storage/config/config.dart';
import 'package:wuchuheng_email_storage/modules/connect_module/connect_module_service/connect_module_local_path_service.dart';
import 'package:wuchuheng_email_storage/modules/connect_module/database_module/database.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import '../../dto/email_account/email_account.dart';
import 'database_module/model/path_model.dart';
import 'imap_module/imap_module.dart' as imapModule;
import 'smtp_module/smtp_module.dart' as smtpModule;

bool isLogEnabled = false;
late AppDb database;

/// To connect email online and init local cache.
Future<void> connect({required EmailAccount emailAccount, required ChannelAbstract channel}) async {
  // Ensure that the account is correct by connecting to the online server.
  await smtpModule.connect(emailAccount: emailAccount, isLogEnabled: isLogEnabled);
  await imapModule.connect(emailAccount: emailAccount, isLogEnabled: isLogEnabled);
  // Check or initialize the path of the online server.
  List<String> pathList = await imapModule.getPathListOrInitByPrefixList(initPathList: rootPathList);
  // Get or initialize the local cache directory.
  final String localCachePath = await ConnectModuleLocalPathService.getStoragePathOrCreate(
    emailAccount: emailAccount,
  );
  // Get the Single instance database.
  database = AppDb(dbSavedPath: localCachePath);
  // Check the root path or creating in the database.
  await Path.checkPathListOrCreate(database: database, pathList: pathList);
  // Listening to the operation log and get the the next Uid changed event
  imapModule.listeningToOperationLog();
  // TODO: delete code for testing.
  await Future.delayed(Duration(seconds: 600));
  channel.send('');
}
