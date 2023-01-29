part of 'imap_module.dart';

late ImapClient _imapClient;
late EmailAccount _emailAccount;

enum ImapChannelName {
  connect,
  setIsLogEnabled,
  getPathListOrInitByPrefixList, // Get the path list by prefix from IMAP server.
  listeningToOperationLog, // Listening to operation log.
}

Future<Task<ImapChannelName>> _createMiddleware() {
  return IsolateTask<ImapChannelName>((message, channel) async {
    switch (channel.name) {
      case ImapChannelName.connect:
        assert(message is EmailAccount);
        _imapClient = await imapComponetController.connect(emailAccount: message, channel: channel);
        _emailAccount = message;
        break;
      case ImapChannelName.setIsLogEnabled:
        assert(message is bool);
        imapComponetController.isLogEnabled = message;
        channel.send('');
        break;
      case ImapChannelName.getPathListOrInitByPrefixList:
        assert(message is List<String>);
        final List<String> result = await imapComponetController.getPathListOrInitByPrefixList(
          initPathList: message as List<String>,
          emailAccount: _emailAccount,
          imapClient: _imapClient,
        );
        channel.send(result);
        break;
      case ImapChannelName.listeningToOperationLog:
        await imapComponetController.listeningToOperationLog(
          channel: channel,
          emailAccount: _emailAccount,
          imapClient: _imapClient,
        );
        break;
    }
  });
}
