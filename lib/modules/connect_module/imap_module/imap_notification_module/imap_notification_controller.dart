part of 'imap_notification_middleware.dart';

Future<void> _onNotification({required EmailAccount emailAccount}) async {
  await tcpPing(TcpPingParameter(emailAccount: emailAccount));
}
