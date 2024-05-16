/// The exception was thrown when the reponse from the server was not valid.
///
/// The exception was thrown with the error message: 'The IMAP server did not responded any message.'
///
library;

class ResponseException implements Exception {
  final String message;

  ResponseException(this.message);

  @override
  String toString() {
    return 'ImapResponseException: $message';
  }
}
