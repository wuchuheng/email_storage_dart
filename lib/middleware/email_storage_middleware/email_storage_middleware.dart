import 'package:wuchuheng_isolate_channel/src/service/task/index.dart';

import 'email_storage_middleware_abstract.dart';

/// The instance of storage that include all method for storage.
class EmailStoreMiddleWare implements EmailStorageMiddlewareAbstract {
  final Task task;
  EmailStoreMiddleWare({required this.task});
}
