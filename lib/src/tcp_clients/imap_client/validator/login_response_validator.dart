import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/response_parser/login_parser.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/response_parser/response_parser_abstract.dart';

import 'command_validator_abstract.dart';

class LoginResponseValidator implements CommandValidatorAbstract {
  final List<String> response;
  final String tag;
  LoginResponseValidator({required this.response, required this.tag});

  @override
  ResponseParserAbstract validate() =>
      LoginParser(response: response, tag: tag);
}
