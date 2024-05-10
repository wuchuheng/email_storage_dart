// This checker to check the capability was valid
abstract class Imap4CapabilityCheckerAbstract {
  // Check if the connection is valid.
  Future<void> checkConnection();

  // Check if the first response is valid.
  Future<void> checkFirstResponse();

  // Check if the IMAPrev1 capability is valid.
  Future<void> checkCapabilities();

  // Check if the creation of the personal folder is valid.
  Future<void> checkCreateFolder();
}
