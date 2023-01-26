import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import '../../dto/channel_name/channel_name.dart';
import 'connect_component_controller.dart';

/// This file is the interaction file for isolate between main thread and isolate thread.
Future<Task<ChannelName>> createConnectMiddleWareMiddleTask() async {
  Task<ChannelName> task = await IsolateTask<ChannelName>(
    (message, channel) async {
      switch (channel.name) {
        case ChannelName.connect:
          await connect(
            message: message,
            channel: channel,
          );
          break;
        case ChannelName.setIsLogEnabled:
          assert(message is bool);
          isLogEnabled = message as bool;
          channel.send('');
          break;
      }
    },
  );

  return task;
}
