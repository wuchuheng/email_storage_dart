class ImapConversation {
  int sessionId;
  int currentVersion = 0;
  Map<int, VersionConversation> versionMapConversation = {};

  ImapConversation({required this.sessionId});

  VersionConversation clientSay({required String content}) {
    ++currentVersion;
    final VersionConversation versionConversation = VersionConversation(
      clientSay: '$content\r\n',
      serverSay: '',
      version: currentVersion,
    );
    versionMapConversation[currentVersion] = versionConversation;
    return versionConversation;
  }
}

class VersionConversation {
  int version;
  String clientSay;
  String serverSay;
  VersionConversation({required this.clientSay, required this.serverSay, required this.version});
}
