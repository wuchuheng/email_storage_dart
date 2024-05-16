import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/address.dart';

import '../../../config/config.dart';

/// Define the mail structure for the IMAP client.

class Mail {
  final String subject;
  final Address from;
  final String body;
  final Map<String, String> headers = {
    'Mime-Version': '1.0',
    'Content-Type': 'text/plain; charset=us-ascii'
  };

  Mail({
    required this.subject,
    required this.from,
    required this.body,
    Map<String, String>? newHeaders,
  }) {
    // 1. Initialize the headers.
    headers['Subject'] = subject;
    headers['From'] = from.format();

    // 1.1 Add the new headers.
    if (newHeaders != null) {
      headers.addAll(newHeaders);
    }
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

  /// Get the size of the mail.
  int size() => fullMail.length;
}
