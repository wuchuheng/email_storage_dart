part of 'tcp_ping_middleware.dart';

late Socket socket;
List<void Function()> _socketDoneEventRegister = [];

List<void Function()> _onDisconnectEventRegister = [];
Future<void> _tcpPing(TcpPingParameter value) async {
  final host = value.emailAccount.imapHost;
  final port = value.emailAccount.imapPort;
  socket = await SecureSocket.connect(
    host,
    port,
    timeout: Duration(
      seconds: value.emailAccount.timeout,
    ),
  );
  Timer? timer;
  socket.listen((Uint8List data) {
    timer ??= Timer.periodic(
      Duration(seconds: 5),
      (timer) {
        socket.write(
          '1.2256 ID ("name" "Mac OS X Mail" "version" "16.0 (3696.100.31)" "os" "Mac OS X" "os-version" "12.4 (21F79)" "vendor" "Apple Inc.") \r\n',
        );
        socket.flush();
      },
    );
  }, onDone: () {
    timer?.cancel();
    socket.close();
    for (final callback in _onDisconnectEventRegister) {
      callback();
    }
    _onDisconnectEventRegister.clear();
    for (var callback in _socketDoneEventRegister) {
      callback();
    }
    _socketDoneEventRegister.clear();
  });
}

_onDisconnect(void Function() callback) => _onDisconnectEventRegister.add(callback);

Future<void> _cancel() {
  Completer<void> completer = Completer();
  _socketDoneEventRegister.add(() {
    completer.complete();
  });
  socket.close();
  return completer.future;
}
