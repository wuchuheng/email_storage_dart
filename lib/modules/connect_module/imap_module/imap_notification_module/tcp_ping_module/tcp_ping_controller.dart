part of 'tcp_ping_middleware.dart';

Future<void> _tcpPing(TcpPingParameter value) async {
  final host = value.emailAccount.imapHost;
  final port = value.emailAccount.imapPort;
  final Socket socket = await SecureSocket.connect(
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
    print('Disconnect');
    timer?.cancel();
    socket.close();
  });
}
