import 'dart:async';

import 'package:test/expect.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/capability_checker/capability_checker.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/imap_client.dart';
import 'package:wuchuheng_env/wuchuheng_env.dart';

import 'env.dart';
import 'tcp_test/security_tcp_server.dart';

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

const securityTcpServerPort = 993;

Future<void> testImapFirstResponseTimeout() async {
  final server = await createSecurityTcpServer(port: securityTcpServerPort);
  server.listen((socket) {});
  // Wait for 5 minutes.
  final imapClient = ImapClient(
    host: DotEnv.get('SSL_TCP_SERVER_DOMAIN', ''),
    username: 'test',
    password: 'test',
    timeout: Duration(seconds: 1),
  );
  // Expect the future error to be thrown after 5 seconds. the exception was thrown with Completer.completeError and the error message was 'The IMAP server did not responded any message.'
  // Get the error message from the exception.
  await imapClient.connect().catchError((e) {
    expect(e.toString(), 'The IMAP server did not responded any message.');
  });
  // Close the server.
  await server.close();
}

Future<void> testImapFirstResponseIncorrect() async {
  final server = await createSecurityTcpServer(port: securityTcpServerPort);
  // Send an incorrect response to the client.
  server.listen((socket) {
    socket.write('BAD');
  });
  // Wait for 5 minutes.
  final imapClient = ImapClient(
    host: DotEnv.get('SSL_TCP_SERVER_DOMAIN', ''),
    username: 'test',
    password: 'test',
  );
  await imapClient.connect().catchError((e) {
    expect(e.toString(), 'The server did not respond with an OK code.');
  });
  await server.close();
}

Future<void> testImapCapability() async {
  final imapAccounts = getImapAccounts();
  // For each IMAP account, test the capability of the IMAP server.
  for (final imapAccount in imapAccounts) {
    final imapCapabilityChecker = Imap4CapabilityChecker(
      host: imapAccount.host,
      username: imapAccount.username,
      password: imapAccount.password,
    );
    await imapCapabilityChecker.checkConnection();
    await imapCapabilityChecker.checkFirstResponse();
    await imapCapabilityChecker.checkCapabilities();
    await imapCapabilityChecker.checkAuthentication();
    await imapCapabilityChecker.checkListCommand();
    await imapCapabilityChecker.clearTestingMailboxes();
    await imapCapabilityChecker.checkCreatePersonalFolder();
    await imapCapabilityChecker.checkSelectCommand();
  }
}
