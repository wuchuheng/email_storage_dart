// Create a security tcp server within a function with the certification and key files.

import 'dart:convert';
import 'dart:io';

import 'package:wuchuheng_env/wuchuheng_env.dart';

Future<SecureServerSocket> createSecurityTcpServer({required int port}) async {
  // Load the certification and key files
  final certificate = File(DotEnv.get("SSL_CERT_FILE", "")).readAsStringSync();
  final key = File(DotEnv.get("SSL_KEY_FILE", "")).readAsStringSync();

  // Create a security context
  final context = SecurityContext()
    ..useCertificateChainBytes(utf8.encode(certificate))
    ..usePrivateKeyBytes(utf8.encode(key));
  // Create a server
  final server = await SecureServerSocket.bind('0.0.0.0', port, context);

  return server;
}
