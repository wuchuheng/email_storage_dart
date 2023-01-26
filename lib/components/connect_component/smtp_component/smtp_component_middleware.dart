part of "smtp_component.dart";

enum ChannelName { connect, setIsLogEnabled }

Future<Task> createMiddleware() async {
  final Task task = await IsolateTask((message, channel) async {
    ChannelName channelName = enumFromString<ChannelName>(ChannelName.values, channel.name);
    switch (channelName) {
      case ChannelName.connect:
        assert(message is EmailAccount);
        await smtpComponentController.connect(emailAccount: message, channel: channel);
        break;
      case ChannelName.setIsLogEnabled:
        assert(message is bool);
        smtpComponentController.isLogEnabled = message as bool;
        channel.send('');
        break;
    }
  });

  return task;
}
