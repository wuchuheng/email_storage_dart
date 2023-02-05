part of 'imap_notification_middleware.dart';

List<void Function()> _onDisconnectResister = [];

Future<void> _onNotification({required EmailAccount emailAccount}) async {
  await tcpPing(
    TcpPingParameter(
      emailAccount: emailAccount,
      onDisconnect: () {
        for (var callback in _onDisconnectResister) {
          callback();
        }
        _onDisconnectResister.clear();
      },
    ),
  );
}

void _onDisconnect(void Function() callback) => _onDisconnectResister.add(callback);
