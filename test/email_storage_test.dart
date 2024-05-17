@Timeout(Duration(seconds: 100))
import 'package:test/test.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/imap_client.dart';

import 'integration_test/env.dart';

void main() {
  // Import the .env file
  group('Access .env file test', () {
    test('Access all email accounts from env', () => testAccessEnv());
  });
  // group('IMAP client test', () {
  //   test('Test IMAP client connection', () => testImapConnection());
  //   test('Test the connection timeout of IMAP client',
  //       () => testImapFirstResponseTimeout());
  //   test('Test the first response from the IMAP was incorrect',
  //       () => testImapFirstResponseIncorrect());
  // });
  // group('IMAP capability test', () {
  //   test('Test the capability of the IMAP server', () => testImapCapability());
  // });

  group('IMAP client test', () {
    // 1. Get the first IMAP account from the .env file.
    final accounts = getImapAccounts();
    final account = accounts.first;
    // 2. Create an IMAP client with the IMAP account.
    final imapClient = ImapClient(
      host: account.host,
      username: account.username,
      password: account.password,
      timeout: Duration(seconds: 5),
    );

    // 3. Connect to the IMAP server.
    test('Test IMAP client connection', () async => await imapClient.connect());
  });
}
