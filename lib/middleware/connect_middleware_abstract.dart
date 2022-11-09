import 'package:wuchuheng_email_storage/middleware/email_storage_middleware/email_storage_middleware_abstract.dart';

import '../dto/email_account/email_account.dart';

abstract class ConnectMiddlewareAbstract {
  Future<EmailStorageMiddlewareAbstract> connect(EmailAccount emailAccount);
}
