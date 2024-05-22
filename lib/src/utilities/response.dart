import 'package:wuchuheng_email_storage/src/exceptions/imap_response_exception.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';

void _validateResponseFormat(List<String> response, String tag) {
  // 1. Check the response is not empty.
  if (response.isEmpty) {
    throw ResponseException('The response is empty.');
  }

  // 2. Check the laster line of response is started with the tag.
  if (!response.last.startsWith(tag)) {
    throw ResponseException('The response is not started with the tag:$tag.');
  }
}

class ResponseUtile {
  /// Parses the status of a response.
  ///
  /// This method takes no arguments and returns a [ResponseStatus] object.
  /// It is used to parse the status of a response and convert it into a
  /// [ResponseStatus] object for easier handling and manipulation.
  ///
  /// Example usage:
  /// ```dart
  /// ResponseStatus status = Response.parseStatus();
  /// print(status.statusCode);
  /// print(status.message);
  /// ```
  static ResponseStatus parseStatus({
    required List<String> response,
    required String tag,
  }) {
    // 1. Validate the response format.
    _validateResponseFormat(response, tag);

    // 2. Parse the status from the last line of the response.
    final status = response.last.substring(tag.length + 1).split(' ').first;
    switch (status) {
      case 'OK':
        return ResponseStatus.OK;
      case 'NO':
        return ResponseStatus.NO;
      case 'BAD':
        return ResponseStatus.BAD;
      default:
        throw ResponseException('The status is not supported: $status.');
    }
  }

  /// Parses the message from the response.
  ///
  /// This method takes in a response and extracts the message from it.
  /// It returns the parsed message as a string.
  static String parseMessage({
    required List<String> response,
    required String tag,
  }) {
    // 1. Validate the response format.
    _validateResponseFormat(response, tag);

    // 2. Parse the message from the last line of the response.
    String message =
        response.last.substring(tag.length + 1).split(' ').skip(1).join(' ');
    // 2.1 Check the response code exists and then remove it from the message.
    RegExp exp = RegExp(r'\[[^\]]+\]');
    message = message.replaceAll(exp, '').trim();

    return message;
  }

  /// Parses the code from the response.
  static String parseCode({
    required List<String> response,
    required String tag,
  }) {
    // 1. Validate the response format.
    _validateResponseFormat(response, tag);

    // 2. Parse the code from the last line of the response.
    String code =
        response.last.substring(tag.length + 1).split(' ').skip(1).first;
    // 2.1 Check the response code exists and then remove it from the message.
    RegExp exp = RegExp(r'\[([^\]]+)\]');
    final String result = exp.firstMatch(code)?.group(1) ?? '';

    return result;
  }

  static List<String> removeTag(List<String> response, String tag) {
    return response.map((line) {
      if (line.startsWith(tag)) {
        return line.substring(tag.length + 1);
      } else if (line.startsWith('* ')) {
        return line.substring(2);
      } else if (line.startsWith('+')) {
        return line;
      } else {
        throw ResponseException(
            'The response is not started with the tag:$tag.');
      }
    }).toList();
  }

  static Response<List<String>> parseResponse({
    required List<String> response,
    required String tag,
  }) {
    // 1. Validate the response format.
    _validateResponseFormat(response, tag);

    // 2. Remove the tag from the response.
    final List<String> result = removeTag(response, tag);
    // 2.1 Remove the last line of the response.
    result.removeLast();

    return Response<List<String>>(
      status: parseStatus(response: response, tag: tag),
      message: parseMessage(response: response, tag: tag),
      code: parseCode(response: response, tag: tag),
      data: result,
      tag: tag,
    );
  }
}
