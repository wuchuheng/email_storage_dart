import 'dart:async';
import 'dart:io';

import 'package:wuchuheng_hooks/wuchuheng_hooks.dart';

/// Connect to the IMAP server over a secure socket.
///
/// The [host] is the hostname of the IMAP server.
/// The [timeout] is the duration to wait for the connection to be established.
///
Future<SecureSocket> connect({
  required String host,
  required Duration timeout,
  required Hook<String> dataRegister,
}) async {
  // 1. Create a result completer to return the result of the connection.
  final Completer<SecureSocket> result = Completer();

  // 2. Create a timer to wait for the initial greeting from the server.
  // 2.1 If the initial greeting is not received within the timeout, complete the result completer with an error.
  final timer = Timer(timeout, () {
    result.completeError(
        'The IMAP server did not respond with an initial greeting.');
  });

  // 3. Connect to the IMAP server over a secure socket using the host and port 993. and set the timeout.
  final socket = await SecureSocket.connect(host, 993, timeout: timeout);

  bool isGreetingReceived = false;

  // 4. Listen for response from the server.
  socket.listen((List<int> data) async {
    // 4.1 Check if the initial greeting is received.
    if (!isGreetingReceived && data.isNotEmpty) {
      isGreetingReceived = true;
      timer.cancel();
      result.complete(socket);
      // 4.2 Cancel the listener after the initial greeting is received.
    }
    // 4.3 Omit the data to the subscriber through the data register.
    dataRegister.set(String.fromCharCodes(data));
  });

  // 5. Wait for the first response from the server.
  return result.future;
}
