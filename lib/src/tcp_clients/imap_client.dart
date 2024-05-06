import 'dart:io';

import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client_abstract.dart';

class ImapClient implements ImapClientAbstract {
  final String host;
  final String username;
  final String password;
  ImapClient(
      {required this.host, required this.username, required this.password}) {
    assert(host.isNotEmpty, 'The host cannot be empty.');
    assert(username.isNotEmpty, 'The username cannot be empty.');
    assert(password.isNotEmpty, 'The password cannot be empty.');
  }

  // define the private state of the tcp connection to the server
  late Socket _socket;

  @override
  Future<void> close() {
    // TODO: implement close
    throw UnimplementedError();
  }

  @override
  Future<void> connect() async {
    // Create a TCP client over TLS that connects to the server
    _socket =
        await SecureSocket.connect(host, 993, timeout: Duration(seconds: 5));
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
