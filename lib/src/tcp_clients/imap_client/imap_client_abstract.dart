import 'dart:async';

import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/mailbox.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/capability_response.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';

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
  /// Returns a [List<String>] object representing the server's response.
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
  Future<Response<Mailbox>> select({required String mailbox});

  /// Generates the documentation for the command `CREATE` in the IMAP protocol.
  ///
  /// This command is used to create a new mailbox on the mail server.
  /// The mailbox name should be specified as an argument to the command.
  /// If the mailbox already exists, the server will return an error.
  ///
  /// Example usage:
  /// ```
  /// CREATE "inbox"
  /// ```
  ///
  /// For more information about the IMAP protocol, refer to the RFC 3501 specification.
  Future<Response<void>> create({required String mailbox});

  Future<void> fetch();
}
