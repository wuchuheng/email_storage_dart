// This checker to check the capability was valid
abstract class Imap4CapabilityCheckerAbstract {
  // Check if the connection is valid.
  Future<void> checkConnection();

  // Check if the first response is valid.
  Future<void> checkFirstResponse();

  // Check if the IMAPrev1 capability is valid.
  Future<void> checkCapabilities();

  // Check if the authentication is valid.
  Future<void> checkAuthentication();

  // Check if the command: `LIST` is valid.
  Future<void> checkListCommand();

  // Clear testing mailboxes before checking the command: `SELECT`
  Future<void> clearTestingMailboxes();

  // Check if a creation of a personal folder is valid.
  Future<void> checkCreatePersonalFolder();

  // Check if the command: `SELECT` is valid.
  Future<void> checkSelectCommand();
}
