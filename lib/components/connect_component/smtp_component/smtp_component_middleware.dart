part of "smtp_component.dart";

enum ChannelName { connect }

Future<Task> createMiddleware() async {
  final Task task = await IsolateTask((message, channel) async {
    ChannelName channelName = enumFromString<ChannelName>(ChannelName.values, channel.name);
    switch (channelName) {
      case ChannelName.connect:
        assert(message is EmailAccount);
        await smtpComponentController.connect(emailAccount: message, channel: channel);
        break;
    }
  });

  return task;
}
