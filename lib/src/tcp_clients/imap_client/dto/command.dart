/// Enum representing various IMAP commands.
///
/// Each value in this enum represents a different IMAP command that can be sent to the server.
/// These commands are used to interact with the server and perform various operations such as retrieving capabilities,
/// listing mailboxes, logging in, deleting mailboxes, creating mailboxes, and selecting a mailbox.
///
/// The commands are:
/// - CAPABILITY: Retrieves the capabilities of the server.
/// - LIST: Lists all the mailboxes in the user's account.
/// - LOGIN: Logs the user into their account.
/// - DELETE: Deletes a specified mailbox.
/// - CREATE: Creates a new mailbox.
/// - SELECT: Selects a specified mailbox for further operations.
enum Command {
  CAPABILITY, // ignore: constant_identifier_names
  LIST, // ignore: constant_identifier_names
  LOGIN, // ignore: constant_identifier_names
  DELETE, // ignore: constant_identifier_names
  CREATE, // ignore: constant_identifier_names
  SELECT, // ignore: constant_identifier_names
  APPEND, // ignore: constant_identifier_names
}
