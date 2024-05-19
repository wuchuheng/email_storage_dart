import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';

abstract class ResponseParserAbstract<T> {
  /// Parse the response from the IMAP server.
  Response<T> parse();
}
