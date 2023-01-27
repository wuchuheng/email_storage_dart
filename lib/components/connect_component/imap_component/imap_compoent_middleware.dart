part of 'imap_component.dart';

late ImapClient imapClient;

Future<Task<ImapChannelName>> _createMiddleware() {
  return IsolateTask<ImapChannelName>((message, channel) async {
    switch (channel.name) {
      case ImapChannelName.connect:
        assert(message is EmailAccount);
        imapClient = await imapComponetController.connect(
          emailAccount: message,
          channel: channel,
        );
        break;
      case ImapChannelName.setIsLogEnabled:
        assert(message is bool);
        imapComponetController.isLogEnabled = message;
        channel.send('');
        break;
      case ImapChannelName.checkPathExistedOrCreate:
        assert(message is String);
        await imapComponetController.checkPathExistedOrCreate(path: message as String, channel: channel);
        break;
    }
  });
}
