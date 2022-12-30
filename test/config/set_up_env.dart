import 'dart:io';

import 'package:wuchuheng_env/wuchuheng_env.dart';

void setUpEnv() {
  final file = '${Directory.current.path}/test/.env';
  DotEnv(path: file);
  assert(DotEnv.get('IMAP_HOST', '').isNotEmpty);
  assert(DotEnv.get('SMTP_HOST', '').isNotEmpty);
  assert(DotEnv.get('USERNAME', '').isNotEmpty);
  assert(DotEnv.get('PASSWORD', '').isNotEmpty);
}
