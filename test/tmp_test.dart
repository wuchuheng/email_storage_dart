import 'package:test/test.dart';

//       final mail = """
// Mime-Version: 1.0
// From: Fred Foobar <chuheng.wu@icloud.com>
// Content-Type: text/plain; charset=us-ascii
//
// 54321
// """;
//       final l = mail.length + mail.split('\n').length - 1;
//       print(l);

void main() {
  group('Imap4CapabilityCheckerAbstract', () {
    // test('checkConnection', () async {
    //   // Date: Thu, 16 May 2024 18:03:13.775898 +0800
    //   final dayInWeek = [
    //     'Sun',
    //     'Mon',
    //     'Tue',
    //     'Wed',
    //     'Thu',
    //     'Fri',
    //     'Sat',
    //   ][DateTime.now().weekday];
    //   final month = [
    //     'Jan',
    //     'Feb',
    //     'Mar',
    //     'Apr',
    //     'May',
    //     'Jun',
    //     'Jul',
    //     'Aug',
    //     'Sep',
    //     'Oct',
    //     'Nov',
    //     'Dec',
    //   ][DateTime.now().month - 1];
    //   // Get the time zone like: +0800
    //   String timeZone =
    //       '${DateTime.now().timeZoneOffset.inHours.toString().padLeft(2, '0')}00';
    //   // Add the '+' sign or the '-' sign.
    //   timeZone = DateTime.now().timeZoneOffset.isNegative
    //       ? '-$timeZone'
    //       : '+$timeZone';
    //   final year = DateTime.now().year.toString();
    //   final nowTime = DateTime.now().toString().split(' ')[1];

    //   final date =
    //       '$dayInWeek, ${DateTime.now().day} $month $year $nowTime $timeZone';
    //   print(date);
    // });

    test("Test", () {
      final str = "L1 OK user chuheng.wu logged in";
      final subStr = str.substring(0);
      print(subStr);
    });
  });
}
