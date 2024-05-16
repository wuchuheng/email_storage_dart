import 'dart:async';
import 'dart:io';

import 'package:wuchuheng_email_storage/src/exceptions/imap_response_exception.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/mailbox.dart';
import 'package:wuchuheng_email_storage/src/utilities/log.dart';

import '../../../config/config.dart';
import '../capability_checker/capability_checker_abstract.dart';
import '../dto/address.dart';
import '../dto/command.dart';
import '../dto/mail.dart';
import '../dto/request.dart';
import '../dto/response.dart';

class ContinueInputCompleter {
  final Completer<void> completer;
  final Request request;
  ContinueInputCompleter({required this.completer, required this.request});
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

  Response _responseFlash = Response.create([]);

  /// Write the data to the socket.
  void _write(String data) {
    // 1. Print a log message with the data.
    data
        .split(EOF)
        .where((element) => element.isNotEmpty)
        .forEach((line) => log(line, level: LogLevel.TCP_GOING));

    // 2. Write the data to the socket.
    _socket?.write(data);
  }

  void _responseHandler(String response) {
    // 1. Check the tag in the response.
    final tag = response.split(' ')[0];
    final isIncorrectTag =
        !_pendingResponses.containsKey(tag) && !["*", "+"].contains(tag);
    if (isIncorrectTag) {
      log('The server did not respond a correct format message: $response',
          level: LogLevel.ERROR);
      return;
    }

    // 2. If the tag is "*", then it means the coming data is a part of the response.
    // and then we need to storage the response in the flash. and then return.
    if (tag == '*') {
      _responseFlash.add(response);
      return;
    }

    // 3. If the tag is "+", then it means the coming data is a part of the continuous input command.
    // The flowing steps must be done for the continuous input command.
    if (tag == '+') {
      // 3.1 Storage the response in the flash.
      _responseFlash.add(response);
      // 3.2 Continue input the data to the server.
      // 3.2.1 If the current continuous input completer is null, then throw an exception.
      if (_currentContinueCommand == null) {
        throw ResponseException(
          'The continuous input completer is null, it should not be null.',
        );
      }
      // 3.2.2 Get the input data from the request of the current continuous input command.
      // and then send the data to the server.
      final input = _currentContinueCommand!.request.continueInput;
      _write(input);

      return;
    }

    // 4. If the tag was not associated with any pending response, then return.
    if (!_pendingResponses.containsKey(tag)) {
      log(
        'The server did not respond a correct format message: $response',
        level: LogLevel.ERROR,
      );

      return;
    }

    // 5. Process the full response for the related command.
    // 5.1 Add the response to the flash.
    _responseFlash.add(response);

    final isOk = response.substring(tag.length + 1).startsWith('OK');

    // 5.2 If the status of the response is OK, then complete the response with the flash.
    if (isOk) {
      _pendingResponses[tag]?.complete(_responseFlash);
    } else {
      // 5.3 If the status of the response is not OK, then complete the response with an error.
      _pendingResponses[tag]?.completeError(Exception(_responseFlash.data));
    }

    // 6. If the command is a continuous input command, then complete the current continuous input completer.
    _currentContinueCommand?.completer.complete();

    // 7. Cleaning the useless data.
    // 7.1 Clear the flash.
    _responseFlash = Response.create([]);
    // 7.2 Clear the pending response.
    _pendingResponses.remove(tag);
  }

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
    final response = await _sendCommand(Request(command: Command.CAPABILITY));
    // Get the capabilities from the response. the response like:
    final capabilities = response.data.first;
    for (var capability in _requiredCapabilities) {
      if (!capabilities.contains(capability)) {
        throw Exception(
            'The IMAP server does not support capability: $capability');
      }
    }
  }

  /// Declare a map to store the pending response for each command.
  /// The key is the message tag and the value is the Future to wait for the response.
  /// The tag is used to identify the response for the command.
  final Map<String, Completer<Response>> _pendingResponses = {};

  /// Declare a completer to wait for the completion of a continuous input command with multiple input lines after the response tag is a sign of '+'.
  ///
  /// The completer is prevented that other commands send to the server before the process of the continuous input command is completed.
  /// So that the response of the continuous input command can be received correctly.
  /// And the response keeps the same order for every related command with the correct tag.
  ContinueInputCompleter? _currentContinueCommand;

  /// Build a sending message in IMAP format.and then send it to the server.
  /// Waiting for the response for this message.
  Future<Response> _sendCommand(Request request) async {
    // 1. If the command is a continuous input command, then wait for the completion of the previous continuous input command.
    await _currentContinueCommand?.completer.future;
    // 1.1 If the command is a continuous input command, then create a completer to wait for the completion of this command.
    if (request.continueInput.isNotEmpty) {
      _currentContinueCommand = ContinueInputCompleter(
        completer: Completer<void>(),
        request: request,
      );
    }

    // 2. Create a Completer with this command tag, the completer is used to wait for the response of this command from the server.
    // And the response will be followed by the tag to identify this completer and complete it.
    final responseCompleter = Completer<Response>();
    _pendingResponses[request.tag] = responseCompleter;

    // 3. Send the message to the server.
    _write(request.toMessage());

    // 4. Wait for the response of this command and return it.
    final Response result = await responseCompleter.future;
    return result;
  }

  List<String> _mailboxes = <String>[];

  @override
  Future<void> checkListCommand() async {
    Response res = await _sendCommand(
      Request(command: Command.LIST, arguments: ['""', '"*"']),
    );
    // Remove the last line of the response by the delimiter of EOF.
    res = Response.create(res.sublist(0, res.length - 1));
    // Get the list of the folders, from the response like:
    // LIST () "/" "Archive"
    // LIST () "/" "tmp"
    // LIST (\Trash) "/" "Deleted Messages"
    // LIST () "/" "Junk"
    // LIST (\Noinferiors) "/" "INBOX"
    // LIST () "/" "Drafts"
    _mailboxes = res.data
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
    await _sendCommand(
      Request(command: Command.LOGIN, arguments: [username, password]),
    );
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
    // 2.3.1 Define a variable to storage the padding futures to wait for the response.
    final futures = <Future<Response>>[];
    for (final level in levels) {
      for (final box in levelMapPathList[level]!) {
        Future<Response> response = _sendCommand(
          Request(command: Command.DELETE, arguments: ["\"$box\""]),
        );
        futures.add(response);
      }
    }

    // 2.4 Wait for all the futures to complete.
    await Future.wait(futures);
  }

  // Define a list of personal folders for testing.
  static const _testingPersonalFolders = [
    _testingMailbox,
    "$_testingMailbox/.history",
    "$_testingMailbox/.history/actions",
    "$_testingMailbox/.history/index",
  ];

  @override
  Future<void> checkCreatePersonalFolder() async {
    // 1. Define a list of pending futures to wait for the response.
    final futures = <Future<Response>>[];

    // 2. Loop through the list of personal folders and create them.
    for (final folder in _testingPersonalFolders) {
      futures.add(_sendCommand(
        Request(command: Command.CREATE, arguments: ['"$folder"']),
      ));
    }

    // 3. Wait for all the futures to complete.
    await Future.wait(futures);
  }

  @override
  Future<void> checkSelectCommand() async {
    for (String box in _testingPersonalFolders) {
      // 1. Send the command to select the mailbox.
      final res = await _sendCommand(
        Request(command: Command.SELECT, arguments: ['"$box"']),
      );
      // 2. Parse the response and hold the result in Mailbox. the response like:
      parseResponseToMailbox(res);
    }
  }

  final List<int> _createdMessageUids = <int>[];

  @override
  Future<void> checkAppendCommand({required String body}) async {
    // 1. Generate the mail content.
    final mail = Mail(
      subject: 'Test mail',
      from: Address(address: username),
      body: body,
    );

    // 2. Send the command to append the mail to the mailbox.
    final Response res = await _sendCommand(
      Request(
        command: Command.APPEND,
        // A003 APPEND saved-messages (\Seen) {310}
        arguments: ['"$_testingMailbox"', '{${mail.size()}}'],
        continueInput: "${mail.fullMail}$EOF",
      ),
    );

    // 3. Hold the uid of the appended message.
    final AppendResponse appendResponse = AppendResponse(res.data);
    _createdMessageUids.add(appendResponse.uid);
  }
}
