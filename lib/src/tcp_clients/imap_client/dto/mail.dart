import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/address.dart';

import '../../../config/config.dart';

/// Define the mail structure for the IMAP client.
class Mail {
  final String subject;
  final Address from;
  final String body;
  late DateTime date;

  final Map<String, String> headers = {
    'Mime-Version': '1.0',
    'Content-Type': 'text/plain; charset=us-ascii'
  };

  Mail({
    required this.subject,
    required this.from,
    required this.body,
    DateTime? date,
    Map<String, String>? newHeaders,
  }) : date = date ?? DateTime.now() {
    // 1. Initialize the headers.
    headers['Subject'] = subject;
    headers['From'] = from.format();
    headers['Date'] = transferDatetime(dateTime: this.date);

    // 1.1 Add the new headers.
    if (newHeaders != null) {
      headers.addAll(newHeaders);
    }
  }

  /// Get the date time in the format of 'Thu, 16 May 2024 18:03:13.775898 +0800' for the mail header.
  /// Transforms a [DateTime] object into a string representation that follows the email date header format.
  ///
  /// The format is: 'Day, DD Month YYYY HH:MM:SS.ssssss ±ZZZZ'
  /// Example: 'Thu, 16 May 2024 18:03:13.775898 +0800'
  ///
  /// The [dateTime] parameter is the [DateTime] object to be transformed.
  ///
  /// Returns a [String] that represents the [dateTime] in the email date header format.
  static String transferDatetime({required DateTime dateTime}) {
    // Date: Thu, 16 May 2024 18:03:13.775898 +0800
    final dayInWeek = [
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
    ][dateTime.weekday % 7];

    final month = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][dateTime.month - 1];
    // Get the time zone like: +0800
    String timeZone =
        '${dateTime.timeZoneOffset.inHours.toString().padLeft(2, '0')}00';
    // Add the '+' sign or the '-' sign.
    timeZone = dateTime.timeZoneOffset.isNegative ? '-$timeZone' : '+$timeZone';
    final year = dateTime.year.toString();
    final nowTime = dateTime.toString().split(' ')[1];

    final result =
        '$dayInWeek, ${dateTime.day} $month $year $nowTime $timeZone';

    return result;
  }

  /// Get the full mail in the string format.
  String get fullMail {
    final StringBuffer buffer = StringBuffer();
    headers.forEach((key, value) {
      buffer.write('$key: $value$EOF');
    });
    buffer.write(EOF);
    buffer.write(body);
    return buffer.toString();
  }

  @override
  toString() => fullMail;

  /// Get the size of the mail.
  int size() => fullMail.length;

  static String wrapLines(String input, {int lineLength = 78}) {
    final buffer = StringBuffer();
    int start = 0;

    while (start < input.length) {
      int end = start + lineLength;
      if (end >= input.length) {
        buffer.write(input.substring(start));
        break;
      }

      // Find a suitable breakpoint
      int breakpoint = input.lastIndexOf(' ', end);
      if (breakpoint <= start) {
        // If no breakpoint found, force a break
        breakpoint = end;
      }

      buffer.writeln(input.substring(start, breakpoint).trim());
      start = breakpoint + 1; // Skip the space or go to the next segment
    }

    return buffer.toString();
  }
}
