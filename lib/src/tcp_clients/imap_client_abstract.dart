abstract class ImapClientAbstract {
  Future<void> connect();
  Future<void> login();
  Future<void> logout();
  Future<void> disconnect();
  Future<void> selectMailbox(String mailbox);
  Future<void> search(String query);
  Future<void> fetch(String sequenceSet, List<String> attributes);
  Future<void> store(String sequenceSet, String item, String value);
  Future<void> copy(String sequenceSet, String mailbox);
  Future<void> expunge();
  Future<void> noop();
  Future<void> close();
}
