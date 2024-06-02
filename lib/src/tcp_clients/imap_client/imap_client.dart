import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:wuchuheng_email_storage/src/config/config.dart';
import 'package:wuchuheng_email_storage/src/exceptions/imap_response_exception.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/commands/append.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/commands/create.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/commands/delete_command.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/commands/fetch.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/commands/list.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/commands/login.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/current_execute_command.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/folder.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/mail.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/mailbox.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/request/request.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/capability_response.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/message.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/imap_client_abstract.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/validator/login_status_validator.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/validator/login_validator.dart';
import 'package:wuchuheng_email_storage/src/utilities/log.dart';
import 'package:wuchuheng_email_storage/src/utilities/response.dart';
import 'package:wuchuheng_hooks/wuchuheng_hooks.dart';

import 'commands/connect.dart' as connect_service;
import 'commands/capability.dart' as capability_service;
import 'commands/select.dart';
import 'dto/command.dart';

typedef OnImapWriteType = Future<Response<List<String>>> Function({
  required Request request,
});

class ImapClient implements ImapClientAbstract {
  final String host;
  final String username;
  final String password;
  final Duration timeout;
  late SecureSocket _socket;
  bool _isLogin = false;
  late Unsubscribe _onDataSubscription;

  /// The register to omit the data from the server to the subscriber with the callback.
  final Hook<String> _tcpDataSubscription = Hook<String>('');

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
    // 1. Print the log when the comming data from the server.
    _tcpDataSubscription.subscribe((response, _) {
      log(
        response.substring(0, response.length - 2),
        level: LogLevel.TCP_COMING,
      );
    });

    // 2. Connect to the IMAP server over a secure socket.
    _socket = await connect_service.connect(
      host: host,
      timeout: timeout,
      dataRegister: _tcpDataSubscription,
    );

    // 3. Bind the data handler to the socket.
    _onDataSubscription = _tcpDataSubscription.subscribe((data, _) {
      _onData(data);
    });
  }

  /// Store the response data into the flush;
  List<String> _flush = [];

  _onData(String data) {
    // 1. Get the tag for the current command.
    final String tag = _currentExecuteCommand!.request.tag;

    // 2. Parse the data from the server, and complete the completer.
    LineSplitter.split(data).where((e) => e.isNotEmpty).forEach((line) {
      // 2.1 Add the line to the flush.
      _flush.add(line);

      // 2.2 Complete the completer if the line contains the tag.
      final isLastLine =
          line.contains('OK') || line.contains('NO') || line.contains('BAD');
      if (isLastLine) {
        final tagFromServer = line.split(' ').first;

        // 2.2.1 Check if the tag from the server is the same as the tag from the client.
        // And then complete the completer.
        if (tagFromServer == tag) {
          _completeCurrentCommand(response: _flush);
          _flush = [];
        }
      }
    });
  }

  /// Define the completer to wait the current command response from the server
  CurrentExecuteCommand? _currentExecuteCommand;

  void _completeCurrentCommand({required List<String> response}) {
    _currentExecuteCommand?.timer.cancel();
    _currentExecuteCommand?.completer.complete(_flush);
  }

  Future<void> _setExecuteCommand({required Request request}) async {
    // 1. Wait the previous command response from the server finished.
    if (_currentExecuteCommand?.completer.isCompleted == false) {
      await _currentExecuteCommand!.completer.future;
    }

    // 2. Create a completer to wait the current command response from the server.
    // 2.1 Create a timer to handle the timeout of the current command.
    final timer = Timer(commandTimeout, () {
      final command = request.command.toString().split(' ').last.toUpperCase();
      _currentExecuteCommand!.completer.completeError(
        ResponseException('The command $command timeout.'),
      );
    });
    _currentExecuteCommand = CurrentExecuteCommand(
      request: request,
      completer: Completer(),
      timer: timer,
    );
  }

  /// Handles the TCP write event to the IMAP server.
  ///
  /// This method is called when the client sends a message to the IMAP server.
  /// The message is logged and then written to the socket.
  ///
  /// Parameter:
  /// - `message`: The message string to be sent to the IMAP server.
  void _onTcpWrite(String message) {
    // 1. Log the message.
    log(message.substring(0, message.length - 2), level: LogLevel.TCP_OUTGOING);

    // 2. Write the message to the server.
    _socket.write(message);
  }

  /// handle the data write to the server by the socket.
  ///
  // ignore: prefer_function_declarations_over_variables
  late final OnImapWriteType _write = ({required Request request}) async {
    // 1. Set the current execute command.
    await _setExecuteCommand(request: request);

    // 3. write the request to the server.
    final message = request.toString();
    _onTcpWrite(message);

    // 4. Validate the response format is correct.
    final List<String> response =
        await _currentExecuteCommand!.completer.future;

    ResponseUtile.validateFormat(response, request.tag);

    // 5. Return the response.
    // 5.1 Format the response from IMAP Server.
    final result =
        ResponseUtile.parseResponse(response: response, tag: request.tag);

    return result;
  };

  @override
  Future<CapabilityResponse> capability() async {
    return capability_service.capability(writeCommand: _write);
  }

  @override
  Future<Response<void>> login() async {
    // 1. Check if the client is already logged in.
    LoginValidator(password: password, username: username).validate();

    // 2. Login to the server.
    final result = await Login(
      username: username,
      password: password,
      writeCommand: _write,
    ).execute();

    // 2.1 Set the login status to true.
    _isLogin = true;

    return result;
  }

  Mailbox? _selectedMailbox;

  @override
  Future<Response<Mailbox>> select({required String mailbox}) async {
    // 1. Check if the client is already logged in.
    LoginStatusValidator(isLogin: _isLogin).validate();

    // 1.1 Create a select command.
    Select<Mailbox> selectCommand = Select(
      mailbox: mailbox,
      socketWrite: _write,
    );

    // 2. Fetch the select command.
    await selectCommand.execute();

    // 3. Parse the response.
    final Response<Mailbox> response = selectCommand.parse();

    // 4. Set the selected mailbox.
    _selectedMailbox = response.data;

    return response;
  }

  @override
  Future<Response<void>> create({required String mailbox}) async {
    // 1. Check if the client is already logged in.
    LoginStatusValidator(isLogin: _isLogin).validate();

    // 2. Execute the create command.
    final result = await Create(
      mailbox: mailbox,
      write: _write,
    ).execute();

    // 3. Return the result.

    return result;
  }

  @override
  Future<Response<List<Message>>> fetch({
    required List<String> dataItems,
    int? endSequenceNumber,
    required int startSequenceNumber,
  }) async {
    // 1. Check if the client is already logged in.
    LoginStatusValidator(isLogin: _isLogin).validate();
    // 2. Check if the selected mailbox is not null.
    if (_selectedMailbox == null) {
      throw ResponseException('No mailbox is selected.');
    }

    // 3.Perform the precedent of the `FETCH` command.
    // 3.1 Unbind the right to receive data from the server.
    // Because the right to process the data needs to be transferred to this class
    _onDataSubscription.unsubscribe();
    // 3.2 Block the other command to execute when the current command is executing.
    await _setExecuteCommand(request: Request(command: Command.FETCH));

    // 4. Execute the fetch command.
    final res = await Fetch(
      dataItems: dataItems,
      tcpDataSubscription: _tcpDataSubscription,
      endSequenceNumber: endSequenceNumber,
      startSequenceNumber: startSequenceNumber,
      tcpWrite: _onTcpWrite,
    ).execute();

    // 5.Perform the postcedent of the `FETCH` command.
    // 5.1 Unblock the other command to execute.
    _completeCurrentCommand(response: []);
    // 5.2 Rebind the `onData` subscription.
    _onDataSubscription = _tcpDataSubscription.subscribe(
      (data, _) => _onData(data),
    );

    return res;
  }

  @override
  Future<Response<List<Folder>>> list({
    String name = "",
    String pattern = "",
  }) async {
    // 1. Check if the client is already logged in.
    LoginStatusValidator(isLogin: _isLogin).validate();

    // 2. Create a list command.
    final listCommand = ListCommand(
      onWrite: _write,
      name: name,
      pattern: pattern,
    );

    // 3. Fetch the list command.
    await listCommand.execute();
    // 4. Parse the response.
    final Response<List<Folder>> result = listCommand.parse();

    // 5. Return the response.
    return result;
  }

  @override
  Future<Response<void>> delete({required String mailbox}) async {
    // 1. Check if the client status is ready for the command.
    LoginStatusValidator(isLogin: _isLogin).validate();

    // 2. Execute the  `delete` command.
    DeleteCommand deleteCommand = DeleteCommand(
      mailbox: mailbox,
      onImapWrite: _write,
    );
    final result = await deleteCommand.execute();

    return result;
  }

  @override
  Future<Response<void>> append({
    required String mailbox,
    required Mail mail,
  }) async {
    // 1. Check if the client status is ready for the command.
    LoginStatusValidator(isLogin: _isLogin).validate();

    // 2. Perform the precedent of the `APPEND` command.
    // 2.1 Cancel the `onData` subscription.
    _onDataSubscription.unsubscribe();

    // 2.2 Block the other command to execute when the current command is executing.
    await _setExecuteCommand(
        request: Request(
      command: Command.APPEND,
      continueInput: mailbox.toString(),
    ));

    // 3. Execute the `append` command.
    final result = await Append(
      mail: mail,
      mailbox: mailbox,
      onServerDataSubscription: _tcpDataSubscription,
      onTcpWrite: _onTcpWrite,
    ).execute();

    // 4. Perform the postcedent of the `APPEND` command.
    // 4.1 Unblock the other command to execute.
    _completeCurrentCommand(response: []);

    // 4.2 Rebind the `onData` subscription.
    _onDataSubscription = _tcpDataSubscription.subscribe(
      (data, _) => _onData(data),
    );

    return result;
  }

  @override
  Future<Response<List<int>>> uidFetch(
      {required int startSequenceNumber,
      int? endSequenceNumber,
      required List<String> dataItems}) {
    // TODO: implement uidFetch
    throw UnimplementedError();
  }
}
