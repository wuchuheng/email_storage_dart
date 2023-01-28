import 'package:test/test.dart';
import 'package:wuchuheng_email_storage/utils/convert_path_util.dart';

void main() {
  test('Convert email path to path and convert back testing', () async {
    String path = '/aa/bb/cc';
    String prefix = 'prefix';
    String emailPath = convertPathToEmailPath(path: path, prefix: prefix);
    expect(emailPath, '${prefix}_aa_bb_cc');
    String path2 = convertEmailPathToPath(path: emailPath, prefix: prefix);
    expect(path2, path);
  });
}
