// ignore: constant_identifier_names
enum ResponseStatus { OK, NO, BAD }

class Response<T> {
  T data;
  final String tag;
  final ResponseStatus status;
  final String message;

  /// The response code of additional information about the response.
  /// Represents a response code received from the IMAP server.
  /// The [code] property stores the response code.
  /// For example, the response code `READ-ONLY` is stored in the [code] property.
  /// Like the following TCP data from the IMAP server:
  /// ```plaintext
  /// * OK [READ-ONLY] Select completed.
  /// ```
  /// And the [code] property stores the `READ-ONLY` value.
  String? code;

  Response({
    required this.data,
    required this.tag,
    required this.status,
    required this.message,
    this.code,
  });
}
