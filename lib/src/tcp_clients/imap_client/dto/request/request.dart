import 'package:wuchuheng_email_storage/src/config/config.dart';

import '../command.dart';

final _tagPrefixMapMessageCount = <String, int>{};

class Request {
  Command command;
  List<String> arguments;
  late String tag;

  // Define a variable to store the input for multiple lines, that will be sent to the server.
  // when the server sends a continuation request with '+', the client will send the input.
  // The input will be stored in this variable.
  String continueInput;

  Request({
    required this.command,
    this.arguments = const [],
    this.continueInput = '',
  }) {
    assert(command == Command.APPEND ? continueInput.isNotEmpty : true);

    //1. Generate a new tag for the request.
    // 1.1 Get the tag prefix from the command.
    final String tagPrefix = command.toString().split('.').last.substring(0, 1);
    // 1.2 Get the message counter for the tag prefix. if it doesn't exist, set it to 1.
    final int messageCounter =
        _tagPrefixMapMessageCount.putIfAbsent(tagPrefix, () => 1);
    // 1.3 Increment the message counter for the tag prefix.
    _tagPrefixMapMessageCount[tagPrefix] = messageCounter + 1;
    // 1.4 Set the tag for the request.
    tag = '$tagPrefix$messageCounter';
  }

  /// Generate a message in IMAP format.
  ///
  @override
  String toString() {
    String argumentsString = arguments.join(' ');
    if (argumentsString.isNotEmpty) {
      argumentsString = ' $argumentsString';
    }

    return '$tag ${command.toString().split('.').last}$argumentsString$EOF';
  }
}
