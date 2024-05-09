@Timeout(Duration(seconds: 100))
import 'dart:io';

import 'package:test/test.dart';
import 'package:wuchuheng_env/wuchuheng_env.dart';

import 'integration_test/env.dart';
import 'integration_test/imap.dart';

void main() {
  // Import the .env file
  setUp(() => DotEnv(path: '${Directory.current.path}/.env'));
  group('Access .env file test', () {
    test('Access all email accounts from env', () => testAccessEnv());
  });
  group('IMAP client test', () {
    test('Test IMAP client connection', () => testImapConnection());
    test(
        'Test the connection timeout of IMAP client',
        // Test the first response of the IMAP client will be not sent,
        () => testImapFirstResponseTimeout());
  });
}
