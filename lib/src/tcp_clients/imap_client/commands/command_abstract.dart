import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';

abstract class CommandAbstract<T> {
  /// The command to execute. To fetch the data from the IMAP server with the command.
  Future<CommandAbstract> fetch();

  /// The command to validate the response from the IMAP server.
  CommandAbstract validate();

  /// Parse the response from the IMAP server.
  Response<T> parse();
}
