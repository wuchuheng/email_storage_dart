import 'package:test/expect.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client.dart';

import 'env.dart';

void testImapConnection() async {
  // Get the list of IMAP accounts from the .env file.
  final imapAccounts = getImapAccounts();
  // Loop through all the IMAP accounts.
  for (final imapAccount in imapAccounts) {
    // Create an IMAP client.
    final client = ImapClient(
      host: imapAccount.host,
      username: imapAccount.username,
      password: imapAccount.password,
    );
    // Connect to the IMAP server.
    bool isConnected = false;
    try {
      await client.connect();
      isConnected = true;
    } catch (e) {
      isConnected = false;
    }
    expect(isConnected, isTrue);
  }
}
