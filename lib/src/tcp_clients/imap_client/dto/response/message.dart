/// `Message` is a class that encapsulates a message retrieved from an IMAP server.
///
/// Each `Message` object represents a single message from the server, identified by a unique sequence number (UID).
/// The message data is stored in a map (`dataItemMapResult`), which includes various data items extracted from the server response.
///
/// For example, consider a server response for a FETCH command:
///
/// ```
/// * 1 FETCH (BODY[TEXT] {19} line1 line2 line3 BODY[HEADER.FIELDS (SUBJECT DATE)] {64} SUBJECT: hello DATE: Wed, 29 May 2024 22:44:12.229361 +0800
/// )
/// ```
///
/// In this case, the sequence number is 1, and the data items include the body text and header fields (subject and date).
/// These data items, along with the UID, are extracted from the response and stored in a `Message` object.
///
/// The `Message` class provides a structured and convenient way to work with message data retrieved from an IMAP server.
class Message {
  /// The unique sequence number (UID) of the message.
  ///
  /// This number is used to identify the message within the server response.
  final int sequenceNumber;

  /// A map containing the data items extracted from the server response.
  ///
  /// The keys in the map represent the names of the data items, such as "BODY[TEXT]" or "BODY[HEADER.FIELDS]".
  final Map<String, String> dataItemMapResult;

  Message({
    required this.sequenceNumber,
    required this.dataItemMapResult,
  });
}
