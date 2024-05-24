import 'package:wuchuheng_email_storage/src/exceptions/imap_response_exception.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';

/// A utility class for handling responses.
///
/// This class provides static methods for validating, parsing, and manipulating responses.
class ResponseUtile {
  /// Validates the format of a response.
  ///
  /// Checks if the response is not empty and if the last line of the response starts with the provided tag.
  /// Throws a [ResponseException] if any of these conditions is not met.
  ///
  /// The [response] argument is the response to validate.
  /// The [tag] argument is the tag that each line of the response should start with.
  static void validateFormat(List<String> response, String tag) {
    // 1. Check the response is not empty.
    if (response.isEmpty) {
      throw ResponseException('The response is empty.');
    }

    // 2. Check the laster line of response is started with the tag.
    if (!response.last.startsWith(tag)) {
      throw ResponseException('The response is not started with the tag:$tag.');
    }
  }

  /// Parses the status of a response.
  ///
  /// Returns a [ResponseStatus] object representing the status of the response.
  ///
  /// The [response] argument is the response to parse.
  /// The [tag] argument is the tag that each line of the response should start with.
  static ResponseStatus parseStatus({
    required List<String> response,
    required String tag,
  }) {
    // 1. Validate the response format.
    validateFormat(response, tag);

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

  /// Parses the message from a response.
  ///
  /// Returns the parsed message as a string.
  ///
  /// The [response] argument is the response to parse.
  /// The [tag] argument is the tag that each line of the response should start with.
  static String parseMessage({
    required List<String> response,
    required String tag,
  }) {
    // 1. Validate the response format.
    validateFormat(response, tag);

    // 2. Parse the message from the last line of the response.
    String message =
        response.last.substring(tag.length + 1).split(' ').skip(1).join(' ');
    // 2.1 Check the response code exists and then remove it from the message.
    RegExp exp = RegExp(r'\[[^\]]+\]');
    message = message.replaceAll(exp, '').trim();

    return message;
  }

  /// Parses the code from a response.
  ///
  /// Returns the parsed code as a string.
  ///
  /// The [response] argument is the response to parse.
  /// The [tag] argument is the tag that each line of the response should start with.
  static String parseCode({
    required List<String> response,
    required String tag,
  }) {
    // 1. Validate the response format.
    validateFormat(response, tag);

    // 2. Parse the code from the last line of the response.
    String code =
        response.last.substring(tag.length + 1).split(' ').skip(1).first;
    // 2.1 Check the response code exists and then remove it from the message.
    RegExp exp = RegExp(r'\[([^\]]+)\]');
    final String result = exp.firstMatch(code)?.group(1) ?? '';

    return result;
  }

  /// Removes the tag from a response.
  ///
  /// Returns a new response with the tag removed from each line.
  /// Throws a [ResponseException] if a line does not start with the tag.
  ///
  /// The [response] argument is the response to remove the tag from.
  /// The [tag] argument is the tag to remove.
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

  /// Parses a response.
  ///
  /// Returns a [Response] object with the status, message, code, and data parsed from the response.
  ///
  /// The [response] argument is the response to parse.
  /// The [tag] argument is the tag that each line of the response should start with.
  static Response<List<String>> parseResponse({
    required List<String> response,
    required String tag,
  }) {
    // 1. Validate the response format.
    validateFormat(response, tag);

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
