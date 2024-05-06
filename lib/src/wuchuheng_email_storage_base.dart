// TODO: Put public facing types in this file.

import 'dart:io';

// Validates the email storage configuration in a private function.
void _checkArgument({
  required String imapHost,
  required String username,
  required String password,
  required String folder,
  required String localSavePath,
  required bool tls,
}) {
  // Check if the host, username, password, folder, and local save path are empty.
  imapHost.isEmpty && (throw ArgumentError('Host must not be empty'));
  username.isEmpty && (throw ArgumentError('Username must not be empty'));
  // Check if the username is a valid email address.
  final isEmail =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(username);
  !isEmail && (throw ArgumentError('Username must be a valid email address'));
  password.isEmpty && (throw ArgumentError('Password must not be empty'));
  folder.isEmpty && (throw ArgumentError('Folder must not be empty'));
  localSavePath.isEmpty &&
      (throw ArgumentError('Local save path must not be empty'));
  // Check if the local save path is a valid directory.
  final isDirectory = Directory(localSavePath).existsSync();
  !isDirectory && (throw ArgumentError('Local save path must be a directory'));
}

//
Future<void> EmailStorage({
  tls = true,
  required String host,
  required String username,
  required String password,
  required String folder,
  required String localSavePath,
}) async {
  _checkArgument(
    imapHost: host,
    tls: tls,
    username: username,
    password: password,
    folder: folder,
    localSavePath: localSavePath,
  );
}
