import 'dart:async';

import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/imap_client_abstract.dart';

import './services/connect_service.dart' as connect_service;

class ImapClient implements ImapClientAbstract {
  final String host;
  final String username;
  final String password;
  final Duration timeout;
  // define the private state of the tcp connection to the server

  ImapClient({
    required this.host,
    required this.username,
    required this.password,
    this.timeout = const Duration(seconds: 5),
  }) {
    assert(host.isNotEmpty, 'The host cannot be empty.');
    assert(username.isNotEmpty, 'The username cannot be empty.');
    assert(password.isNotEmpty, 'The password cannot be empty.');
    assert(timeout.inSeconds > 0, 'The timeout must be greater than 0.');
  }

  @override
  Future<void> connect() async {
    await connect_service.connect(
      host: host,
      timeout: timeout,
      onData: _onData,
    );
  }

  _onData(String data) {
    // handle the data received from the server
  }
}
