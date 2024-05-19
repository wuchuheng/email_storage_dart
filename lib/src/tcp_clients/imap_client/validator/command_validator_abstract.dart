
import '../response_parser/response_parser_abstract.dart';

/// The abstract class to validate the command response from the IMAP server.
abstract class CommandValidatorAbstract {
  /// The command to validate the response from the IMAP server.
  ResponseParserAbstract validate();
}
