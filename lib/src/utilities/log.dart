enum LogLevel {
  /// Log level for debug messages
  debug,

  /// Log level for tcp messages.
  tcp,

  /// Log level for info messages.
  info,

  /// Log level for warning messages.
  warning,

  /// Log level for error messages.
  error,
}

/// Log a message with the [level] of severity.
/// The log format like the flowing:
/// 2023-04-05 13:45:37 [INFO] main.py:42 - User 'john_doe' logged in successfully.
void log(String message, {LogLevel level = LogLevel.info}) {
  final now = DateTime.now();
  final formattedDate =
      '${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}';
  final logLevel = level.toString().split('.').last.toUpperCase();
  print('$formattedDate [$logLevel] : - $message');
}
