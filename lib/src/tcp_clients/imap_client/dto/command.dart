/// Enum representing various IMAP commands.
///
/// Each value in this enum corresponds to a different IMAP command that can be sent to an IMAP server.
/// These commands facilitate various operations such as retrieving server capabilities, listing mailboxes,
/// user authentication, mailbox deletion, mailbox creation, mailbox selection, message appending, and message fetching.
enum Command {
  /// Retrieves the capabilities of the server.
  ///
  /// This command is used to ask the server to list its capabilities,
  /// such as the supported IMAP version and any optional features it supports.
  CAPABILITY, // ignore: constant_identifier_names

  /// Lists all the mailboxes in the user's account.
  ///
  /// This command is used to ask the server to list all the mailboxes that the user has access to.
  LIST, // ignore: constant_identifier_names

  /// Logs the user into their account.
  ///
  /// This command is used to authenticate the user with the server.
  LOGIN, // ignore: constant_identifier_names

  /// Deletes a specified mailbox.
  ///
  /// This command is used to ask the server to delete a specified mailbox.
  DELETE, // ignore: constant_identifier_names

  /// Creates a new mailbox.
  ///
  /// This command is used to ask the server to create a new mailbox.
  CREATE, // ignore: constant_identifier_names

  /// Selects a specified mailbox for further operations.
  ///
  /// This command is used to select a specified mailbox.
  /// Once a mailbox is selected, the client can perform operations on the mailbox, such as fetching messages.
  SELECT, // ignore: constant_identifier_names

  /// Appends a message to a specified mailbox.
  ///
  /// This command is used to ask the server to append a message to a specified mailbox.
  APPEND, // ignore: constant_identifier_names

  /// Fetches one or more messages from a specified mailbox.
  ///
  /// This command is used to ask the server to fetch one or more messages from a specified mailbox.
  FETCH, // ignore: constant_identifier_names

  /// Fetches specific messages from a specified mailbox using their unique identifiers (UIDs).
  ///
  /// This command is used to ask the server to fetch specific messages from a specified mailbox using their UIDs.
  /// This could be used when a client wants to retrieve specific messages from the mailbox.
  UID, // ignore: constant_identifier_names
}
