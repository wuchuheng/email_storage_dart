part of 'imap_notification_middleware.dart';

Map<int, String> conversationToIdle = {
  // server say:  * OK [CAPABILITY IMAP4 IMAP4rev1 ID AUTH=PLAIN AUTH=LOGIN AUTH=XOAUTH2 NAMESPACE] QQMail XMIMAP4Server ready
  0: '1.3 ID ("name" "Mac OS X Mail" "version" "16.0 (3696.80.82.1.1)" "os" "Mac OS X" "os-version" "12.3 (21E230)" "vendor" "Apple Inc.")',
  // server sya: * ID NIL
  // 1: '',
  // server say: 1.3 OK ID completed
  1: '2.3 AUTHENTICATE PLAIN',
  // server say: +
  2: "MjM5OTQxMjc2NkBxcS5jb20AMjM5OTQxMjc2NkBxcS5jb20AZ3lpbmFxc2lneHp0ZWNkZQa==",
  // server say: 2.3 OK Success login ok
  3: "3.3 CAPABILITY",
  // server say: * CAPABILITY IMAP4 IMAP4rev1 XLIST MOVE IDLE XAPPLEPUSHSERVICE NAMESPACE CHILDREN ID UIDPLUS
  // 4: '',
  // server say: 3.3 OK CAPABILITY Completed
  4: '4.3 SELECT INBOX',
  5: '13.1 IDLE',
};

int sessionVersionInt = 0;
bool isFirstMessage = true;
bool isIdling = false;
Future<void> _onNotification({required EmailAccount emailAccount}) async {
  final Socket socket = await SecureSocket.connect(emailAccount.imapHost, emailAccount.imapPort);
  socket.timeout(Duration(seconds: emailAccount.timeout));
  socket.listen((Uint8List buff) {
    final String result = String.fromCharCodes(buff);
    if (result.substring(0, 1) != '*' || isFirstMessage) {
      isFirstMessage = false;
      if (conversationToIdle.containsKey(sessionVersionInt)) {
        if (conversationToIdle[sessionVersionInt]!.isNotEmpty) {
          socket.write('${conversationToIdle[sessionVersionInt]}\r\n');
          socket.flush();
        }
      }
      sessionVersionInt++;
      return;
    }
    if (isIdling) {
      print(result);
    }
    if (sessionVersionInt > conversationToIdle.length) {
      isIdling = true;
    }
  });

  await Future.delayed(Duration(seconds: emailAccount.timeout));
}
