import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/capability_response.dart';

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
  
}
