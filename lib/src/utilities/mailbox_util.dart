import '../exceptions/imap_response_exception.dart';
import '../tcp_clients/imap_client/dto/mailbox.dart';
import '../tcp_clients/imap_client/dto/mailbox_permission.dart';

class MailboxUtil {
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
  static parseResponseToMailbox(List<String> data) {
    int exists = 0;
    int recent = 0;
    int uidValidity = 0;
    int uidNext = 0;
    List<String> flags = [];
    List<String> permanentFlags = [];
    MailboxPermission permission = MailboxPermission.READ_ONLY;

    for (final String line in data) {
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
          throw ResponseException(
              'The UIDVALIDITY is not found in the response.');
        }
        uidValidity = int.parse(uidValidityStr);
        continue;
      }

      if (line.contains('UIDNEXT')) {
        String uidNextStr =
            RegExp(r'\[UIDNEXT\s(\d+)\]').firstMatch(line)?.group(1) ?? "";
        if (uidNextStr.isEmpty) {
          throw ResponseException('The UIDNEXT is not found in the response.');
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
            throw ResponseException(
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
}
