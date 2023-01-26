part of 'imap_component.dart';

Future<Task<ChannelName>> _createMiddleware() {
  return IsolateTask<ChannelName>((message, channel) async {
    switch (channel.name) {
      case ChannelName.connect:
        assert(message is EmailAccount);
        imapClient = await imapComponetController.connect(
          emailAccount: message,
          channel: channel,
        );
        break;
      case ChannelName.isBoxExisted:
        assert(message is String);
        await imapComponetController.isBoxExisted(boxName: message, channel: channel);
        break;
      case ChannelName.setIsLogEnabled:
        assert(message is bool);
        imapComponetController.isLogEnabled = message;
        channel.send('');
        break;
      case ChannelName.createBoxName:
        assert(message is String);
        await imapComponetController.createBoxName(boxName: message, channel: channel);
        break;
    }
  });
}
