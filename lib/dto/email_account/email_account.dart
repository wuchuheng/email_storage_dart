import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class EmailAccount {
  final String password;
  final String userName;
  final String imapHost;
  final int imapPort;
  final bool imapTls;
  final String smtpHost;
  final int smtpPort;
  final bool smtpTls;
  final String storageName;
  final String localStoragePath;

  EmailAccount({
    required this.imapHost,
    required this.smtpHost,
    required this.password,
    required this.userName,
    required this.storageName,
    required this.localStoragePath,
    this.smtpPort = 465,
    this.imapPort = 993,
    this.imapTls = true,
    this.smtpTls = true,
  }) {
    assert(userName.isNotEmpty);
    assert(imapHost.isNotEmpty);
    assert(smtpHost.isNotEmpty);
    assert(smtpPort > 0 && smtpPort < 65535);
  }
}
