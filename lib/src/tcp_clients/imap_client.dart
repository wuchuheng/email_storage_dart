import 'dart:async';
import 'dart:io';

import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client_abstract.dart';

class ImapClient implements ImapClientAbstract {
  final String host;
  final String username;
  final String password;
  // define the private state of the tcp connection to the server
  late Socket _socket;
  // define the private state of the connection status
  bool _isConnected = false;

  ImapClient(
      {required this.host, required this.username, required this.password}) {
    assert(host.isNotEmpty, 'The host cannot be empty.');
    assert(username.isNotEmpty, 'The username cannot be empty.');
    assert(password.isNotEmpty, 'The password cannot be empty.');
  }

  @override
  Future<void> close() {
    // TODO: implement close
    throw UnimplementedError();
  }

  @override
  Future<void> connect() async {
    // Assert the connection state of the socket.
    assert(!_isConnected, 'The socket is already connected.');
    // Create a TCP client over TLS that connects to the server
    _socket =
        await SecureSocket.connect(host, 993, timeout: Duration(seconds: 5));
    _isConnected = true;

    // Create a completer to return the result of the connection.
    final Completer<void> result = Completer();
    bool isFirstResponse = false;
    final Completer<void> waitFirstResponse = Completer();

    // Set a timer to wait to check the first response was received.
    final waitFirstResponseTask = Timer(Duration(seconds: 5), () {
      if (!isFirstResponse) {
        waitFirstResponse.complete();
        result.completeError('The IMAP server did not responded any message.');
      }
    });

    // Listen for response from the server.
    _socket.listen((List<int> data) {
      if (!isFirstResponse) {
        isFirstResponse = true;
        waitFirstResponse.complete();
        waitFirstResponseTask.cancel();
        // Check if the server responded with a success code.
        if (String.fromCharCodes(data).contains('OK')) {
          result.complete();
        } else {
          result.completeError('The server did not respond with an OK code.');
        }
      } else {
        throw UnimplementedError();
      }
    }, onDone: () {
      // If the server closes the connection, set the connection status to false.
      _isConnected = false;
    }, onError: (error) {
      // If an error occurs, set the connection status to false and return the error.
      _isConnected = false;
      result.completeError(error);
    });

    await waitFirstResponse.future;

    return result.future;
  }

  @override
  Future<void> copy(String sequenceSet, String mailbox) {
    // TODO: implement copy
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect() {
    // TODO: implement disconnect
    throw UnimplementedError();
  }

  @override
  Future<void> expunge() {
    // TODO: implement expunge
    throw UnimplementedError();
  }

  @override
  Future<void> fetch(String sequenceSet, List<String> attributes) {
    // TODO: implement fetch
    throw UnimplementedError();
  }

  @override
  Future<void> login() {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<void> noop() {
    // TODO: implement noop
    throw UnimplementedError();
  }

  @override
  Future<void> search(String query) {
    // TODO: implement search
    throw UnimplementedError();
  }

  @override
  Future<void> selectMailbox(String mailbox) {
    // TODO: implement selectMailbox
    throw UnimplementedError();
  }

  @override
  Future<void> store(String sequenceSet, String item, String value) {
    // TODO: implement store
    throw UnimplementedError();
  }
}
