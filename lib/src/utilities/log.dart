enum LogLevel {
  DEBUG, // ignore: constant_identifier_names

  /// Log level for tcp messages.
  TCP_COMING, // ignore: constant_identifier_names
  TCP_GOING, // ignore: constant_identifier_names

  /// Log level for info messages.
  INFO, // ignore: constant_identifier_names
  ERROR, // ignore: constant_identifier_names
}

/// Log a message with the [level] of severity.
/// The log format like the flowing:
/// 2023-04-05 13:45:37 [INFO] main.py:42 - User 'john_doe' logged in successfully.
void log(String message, {LogLevel level = LogLevel.INFO}) {
  final now = DateTime.now();
  final formattedDate =
      '${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}';
  final logLevel = level.toString().split('.').last.toUpperCase();
  print('$formattedDate [$logLevel] $message');
}
