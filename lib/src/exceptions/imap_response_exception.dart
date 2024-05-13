/// The exception was thrown when the reponse from the server was not valid.
///
/// The exception was thrown with the error message: 'The IMAP server did not responded any message.'
///
library;

class ImapResponseException implements Exception {
  final String message;

  ImapResponseException(this.message);

  @override
  String toString() {
    return 'ImapResponseException: $message';
  }
}
