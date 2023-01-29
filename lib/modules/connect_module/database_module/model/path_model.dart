import 'package:drift/drift.dart';
import 'package:wuchuheng_email_storage/modules/connect_module/database_module/database.dart';

class Path extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();
  // The name of path.
  TextColumn get name => text().unique().withLength(min: 1)();
  IntColumn get pid => integer().nullable().withDefault(const Constant(0))();
  // The uid is last updated from online.
  IntColumn get lastSyncUid => integer().nullable().withDefault(const Constant(0))();

  // Check the list of path or create that.
  static Future<void> checkPathListOrCreate({
    required AppDb database,
    required List<String> pathList,
    int pid = 0,
  }) async {
    for (String path in pathList) {
      final PathData? row = await (database.select(database.path)
            ..where((t) => t.name.equals(path))
            ..where((t) => t.pid.equals(pid)))
          .getSingleOrNull();
      if (row == null) {
        await database.into(database.path).insert(PathData(name: path, pid: pid));
      }
    }
  }
}
