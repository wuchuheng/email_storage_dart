import 'dart:io';

import 'package:path/path.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

import '../../../dto/email_account/email_account.dart';

class ConnectComponentLocalPathService {
  static final String _prefix = 'emailStorageCache';

  /// 获取本地缓存的存储目录.
  static Future<String> getStoragePathOrCreate({required EmailAccount emailAccount}) async {
    String path = join(emailAccount.localStoragePath, _prefix, emailAccount.userName).toString();
    final d = Directory(path);
    if (!await d.exists()) {
      Logger.info('Create path: $path');
      await d.create(recursive: true);
    }

    return path;
  }
}
