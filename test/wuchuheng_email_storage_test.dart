@Timeout(Duration(seconds: 100))
import 'dart:io';

import 'package:test/test.dart';
import 'package:wuchuheng_email_storage/wuchuheng_email_storage.dart';

void main() {
  group('A group of tests', () {
    final awesome = Awesome();

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(awesome.isAwesome, isTrue);
    });
  });

  // The group of the tests for TCP client.
  group('TCP client tests', () {
    // Test the TCP connection to the server.
    test('Test TCP connection', () async {
      // Create a TCP server that listens on port 4041
      const tcpServerPort = 4041;
      final tcpServerHandle =
          await ServerSocket.bind(InternetAddress.loopbackIPv4, tcpServerPort);
      bool isServerConnected = false;
      // Listen for incoming connections
      tcpServerHandle.listen((Socket client) {
        isServerConnected = true;
        client.close();
        tcpServerHandle.close();
      });
      // Create a TCP client that connects to the server
      await Socket.connect('127.0.0.1', tcpServerPort);
      // Close the client
      expect(isServerConnected, isTrue);
    });
  });
}
