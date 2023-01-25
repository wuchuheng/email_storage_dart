part of 'imap_component.dart';

bool isLogEnabled = true;

Future<Task> _createMiddleware() {
  return IsolateTask((message, channel) async {
    final ChannelName channelName = enumFromString<ChannelName>(ChannelName.values, channel.name);
    switch (channelName) {
      case ChannelName.connect:
        assert(message is EmailAccount);
        imapClient = await imapComponetController.connect(
          emailAccount: message,
          channel: channel,
          isLogEnabled: isLogEnabled,
        );
        break;
      case ChannelName.isBoxExisted:
        assert(message is String);
        await imapComponetController.isBoxExisted(boxName: message, channel: channel);
        break;
      case ChannelName.setIsLogEnabled:
        assert(message is bool);
        isLogEnabled = message;
        channel.send('');
        break;
    }
  });
}
