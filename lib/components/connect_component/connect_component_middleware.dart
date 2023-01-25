import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import '../../dto/channel_name/channel_name.dart';
import 'connect_component_controller.dart';

/// This file is the interaction file for isolate between main thread and isolate thread.
Future<Task> createConnectMiddleWareMiddleTask() async {
  Task task = await IsolateTask(
    (message, channel) async {
      final ChannelName channelName = enumFromString<ChannelName>(ChannelName.values, channel.name);
      switch (channelName) {
        case ChannelName.connect:
          await connect(
            message: message,
            channel: channel,
          );
          break;
      }
    },
  );

  return task;
}
