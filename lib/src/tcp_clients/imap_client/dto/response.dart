abstract interface class Response {
  /// Returns the length of the response data.
  ///
  /// This getter is used to get the number of response lines in the data.
  /// Each line is considered as a separate element.
  ///
  /// @return The number of lines in the response data.
  int get length;

  /// Add a factory method to create a new instance of the Response.
  ///
  /// This method is used to create a new instance of the Response.
  /// The data parameter is a list of strings that represent the response from the IMAP server.
  ///
  static Response create(List<String> data) => ResponseBuilder(data);

  /// Remove tags from the response.
  Response removeTags();

  /// Get the response data.
  List<String> get data;

  /// To string to print the List<String> data.
  @override
  String toString() {
    return data.join('\n');
  }

  /// Adds a new response to the existing data.
  ///
  /// This method is used to add a new response line to the existing data.
  /// The response is a string that represents a single line of the response from the IMAP server.
  ///
  /// @param response The response line to be added.
  void add(String response);

  /// Clears all the response data.
  ///
  /// This method is used to clear all the existing response data.
  /// It's useful when you want to discard the current data and start fresh.
  void clear();

  /// Returns a portion of the response data.
  ///
  /// This method is used to get a sublist of the response data from the specified start index to the end index.
  /// If the end index is not provided, the sublist will include all elements from the start index to the end of the data.
  ///
  /// @param start The start index of the sublist.
  /// @param end The end index of the sublist. If not provided, the sublist will go to the end of the data.
  /// @return A list containing the elements from the start index to the end index.
  List<String> sublist(int start, int? end);
}

/// This type is used to hold the response from an IMAP server.
/// The IMAP response data is in the format: `TAG message`. like the flowing:
/// ```
/// * CAPABILITY IMAP4rev1 LITERAL+ SASL-IR LOGIN-REFERRALS ID ENABLE IDLE AUTH=PLAIN AUTH=LOGIN
/// C1 OK Pre-login capabilities listed, post-login capabilities have more.
/// ```
class ResponseBuilder implements Response {
  final List<String> _data;

  ResponseBuilder(this._data);

  // Method to remove tags from each line
  @override
  Response removeTags() {
    final newData = data.map((line) {
      final tagPattern = RegExp(r'^[A-Z]+ ');
      return line.replaceFirst(tagPattern, '');
    }).toList();

    return ResponseBuilder(newData);
  }

  @override
  List<String> get data => _data;

  @override
  void add(String response) => _data.add(response);

  @override
  void clear() => _data.clear();

  @override
  int get length => _data.length;

  @override
  List<String> sublist(int start, int? end) => _data.sublist(start, end);
}
