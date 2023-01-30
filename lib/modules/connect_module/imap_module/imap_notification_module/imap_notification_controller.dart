import 'dart:math';

int num = 0;
Future<void> onNotification() async {
  num++;
  final int randomNum = Random().nextInt(10);
  await Future.delayed(Duration(seconds: randomNum), () {
    print('call #$num timeout: $randomNum ');
  });
}
