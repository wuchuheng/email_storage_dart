import 'dart:async';

import 'package:test/scaffolding.dart';
import 'package:wuchuheng_email_storage/dto/email_account/email_account.dart';
import 'package:wuchuheng_email_storage/modules/connect_module/imap_module/imap_notification_module/imap_notification_module.dart';
import 'package:wuchuheng_hooks/wuchuheng_hooks.dart';

import 'config/get_email_account.dart';

void main() {
  late EmailAccount emailAccount;
  setUp(() {
    emailAccount = getEmailAccount();
  });
  test('onNotification', () async {
    print(DateTime.now());
    await onNotification(emailAccount: emailAccount);
    await Future.delayed(Duration(seconds: 2000));
  });
  test('Test for sync* yield*', () {
    Iterable<String> getEmojiWithTime(int count) sync* {
      Iterable<String> getItems() sync* {
        yield 'hello';
        yield 'world';
      }

      yield* getItems();
      yield '!';
    }

    getEmojiWithTime(1).forEach((element) {
      print(element);
    });
  });
  test('Multiple async test', () async {
    Future<String> getWord() async => 'Hello world!';

    Stream<String> getStream() async* {
      final ChannelHook<String> channelHook = ChannelHook<String>();
      int num = 0;
      Timer.periodic(Duration(seconds: 1), (timer) {
        channelHook.push((++num).toString());
      });
      Stream<String> list = Stream.empty();
      await for (var i in list) {}

      while (true) {
        yield await channelHook.value;
      }
    }

    final s = Stream<String>.empty();

    getStream().listen((event) {
      print(event);
    });

    await Future.delayed(const Duration(seconds: 1000));
  });
  test('Basic usage', () async {
    final StreamController<String> strStreamController = StreamController<String>();
    strStreamController.stream.listen((event) {
      // <-- 接收元素
      print(event); // hello
    });
    strStreamController.add('hello'); // <-- 添加元素进去
    await Future.delayed(Duration(seconds: 20));
  });
  test('onCancel event in dart stream', () async {
    // step 1 创建流
    final StreamController<String> strStreamController = StreamController<String>(
      onCancel: () {
        // step 1.1 : 监听取消事件
        print('onCancel'); //  step 4.1 关闭到触发取消事件
      },
    );
    // step 2: 监听流中的元素
    final StreamSubscription<String> subscription = strStreamController.stream.listen((event) {
      print(event); // e1
    });
    // step 3: 添加元素到流中
    strStreamController.add('e1');
    await Future.delayed(Duration(seconds: 1));
    // step 4: 取消流
    subscription.cancel();
    strStreamController.add('a2'); // step 5: 无法添加元素进流了，因为流已经取消了

    await Future.delayed(Duration(seconds: 20));
  });
  test('onListen event in dart stream', () async {
    // step 1 创建流
    final StreamController<String> strStreamController = StreamController<String>(
      onListen: () {
        // step 1.1 : 当注册监听事件时，则触发这个回调
        print('onListen');
      },
    );
    // step 2: 注册监听事件，然后触发 step 1.1 的回调事件
    strStreamController.stream.listen((event) {
      print(event); // e1
    });
    // step 3: 添加元素到流中
    strStreamController.add('e1');

    await Future.delayed(Duration(seconds: 20));
  });
  test('onPause event in dart stream ', () async {
    // step 1: 创建流
    final StreamController<String> strStreamController = StreamController<String>(
      onPause: () {
        // step 4.1 触发中断事件
        print('onPause');
      },
    );
    // step 2: 监听流
    StreamSubscription subscription = strStreamController.stream.listen((event) {
      print(event); // e1 e2  step 5.1: 最终还是能接收到元素，并没有实现停止的作用
    });

    // step 3: 发送元素到流中
    strStreamController.add('e1');
    await Future.delayed(Duration(seconds: 1));
    // step 4: 停止流
    subscription.pause();
    // step 5: 再发送元素到流中
    strStreamController.add('e2');
    await Future.delayed(Duration(seconds: 10));
  });
  test('onResume event in dart stream', () async {
    // step 1: 创建流
    final StreamController<String> strStreamController = StreamController<String>(
      // step 5.1 触发停止事件
      onPause: () {
        print('onPause');
      },
      // step: 5.4: 触发播放事件
      onResume: () {
        print('onResume');
      },
    );
    // step 2: 监听流
    final StreamSubscription<String> subscription = strStreamController.stream.listen((event) {
      print(event);
      // step 3.1: 输出 e1
      // step 5.5: 输出 e2
    });
    // step 3: 添加元素
    strStreamController.add('e1');
    // step 4: 等1s
    await Future.delayed(Duration(seconds: 1));
    // step 5: 停止流
    subscription.pause();
    // step 5.2: 停止后再添加元素
    strStreamController.add('e2');
    // step 5.3: 然后再播放流
    subscription.resume();
    await Future.delayed(Duration(seconds: 20));
  });
  test('Where method in dart stream', () async {
    // step 1: 声明流
    final StreamController<String> strStreamController = StreamController<String>();

    strStreamController.stream.where((event) {
      // step 2: 只过滤字符大于3个的字符串
      return event.length > 3;
    }).listen((event) {
      // step 3: 监听流数据
      print(event); // step 5: 1234   <-- 经过上where的过虑，现在已经只剩下1234到达这里了
    });

    // step 4: 发送数据到流中
    strStreamController.add('1');
    strStreamController.add('12');
    strStreamController.add('123');
    strStreamController.add('1234');
    await Future.delayed(Duration(seconds: 20));
  });
  test('How to declare stream', () async {
    // Method 1.1: 通过数列方式去声明
    final Stream<String> streamStrList = Stream.fromIterable(['Mars', 'Venus', 'Earth']);
    streamStrList.listen(print); // ['Mars', 'Venus', 'Earth']
    // Method 1.2: 通过Future去声明
    final Stream<String> fromFutureStream = Stream.fromFuture(Future.value('Hello'));
    fromFutureStream.listen(print); // Hello
    // Method 1.3: 通过Futures去声明
    final Stream<String> fromFuturesStream = Stream.fromFutures([Future.value('foo'), Future.value('bar')]);
    fromFuturesStream.listen(print); // foo bar
    // Method 2: 通过StreamController去声明
    final StreamController<String> streamController = StreamController<String>();
    streamController.add('hello');
    streamController.stream.listen(print); // hello
  });
  test("Join method in dart stream", () async {
    // step 1: 声明流
    final StreamController<String> strStreamController = StreamController<String>();
    // step 2: 给流添加拼接(join)的处理环节
    strStreamController.add('foo');
    strStreamController.add('baa');
    await Future.delayed(Duration(seconds: 1));
    strStreamController.close();
    String result = await strStreamController.stream.join('/');
    print(result); //
    await Future.delayed(Duration(seconds: 20));
  });
  test('Take method in dart stream', () async {
    final StreamController<String> streamController = StreamController<String>();
    streamController.add('e1');
    streamController.add('e2');
    streamController.add('e3');
    // 获取2个元素
    streamController.stream.take(2).listen(print); // [e1, e2]
  });
  test('TakeWhile method in dart stream', () async {
    // Step 1: 声明流
    final StreamController<String> streamController = StreamController<String>();
    streamController.add('e1');
    streamController.add('e2');
    streamController.add('e3');
    // Step 2: 只获取元素到 e2, 后面的元素不再获取
    streamController.stream.takeWhile((e) => e != 'e3').listen(print); // e1 e2
  });
  test('Contains method in dart Stream', () async {
    // Step 1: 声明流
    final StreamController streamController = StreamController<String>();
    streamController.add('e1');
    streamController.add('e2');
    streamController.add('e3');
    // Step 2: 检测元素中有没有 e2 元素
    bool result = await streamController.stream.contains('e2');
    print(result); // true
  });
  test('any method in dart stream', () async {
    // Step 1: 声明流
    final StreamController<String> streamController = StreamController<String>();
    streamController.add('e1');
    streamController.add('e2');
    streamController.add('e3');
    // Step 2: 懒加载遍历,并找出 e2 元素
    final bool result = await streamController.stream.any((element) {
      return element == 'e2';
    });
    print(result);
  });
  test('drain method in dart stream', () async {});
}
