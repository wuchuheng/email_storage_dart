import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/commands/command_abstract.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/command.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/request/request.dart';
import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/response/response.dart';

import '../dto/response/message.dart';
import '../imap_client.dart';

class UidStore implements CommandAbstract<List<Message>> {
  final OnImapWriteType onWrite;
  final int startUid;
  final String endUid;
  final List<String> dataItems;

  UidStore({
    required this.onWrite,
    required this.startUid,
    required this.endUid,
    required this.dataItems,
  }) {
    // 1. Check the properties.
    // 1.1 Check the `startUid` property.
    if (endUid.isNotEmpty && endUid != '*') {
      final endUidInt = int.tryParse(endUid);
      if (endUidInt == null) {
        throw Exception('The `endUid` property must be an integer or `*`.');
      }
      if (endUidInt <= startUid) {
        throw Exception(
          'The `endUid` property must be greater than the `startUid` property.',
        );
      }
    }
  }
  @override
  Future<Response<List<Message>>> execute() async {
    // 1. Create a request for the `UID STORE` command.
    // 1.1 Define the sequence set of the UIDs.
    final uids = endUid.isEmpty ? startUid.toString() : '$startUid:$endUid';

    // 1.2 Create rquest
    final request = Request(command: Command.UID, arguments: [
      'store',
      uids,
      dataItems.join(' '),
    ]);

    // 2. Write the request to the IMAP server.
    final Response res = await onWrite(request: request);

    // 3. Parse the response from the IMAP server.
    final List<Message> messages = _parseResponse(res.data);

    // 4. Return the response.
    return Response(
      data: messages,
      tag: res.tag,
      status: res.status,
      message: res.message,
    );
  }

  /// Parses the response from the IMAP server.
  ///
  /// Returns a list of messages parsed from the response.
  /// [data] is the response to parse.
  List<Message> _parseResponse(List<String> data) {
    // 1. Convert the list of strings from the response of IMAP server to a list of messages.
    // the data like:
    // ```
    //8 FETCH (UID 121 FLAGS (\Deleted \Seen))
    // 9 FETCH (UID 121 FLAGS (\Deleted \Seen))
    // ```
    final List<Message> messages = [];
    for (String line in data) {
      // 1.1 Extract the sequence number and the message.
      final sequenceNumber = int.parse(line.split(' ')[0]);
      final Message message = Message(
        sequenceNumber: sequenceNumber,
        dataItemMapResult: {},
      );

      // 1.2 Extract the data items from the message.
      // 1.2.1 Extract the data items from the message, like:
      // Example: `8 FETCH (UID 121 FLAGS (\Deleted \Seen))` to `UID 121 FLAGS (\Deleted \Seen)`
      // By rexgex, we can extract the data items from the message.
      final exp = RegExp(r'\d+ FETCH \((.+)\)$');
      final match = exp.firstMatch(line);
      // dataItems is like `UID 121 FLAGS (\Deleted \Seen)`
      String dataItems = match?.group(1) ?? '';

      // 1.2.2 If the UID is in the data items, extract the pare of the UID and the value.
      // By regex, we can extract the UID and the value from the data items.
      final uidExp = RegExp(r'UID (\d+)');
      if (uidExp.hasMatch(dataItems)) {
        // 1.2.2.1 Extract the UID from the data items.
        final uidMatch = uidExp.firstMatch(dataItems);
        final uid = uidMatch?.group(1) ?? '';
        message.dataItemMapResult['UID'] = uid;
        // 1.2.2.2 Remove the pare of the UID and the value from the data items.
        dataItems = dataItems.replaceAll(uidExp, '');
      }

      // 1.2.3 If the FLAGS is in the data items, extract the pare of the FLAGS and the value.
      // By regex, we can extract the FLAGS and the value from the data items.
      final flagsExp = RegExp(r'FLAGS (\(.*\))');
      if (flagsExp.hasMatch(dataItems)) {
        // 1.2.3.1 Extract the FLAGS from the data items.
        final flagsMatch = flagsExp.firstMatch(dataItems);
        final flags = flagsMatch?.group(1) ?? '';
        message.dataItemMapResult['FLAGS'] = flags;

        // 1.2.3.2 Remove the pare of the FLAGS and the value from the data items.
        dataItems = dataItems.replaceAll(flagsExp, '');
      }

      messages.add(message);
    }

    // 2. Return the list of messages.
    return messages;
  }
}
