import 'dart:async';

import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/folder.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/mailbox.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/capability_response.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';

/// Abstract class representing the interface for an IMAP client.
abstract class ImapClientAbstract {
  /// Connects to the IMAP server.
  ///
  /// This method establishes a connection with the IMAP server.
  /// It returns a [Future] that completes when the connection is established.
  Future<void> connect();

  /// Sends the CAPABILITY command to the server.
  ///
  /// The CAPABILITY command requests a listing of capabilities that the server supports.
  /// The server responds with a list of capability names, which can include both
  /// standard and non-standard capabilities.
  ///
  /// Example usage:
  /// ```dart
  /// var capabilities = await client.capability();
  /// print(capabilities);
  /// ```
  ///
  /// For more information, see the IMAP protocol specification:
  /// [RFC 3501 - INTERNET MESSAGE ACCESS PROTOCOL - VERSION 4rev1](https://datatracker.ietf.org/doc/html/rfc3501#section-6.1.1)
  ///
  /// Returns a [CapabilityResponse] object representing the server's response.
  Future<CapabilityResponse> capability();

  /// Logs in to the IMAP server using the `LOGIN` command as per the IMAP4rev1 protocol.
  ///
  /// This method should be called after establishing a connection to the IMAP server.
  /// It authenticates the user with the server using the provided username and password.
  ///
  /// For more information, see the IMAP protocol specification:
  /// [RFC 3501 - INTERNET MESSAGE ACCESS PROTOCOL - VERSION 4rev1](https://datatracker.ietf.org/doc/html/rfc3501#section-6.2.3)
  ///
  /// Throws an [ImapException] if the login fails.
  Future<Response<void>> login();

  /// Selects a mailbox on the server using the `SELECT` command as per the IMAP4rev1 protocol.
  ///
  /// This method allows the client to select a specific mailbox on the server.
  /// The `SELECT` command is part of the IMAP4rev1 protocol and is used to
  /// indicate that the client wants to access a specific mailbox for reading
  /// or writing operations.
  ///
  /// Example usage:
  /// ```dart
  /// ImapClientAbstract client = ImapClientAbstract();
  /// client.selectMailbox(mailbox: 'inbox');
  /// ```
  ///
  /// Returns a [Response<Mailbox>] representing the selected mailbox.
  Future<Response<Mailbox>> select({required String mailbox});

  /// Creates a new mailbox on the server using the `CREATE` command as per the IMAP4rev1 protocol.
  ///
  /// This command is used to create a new mailbox on the mail server.
  /// The mailbox name should be specified as an argument to the command.
  /// If the mailbox already exists, the server will return an error.
  ///
  /// Example usage:
  /// ```dart
  /// await client.create(mailbox: 'new_mailbox');
  /// ```
  ///
  /// For more information, see the IMAP protocol specification:
  /// [RFC 3501 - INTERNET MESSAGE ACCESS PROTOCOL - VERSION 4rev1](https://datatracker.ietf.org/doc/html/rfc3501#section-6.3.3)
  ///
  /// Returns a [Response<void>] indicating the result of the create operation.
  Future<Response<void>> create({required String mailbox});

  /// Fetches messages from the server.
  ///
  /// This method fetches messages from the currently selected mailbox.
  /// The specific messages to be fetched and the details to be retrieved can be
  /// specified by the command's parameters, though they are not detailed here.
  ///
  /// Example usage:
  /// ```dart
  /// await client.fetch();
  /// ```
  ///
  /// For more information, see the IMAP protocol specification:
  /// [RFC 3501 - INTERNET MESSAGE ACCESS PROTOCOL - VERSION 4rev1](https://datatracker.ietf.org/doc/html/rfc3501#section-6.4.5)
  ///
  /// Returns a [Future<void>] indicating the result of the fetch operation.
  Future<void> fetch();

  /// Lists mailboxes on the server using the `LIST` command according to the IMAP4rev1 protocol.
  ///
  /// This method sends the `LIST` command to the IMAP server to retrieve a list of mailboxes.
  /// It returns details of each mailbox including attributes, hierarchy delimiter, and name.
  ///
  /// Example usage:
  /// ```dart
  /// var response = await client.list(reference: '', name: '*');
  /// print(response);
  /// ```
  ///
  /// For more information, see the IMAP protocol specification:
  /// [RFC 3501 - INTERNET MESSAGE ACCESS PROTOCOL - VERSION 4rev1](https://datatracker.ietf.org/doc/html/rfc3501#section-6.3.8)
  ///
  /// Parameters:
  /// - `reference`: The reference name argument for the `LIST` command. It specifies the base for interpreting the mailbox name.
  /// - `name`: The mailbox name argument for the `LIST` command. It can include wildcards to match multiple mailboxes.
  ///
  /// Returns a [Response<Folder>] containing the list of mailboxes.
  Future<Response<List<Folder>>> list({String name = "", String pattern = ""});

  /// Deletes a mailbox.
  ///
  /// This method sends the `DELETE` command to the server to delete the specified mailbox.
  ///
  /// Example usage:
  /// ```dart
  /// var response = await client.delete(mailbox: 'INBOX.Trash');
  /// print(response);
  /// ```
  ///
  /// For more information, see the IMAP protocol specification:
  /// [RFC 3501 - INTERNET MESSAGE ACCESS PROTOCOL - VERSION 4rev1](https://datatracker.ietf.org/doc/html/rfc3501#section-6.3.4)
  ///
  /// Parameters:
  /// - `mailbox`: The name of the mailbox to delete.
  ///
  /// Returns a [Response] indicating the success or failure of the operation.
  Future<Response<void>> delete({required String mailbox});
}
