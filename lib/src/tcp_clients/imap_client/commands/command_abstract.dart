import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';

abstract class CommandAbstract<T> {
  /// The command to execute. To fetch the data from the IMAP server with the command.
  Future<CommandAbstract> execute();

  /// Parse the response from the IMAP server.
  Response<T> parse();
}
