@Timeout(Duration(seconds: 100))
import 'dart:io';

import 'package:test/test.dart';
import 'package:wuchuheng_env/wuchuheng_env.dart';

import 'env.dart';
import 'imap.dart';

void main() {
  // Import the .env file
  setUp(() => DotEnv(path: '${Directory.current.path}/.env'));
  group('Access .env file test', () {
    test('Access all email accounts from env', () => testAccessEnv());
  });
  group('IMAP client test', () {
    test('Test IMAP client connection', () => testImapConnection());
  });
}
