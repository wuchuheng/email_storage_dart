@Timeout(Duration(seconds: 100))
import 'dart:async';

import 'package:test/test.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/address.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/folder.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/mail.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/mailbox.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';
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

    const testMailboxName = 'INBOX';
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

    late Mailbox selectedMailbox;
    test('Test the `SELECT` command.', () async {
      final res = await imapClient.select(mailbox: testMailboxName);
      selectedMailbox = res.data;
      selectedMailbox.exists;
    });
    late final List<Folder> folders;
    test('Test the `LIST` command.', () async {
      final result = await imapClient.list(pattern: '*', name: '');
      folders = result.data;
    });
    const tmpBoxName = 'test';
    test('Test the `CREATE` command.', () async {
      final isCreatedMailbox =
          folders.indexWhere((el) => el.name == tmpBoxName) != -1;
      // If the mailbox is created, delete it.
      if (isCreatedMailbox) {
        await imapClient.delete(mailbox: tmpBoxName);
      }

      await imapClient.create(mailbox: tmpBoxName);
    });

    test('Test the command `DELETE`', () async {
      await imapClient.delete(mailbox: tmpBoxName);
    });

    test('Test the `APPEND` command.', () async {
      final Mail mail = Mail(
        subject: 'hello',
        from: Address(name: 'Wu', address: account.username),
        body: """New email""",
      );
      final res = await imapClient.append(mailbox: testMailboxName, mail: mail);
      res.data;
    });

    test('Test the `FETCH` command.', () async {
      final res = await imapClient.fetch(
        startSequenceNumber: 1,
        dataItems: ['BODY[TEXT]', 'BODY[HEADER.FIELDS (SUBJECT DATE)]', 'UID'],
      );
      res.data;
    });

    Future<Mailbox> selecteMailbox(String mailboxName) async {
      final Response<Mailbox> res =
          await imapClient.select(mailbox: mailboxName);
      return res.data;
    }

    test('Test the `UID FETCH` command.', () async {
      final Mailbox selectedMailbox = await selecteMailbox(testMailboxName);
      final queryDataItem = [
        'BODY[TEXT]',
        'BODY[HEADER.FIELDS (SUBJECT DATE)]',
        'UID'
      ];
      var res = await imapClient.uidFetch(
        startUid:
            selectedMailbox.uidNext == 1 ? 1 : selectedMailbox.uidNext - 1,
        dataItems: queryDataItem,
      );

      void testGroup() {
        expect(true, res.data.isNotEmpty);
        for (final mail in res.data) {
          for (final dataItem in queryDataItem) {
            expect(mail.dataItemMapResult[dataItem]?.isNotEmpty, true);
          }
        }
      }

      expect(res.data.length, 1);
      testGroup();
      res = await imapClient.uidFetch(
        startUid:
            selectedMailbox.uidNext == 1 ? 1 : selectedMailbox.uidNext - 1,
        endUid: '*',
        dataItems: queryDataItem,
      );
      testGroup();
    });

    test('Test the `UID STORE` command.', () async {
      final selectedMailbox = await selecteMailbox(testMailboxName);
      final res = await imapClient.uidStore(
        startUid: selectedMailbox.uidNext - 1,
        endUid: '*',
        dataItems: ['+FLAGS', '(\\Deleted)'],
      );
      res.data;
    });

    test('Test the `UID EXPUNGE` command.', () async {
      // 1. Select the mailbox.
      Mailbox selectedMailbox = await selecteMailbox(testMailboxName);

      // 2. Delete the last email.
      final uid = selectedMailbox.uidNext - 1;
      await imapClient.uidExpunge(
        startUid: uid,
        endUid: '*',
      );

      // 3. Check the number of emails in the mailbox.
      final oldExists = selectedMailbox.exists;
      selectedMailbox = await selecteMailbox(testMailboxName);
      final newExists = selectedMailbox.exists;
      expect(newExists, oldExists - 1);
    });
  });
}
