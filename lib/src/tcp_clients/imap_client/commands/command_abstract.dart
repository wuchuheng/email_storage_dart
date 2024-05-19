import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/validator/command_validator_abstract.dart';

abstract class CommandAbstract {
  /// The command to execute. To fetch the data from the IMAP server with the command.
  Future<CommandValidatorAbstract> fetch();
}
