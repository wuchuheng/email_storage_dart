import 'package:test/test.dart';
import 'package:wuchuheng_email_storage/src/config/config.dart';

//       final mail = """
// Mime-Version: 1.0
// From: Fred Foobar <chuheng.wu@icloud.com>
// Content-Type: text/plain; charset=us-ascii
//
// 54321
// """;
//       final l = mail.length + mail.split('\n').length - 1;
//       print(l);

final str =
    """Mime-Version: 1.0${EOF}Content-Type: text/plain; charset=us-ascii${EOF}Subject: Test mail${EOF}From: chuheng.wu@icloud.com${EOF}This is a test mail1.""";
void main() {
  group('Imap4CapabilityCheckerAbstract', () {
    test('checkConnection', () async {
      final len = str.length;
      print(len);
    });
  });
}
