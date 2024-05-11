import 'dart:async';
import 'dart:io';

import 'package:wuchuheng_email_storage/src/utilities/log.dart';

import './imap_capability_checker_abstract.dart';

/// Declare the commands in IMAP
enum IMAPCommands {
  CAPABILITY, // ignore: constant_identifier_names
  LIST, // ignore: constant_identifier_names
  LOGIN, // ignore: constant_identifier_names
  DELETE // ignore: constant_identifier_names
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
          level: LogLevel.ERROR);
      return;
    }

    // If the tag is "*", then it means the coming data is a part of the response.
    // and then we need to storage the response in the flash.
    if (tag == '*') {
      // Remove the '* ' within the response.
      response = response.substring(2);
      _multiLineResponseFlash +=
          _multiLineResponseFlash.isNotEmpty ? EOF + response : response;
      return;
    }

    // If the tag is not "*", then it means the coming data is the response for the command.
    // Check the tag was in the pending response.
    if (!_pendingResponses.containsKey(tag)) {
      log('The server did not respond a correct format message: $response',
          level: LogLevel.ERROR);
      return;
    }

    // Check the response was OK or not.
    // remove the tag from the response.
    response = response.substring(tag.length).trim();
    final successStatus = 'OK';
    if (response.startsWith(successStatus)) {
      response = response.substring(('$successStatus ').length);
      _multiLineResponseFlash += EOF + response;
      _pendingResponses[tag]?.complete(_multiLineResponseFlash);
      // Clear the pending response.
      _pendingResponses.remove(tag);
      // Clear the flash.
      _multiLineResponseFlash = "";
    } else {
      _pendingResponses[tag]?.completeError(Exception(response));
    }
  }

  static const EOF = '\r\n'; // ignore: constant_identifier_names

  /// Callback function when the TCP connection receives data.
  void _onTcpData(List<int> data) {
    final response = String.fromCharCodes(data);
    // Print a log message with the response.
    log(response, level: LogLevel.TCP_COMING);
    if (_isReceivedFirstResponse) {
      for (final line in response.split(EOF)) {
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
    final response = await _sendCommand('', command: IMAPCommands.CAPABILITY);
    final capabilities = response.split(EOF).first;
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
  Future<String> _sendCommand(String msg,
      {required IMAPCommands command}) async {
    // Generate a new tag for the command.
    final newTag = _generateCommandTag(command);
    msg = msg.isEmpty ? '' : ' $msg';
    // Compose the command message.
    final newMsg = '$newTag ${command.toString().split('.').last}$msg$EOF';

    // Create a Completer to wait for the response.
    final responseCompleter = Completer<String>();
    _pendingResponses[newTag] = responseCompleter;
    log(newMsg, level: LogLevel.TCP_GOING);
    _socket?.write(newMsg);

    return responseCompleter.future;
  }

  String _generateCommandTag(IMAPCommands command) {
    int tagCount = _commandUsageCount[command] ?? 0;
    tagCount++;
    _commandUsageCount[command] = tagCount;
    return command.toString().split('.').last[0] + tagCount.toString();
  }

  List<String> _mailboxes = <String>[];

  @override
  Future<void> checkListCommand() async {
    String res = await _sendCommand('"" "*"', command: IMAPCommands.LIST);
    // Remove the last line of the response by the delimiter of EOF.
    res = res.split(EOF).sublist(0, res.split(EOF).length - 1).join(EOF);
    // Get the list of the folders, from the response like:
    // LIST () "/" "Archive"
    // LIST () "/" "tmp"
    // LIST (\Trash) "/" "Deleted Messages"
    // LIST () "/" "Junk"
    // LIST (\Noinferiors) "/" "INBOX"
    // LIST () "/" "Drafts"
    _mailboxes = res
        .split(EOF)
        .map((e) {
          // Capture the folder name from the element by the regex: (?<=")[^"]*(?="$)
          String folderName =
              RegExp(r'(?<=")[^"]*(?="$)').firstMatch(e)?.group(0) ?? "";
          return folderName;
        })
        .where((element) => element.isNotEmpty)
        .toList();
  }

  @override
  Future<void> checkAuthentication() async {
    await _sendCommand('$username $password', command: IMAPCommands.LOGIN);
  }

  // Define the testing mailboxes named “tmp”, and all folders under the “tmp” folder will be as a testing mailbox.
  static const _testingMailbox = "tmp";

  @override
  Future<void> clearTestingMailboxes() async {
    // 1. Get the testing mailboxes.
    final testingMailboxes = _mailboxes
        .where((element) => element.startsWith(_testingMailbox))
        .toList();
    // 2 Delete the testing mailboxes.
    // 2.1 Declaring a Map variable to store data according to the hierarchy of the mailbox path.
    final levelMapPathList = <int, List<String>>{};
    // 2.2 Loop through the testing mailboxes and store the data according to the hierarchy of the mailbox path.
    for (final String box in testingMailboxes) {
      final level = box.split('/').length;
      if (levelMapPathList[level] == null) {
        levelMapPathList[level] = [];
      }
      levelMapPathList[level]?.add(box);
    }
    // 2.3 Loop through the levelMapPathList and delete the testing mailboxes in the order of the hierarchy of the mailbox path.
    final levels = levelMapPathList.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    for (final level in levels) {
      for (final box in levelMapPathList[level]!) {
        await _sendCommand("\"$box\"", command: IMAPCommands.DELETE);
      }
    }
  }
}
