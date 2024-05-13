import 'package:wuchuheng_email_storage/src/exceptions/imap_response_exception.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response.dart';

import './mailbox_permission.dart';

/// Declare a type to hold a mailbox information. the information like the flowing from the IMAP server after the command: `SELECT` is executed.
/// ```
///  * 0 EXISTS
/// * 0 RECENT
/// * OK [UIDVALIDITY 1675209865]
/// * OK [UIDNEXT 1]
/// * FLAGS (\Answered \Flagged \Draft \Deleted \Seen \Recent $MailFlagBit0 $MailFlagBit1 $MailFlagBit2 $Forwarded Redirected $NotJunk NotJunk)
/// * OK [PERMANENTFLAGS (\Answered \Flagged \Draft \Deleted \Seen \Recent $MailFlagBit0 $MailFlagBit1 $MailFlagBit2 $Forwarded Redirected $NotJunk NotJunk \*)]
/// S1 OK [READ-WRITE] SELECT completed (took 108 ms)
/// ```
class Mailbox {
  int exists;
  int recent;
  int uidValidity;
  int uidNext;
  List<String> flags;
  List<String> permanentFlags;
  MailboxPermission permission;

  Mailbox({
    required this.exists,
    required this.recent,
    required this.uidValidity,
    required this.uidNext,
    required this.flags,
    required this.permanentFlags,
    required this.permission,
  });

  @override
  String toString() {
    return 'Mailbox{exists: $exists, recent: $recent, uidValidity: $uidValidity, uidNext: $uidNext, flags: $flags, permanentFlags: $permanentFlags, readWrite: $permission}';
  }
}

/// Decode the response from the IMAP server after the command: `SELECT` is executed.
/// And return a [Mailbox] object.
/// The response should be like the flowing:
/// ```
/// * 0 EXISTS
/// * 0 RECENT
/// * OK [UIDVALIDITY 1675270477]
/// * OK [UIDNEXT 1]
/// * FLAGS (\Answered \Flagged \Draft \Deleted \Seen \Recent $MailFlagBit0 $MailFlagBit1 $MailFlagBit2 $Forwarded Redirected $NotJunk NotJunk)
/// * OK [PERMANENTFLAGS (\Answered \Flagged \Draft \Deleted \Seen \Recent $MailFlagBit0 $MailFlagBit1 $MailFlagBit2 $Forwarded Redirected $NotJunk NotJunk \*)]
/// S1 [READ-WRITE] SELECT completed (took 108 ms)
/// ```
Mailbox parseResponseToMailbox(Response response) {
  int exists = 0;
  int recent = 0;
  int uidValidity = 0;
  int uidNext = 0;
  List<String> flags = [];
  List<String> permanentFlags = [];
  MailboxPermission permission = MailboxPermission.READ_ONLY;

  for (final String line in response.data) {
    if (line.contains('EXISTS')) {
      exists = int.parse(line.split(' ')[1]);
      continue;
    }
    if (line.contains('RECENT')) {
      recent = int.parse(line.split(' ')[1]);
      continue;
    }
    if (line.contains('UIDVALIDITY')) {
      // Exact the string between the square brackets that contains the UIDVALIDITY and int.
      // Like: [UIDVALIDITY 1675270477]
      String uidValidityStr =
          RegExp(r'\[UIDVALIDITY\s(\d+)\]').firstMatch(line)?.group(1) ?? "";
      if (uidValidityStr.isEmpty) {
        throw ImapResponseException(
            'The UIDVALIDITY is not found in the response.');
      }
      uidValidity = int.parse(uidValidityStr);
      continue;
    }

    if (line.contains('UIDNEXT')) {
      String uidNextStr =
          RegExp(r'\[UIDNEXT\s(\d+)\]').firstMatch(line)?.group(1) ?? "";
      if (uidNextStr.isEmpty) {
        throw ImapResponseException(
            'The UIDNEXT is not found in the response.');
      }
      uidNext = int.parse(uidNextStr);
      continue;
    }
    // To parse the line:* FLAGS (\Answered \Flagged \Draft \Deleted \Seen \Recent $MailFlagBit0 $MailFlagBit1 $MailFlagBit2 $Forwarded Redirected $NotJunk NotJunk)
    bool isFlags = RegExp(r'\sFLAGS\s\(([^\)]*)\)')
            .firstMatch(line)
            ?.group(1)
            ?.isNotEmpty ??
        false;
    if (isFlags) {
      String flagsStr = RegExp(r'\((.*)\)').firstMatch(line)?.group(1) ?? "";
      flags = flagsStr.split(' ');

      continue;
    }
    if (line.contains('PERMANENTFLAGS')) {
      String permissionStr =
          RegExp(r'\((.*)\)').firstMatch(line)?.group(1) ?? "";
      permanentFlags = permissionStr.split(' ');
      continue;
    }

    // Extract the permission from the response.
    if (line.contains('READ-WRITE') || line.contains('READ-ONLY')) {
      final RegExp permissionRegExp =
          RegExp(r'\[((?:READ-WRITE)|(?:READ-ONLY))\]');
      final String permissionStr =
          permissionRegExp.firstMatch(line)?.group(1) ?? "";
      switch (permissionStr) {
        case 'READ-WRITE':
          permission = MailboxPermission.READ_WRITE;
          break;
        case 'READ-ONLY':
          permission = MailboxPermission.READ_ONLY;
          break;
        default:
          throw ImapResponseException(
              'The permission is not found in the response.');
      }
    }
  }
  //

  return Mailbox(
    exists: exists,
    recent: recent,
    uidValidity: uidValidity,
    uidNext: uidNext,
    flags: flags,
    permanentFlags: permanentFlags,
    permission: permission,
  );
}
