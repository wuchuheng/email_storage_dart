@Timeout(Duration(seconds: 100))
import 'package:test/test.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/folder.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/imap_client.dart';

import 'integration_test/env.dart';

void main() {
  // Import the .env file
  group('Access .env file test', () {
    test('Access all email accounts from env', () => testAccessEnv());
  });

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
    test(
      'Test the `CAPABILITY` command.',
      () async => await imapClient.capability(),
    );
    test('Test the `LOGIN` command.', () async => await imapClient.login());
    test('Test the `LIST` command.', () async {
      final folders = await imapClient.list(pattern: '*', name: '');
      folders.data.first;
    });
    test('Test the `SELECT` command.', () async {
      await imapClient.select(mailbox: 'INBOX');
    });
    late final List<Folder> folders;
    test('Test the `LIST` command.', () async {
      final result = await imapClient.list(pattern: '*', name: '');
      folders = result.data;
    });
    const testMailboxName = 'test';
    test('Test the `CREATE` command.', () async {
      final isCreatedMailbox =
          folders.indexWhere((el) => el.name == testMailboxName) != -1;
      // If the mailbox is created, delete it.
      if (isCreatedMailbox) {
        await imapClient.delete(mailbox: testMailboxName);
      }

      await imapClient.create(mailbox: testMailboxName);
    });

    test('Test the command `DELETE`', () async {
      await imapClient.delete(mailbox: testMailboxName);
    });
  });
}
