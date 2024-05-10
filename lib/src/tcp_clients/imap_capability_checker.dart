import 'dart:async';
import 'dart:io';

import 'package:wuchuheng_email_storage/src/utilities/log.dart';

import './imap_capability_checker_abstract.dart';

/// Declare the commands in IMAP
enum IMAPCommands {
  capability,
}

class Imap4CapabilityChecker implements Imap4CapabilityCheckerAbstract {
  String host;
  String username;
  String password;
  int port;
  Duration connectionTimeout;

  SecureSocket? _socket;

  // Required capabilities for the IMAP server.
  static const List<String> _requiredCapabilities = [
    'IMAP4rev1',
  ];

  Imap4CapabilityChecker({
    required this.host,
    required this.username,
    required this.password,
    this.port = 993,
    this.connectionTimeout = const Duration(seconds: 5),
  }) {
    if (host.isEmpty) {
      throw Exception('Hostname is required');
    }
    if (username.isEmpty) {
      throw Exception('Username is required');
    }
    if (password.isEmpty) {
      throw Exception('Password is required');
    }
    if (port <= 0 || port > 65535) {
      throw Exception('Port is invalid');
    }
  }

  @override
  Future<void> checkConnection() async {
    // Create a secure connection to the IMAP server.
    _socket =
        await SecureSocket.connect(host, port, timeout: connectionTimeout);
    _socket?.listen(_onTcpData, onDone: _onTcpDone);
  }

  /// Callback function when the TCP connection is done.
  void _onTcpDone() {
    _socket?.destroy();
    _socket = null;
    _isReceivedFirstResponse = false;
  }

  bool _isReceivedFirstResponse = false;
  final Completer<void> _waitFirstResponseCompleter = Completer<void>();

  String _multiLineResponseFlash = "";
  void _responseHandler(String response) {
    // Check the tag in the response.
    final tag = response.split(' ')[0];
    final isIncorrectTag = !_pendingResponses.containsKey(tag) && tag != '*';
    if (isIncorrectTag) {
      log('The server did not respond a correct format message: $response',
          level: LogLevel.error);
      return;
    }

    // If the tag is "*", then it means the coming data is a part of the response.
    // and then we need to storage the response in the flash.
    if (tag == '*') {
      // Remove the '* ' within the response.
      response = response.substring(2);
      _multiLineResponseFlash +=
          _multiLineResponseFlash.isNotEmpty ? eof + response : response;
      return;
    }

    // If the tag is not "*", then it means the coming data is the response for the command.
    // Check the tag was in the pending response.
    if (!_pendingResponses.containsKey(tag)) {
      log('The server did not respond a correct format message: $response',
          level: LogLevel.error);
      return;
    }

    // Check the response was OK or not.
    // remove the tag from the response.
    response = response.substring(tag.length).trim();
    final successStatus = 'OK';
    if (response.startsWith(successStatus)) {
      response = response.substring(('$successStatus ').length);
      _multiLineResponseFlash += eof + response;
      _pendingResponses[tag]?.complete(_multiLineResponseFlash);
      // Clear the pending response.
      _pendingResponses.remove(tag);
      // Clear the flash.
      _multiLineResponseFlash = "";
    } else {
      _pendingResponses[tag]?.completeError(Exception(response));
    }
  }

  static const eof = '\r\n';

  /// Callback function when the TCP connection receives data.
  void _onTcpData(List<int> data) {
    final response = String.fromCharCodes(data);
    // Print a log message with the response.
    log("<- $response", level: LogLevel.debug);
    if (_isReceivedFirstResponse) {
      for (final line in response.split(eof)) {
        if (line == '') continue;
        _responseHandler(line);
      }
    } else {
      _waitFirstResponseTimer?.cancel();
      _waitFirstResponseCompleter.complete();
      _isReceivedFirstResponse = true;
    }
  }

  @override
  Future<void> checkCreateFolder() {
    // TODO: implement checkCreateFolder
    throw UnimplementedError();
  }

  Timer? _waitFirstResponseTimer;
  @override
  Future<void> checkFirstResponse() async {
    if (!_isReceivedFirstResponse) {
      // Timer to wait for the first response.
      _waitFirstResponseTimer = Timer(connectionTimeout, () {
        !_isReceivedFirstResponse
            ? _waitFirstResponseCompleter.completeError(
                Exception('The IMAP server did not responded any message.'))
            : _waitFirstResponseCompleter.complete();
      });

      await _waitFirstResponseCompleter.future;
    }
  }

  @override
  Future<void> checkCapabilities() async {
    // If the socket is not connected, return an error.
    if (_socket == null) {
      return Future.error(Exception('The socket is not connected.'));
    }
    final response = await _sendCommand(command: IMAPCommands.capability);
    final capabilities = response.split(eof).first;
    for (var capability in _requiredCapabilities) {
      if (!capabilities.contains(capability)) {
        throw Exception(
            'The IMAP server does not support capability: $capability');
      }
    }
  }

  /// Declare the map to store the increment number for each command to create a tag.
  /// The key is the command and the value is the increment number.
  /// The increment number is used to create a tag for the command.
  final Map<IMAPCommands, int> _commandUsageCount = {};

  /// Declare a map to store the pending response for each command.
  /// The key is the message tag and the value is the Future to wait for the response.
  /// The tag is used to identify the response for the command.
  final Map<String, Completer<String>> _pendingResponses = {};

  /// Build a sending message in IMAP format.and then send it to the server.
  /// Waiting for the response for this message.
  Future<String> _sendCommand({
    required IMAPCommands command,
  }) async {
    // Create a tag for the command.
    int tagCount = _commandUsageCount[command] ?? 0;
    tagCount++;
    _commandUsageCount[command] = tagCount;
    final newTag = command.toString().split('.').last[0] + tagCount.toString();

    // Compose the command message.
    final commandMessage = '$newTag ${command.toString().split('.').last}\r\n';
    // Create a Completer to wait for the response.
    final responseCompleter = Completer<String>();
    _pendingResponses[newTag] = responseCompleter;
    log('-> $commandMessage', level: LogLevel.debug);
    _socket?.write(commandMessage);

    return responseCompleter.future;
  }
}
