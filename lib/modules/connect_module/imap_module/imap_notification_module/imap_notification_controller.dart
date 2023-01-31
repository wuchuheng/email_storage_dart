part of 'imap_notification_middleware.dart';

Future<void> _onNotification({required EmailAccount emailAccount}) async {
  var socket = await Socket.connect("baidu.com", 80);
  socket.listen((event) {
    print(event);
  });
  //根据http协议，发起 Get请求头
  socket.writeln("GET / HTTP/1.1");
  socket.writeln("Host:baidu.com");
  socket.writeln("Connection:close");
  socket.writeln();
  await socket.flush(); //发送
  //读取返回内容，按照utf8解码为字符串

  // String _response = await utf8.decoder.bind(socket).join();
  await socket.close();

  //
  // final connectHandler = await SecureSocket.connect(
  //   emailAccount.imapHost,
  //   emailAccount.imapPort,
  //   onBadCertificate: (X509Certificate certificate) {
  //     print(certificate);
  //     return true;
  //   },
  // ).timeout(Duration(seconds: connectTimeout));
  // connectHandler.listen(
  //   (Uint8List data) async {
  //     print(data);
  //     final serverGreeting = String.fromCharCodes(data);
  //     print(data);
  //   },
  //   onError: () {
  //     print('error');
  //   },
  //   onDone: () {
  //     print('done');
  //   },
  // );
  await Future.delayed(Duration(seconds: 60));
}
