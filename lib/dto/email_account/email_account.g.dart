// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmailAccount _$EmailAccountFromJson(Map<String, dynamic> json) => EmailAccount(
      imapHost: json['imapHost'] as String,
      smtpHost: json['smtpHost'] as String,
      password: json['password'] as String,
      userName: json['userName'] as String,
      smtpPort: json['smtpPort'] as int? ?? 465,
      imapPort: json['imapPort'] as int? ?? 995,
      imapTls: json['imapTls'] as bool? ?? true,
      smtpTls: json['smtpTls'] as bool? ?? true,
    );

Map<String, dynamic> _$EmailAccountToJson(EmailAccount instance) =>
    <String, dynamic>{
      'password': instance.password,
      'userName': instance.userName,
      'imapHost': instance.imapHost,
      'imapPort': instance.imapPort,
      'imapTls': instance.imapTls,
      'smtpHost': instance.smtpHost,
      'smtpPort': instance.smtpPort,
      'smtpTls': instance.smtpTls,
    };
