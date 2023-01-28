import 'dart:io';

import 'package:drift/drift.dart';
// These imports are used to open the database
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import 'model/path_model.dart';

part 'database.g.dart';

@DriftDatabase(
  include: {'tables.drift'},
  tables: [Path],
)
class AppDb extends _$AppDb {
  AppDb({required String dbSavedPath}) : super(_openConnection(dbSavedPath: dbSavedPath));

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection({required String dbSavedPath}) {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final file = File(p.join(dbSavedPath, 'db.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
