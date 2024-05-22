
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
