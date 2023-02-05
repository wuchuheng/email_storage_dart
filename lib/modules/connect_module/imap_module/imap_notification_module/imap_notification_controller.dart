part of 'imap_notification_middleware.dart';

List<void Function()> _onDisconnectResister = [];
List<void Function()> _cancelRegister = [];

Future<void> _notification({required EmailAccount emailAccount}) async {
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

Future<void> _cancel() async {
  Completer<void> completer = Completer();
  _cancelRegister.add(() => completer.complete());
  return completer.future;
}
