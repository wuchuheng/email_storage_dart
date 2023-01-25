import 'package:test/test.dart';
import 'package:wuchuheng_email_storage/utils/convert_path_util.dart';

void main() {
  test('Convert email path to path and convert back testing', () async {
    String path = '/aa/bb/cc';
    String emailPath = convertPathToEmailPath(path);
    expect(emailPath, '_aa_bb_cc');
    String path2 = convertEmailPathToPath(emailPath);
    expect(path2, path);
  });
}
