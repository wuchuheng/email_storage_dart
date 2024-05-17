import 'dart:io';

import 'package:test/expect.dart';
import 'package:wuchuheng_env/wuchuheng_env.dart';

class ImapAccount {
  final String host;
  final String username;
  final String password;

  ImapAccount({
    required this.host,
    required this.username,
    required this.password,
  });
}

// Get the list of imap accounts from the .env file in the `getImapAccounts` function.
List<ImapAccount> getImapAccounts() {
  DotEnv(path: '${Directory.current.path}/.env');
  // Declare a list of EmailAccount objects.
  final imapAccounts = <ImapAccount>[];
  // while loop to get all email accounts from the .env file.
  int i = 1;
  while (true) {
    final imapHost = DotEnv.get("${i}_IMAP_HOST", '');
    final emailUsername = DotEnv.get("${i}_EMAIL_USERNAME", '');
    final emailPassword = DotEnv.get("${i}_EMAIL_PASSWORD", '');
    // if any of the email account fields is empty, break the loop.
    if (imapHost.isEmpty || emailUsername.isEmpty || emailPassword.isEmpty) {
      break;
    }
    // Add the email account to the list.
    imapAccounts.add(ImapAccount(
      host: imapHost,
      username: emailUsername,
      password: emailPassword,
    ));
    i++;
  }
  return imapAccounts;
}

void testAccessEnv() {
  // Print the email accounts.
  final imapAccounts = getImapAccounts();
  expect(imapAccounts.isNotEmpty, isTrue);
}
