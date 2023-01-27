import 'dart:io';

import 'package:wuchuheng_logger/wuchuheng_logger.dart';

Future<void> checkPathOrCreate({required String path}) async {
  if (!await Directory(path).exists()) {
    Logger.info('Create path: $path');
    await Directory(path).create(recursive: true);
  }
}
