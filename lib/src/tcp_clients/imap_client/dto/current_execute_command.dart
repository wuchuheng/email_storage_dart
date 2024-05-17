import 'dart:async';

import 'package:wuchuheng_email_storage/src/tcp_clients/imap_client/dto/request.dart';

class CurrentExecuteCommand {
  final Request request;
  final Completer<List<String>> completer;
  final Timer timer;

  CurrentExecuteCommand({
    required this.request,
    required this.completer,
    required this.timer,
  });
}
