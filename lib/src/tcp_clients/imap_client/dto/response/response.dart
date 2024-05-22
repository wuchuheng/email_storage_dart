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
  String? code;

  Response({
    required this.data,
    required this.tag,
    required this.status,
    required this.message,
    this.code,
  });
}
