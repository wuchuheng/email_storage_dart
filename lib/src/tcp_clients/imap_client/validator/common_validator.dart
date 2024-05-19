/// Checks the validity of a response from an IMAP server.
///
/// This function performs two checks:
/// 1. It checks that the response list is not empty. If it is, an exception is thrown.
/// 2. It checks that the last line of the response includes a specified tag. If it doesn't, an exception is thrown.
///
/// The function is used to validate responses like: "T1 OK success message."
///
/// @param response The list of response lines from the IMAP server.
/// @param tag The tag that should be included in the last line of the response.
void checkResponseFormat(List<String> response, String tag) {
  // 1. Check the acount of list of response must be 1 or more than 1.
  if (response.isEmpty) {
    throw Exception('The response is empty.');
  }

  // 2. Check the last line of the response must be include the tag.
  final lastLine = response.last;
  if (!lastLine.contains(tag)) {
    throw Exception('The response does not include the tag: $tag.');
  }
}
