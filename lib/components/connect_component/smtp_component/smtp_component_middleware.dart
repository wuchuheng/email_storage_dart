part of "smtp_component.dart";

enum ChannelName { connect, setIsLogEnabled }

Future<Task<ChannelName>> createMiddleware() async {
  final Task<ChannelName> task = await IsolateTask<ChannelName>((message, channel) async {
    switch (channel.name) {
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
