import 'package:drift/drift.dart';

class Path extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();
  TextColumn get name => text().withLength(min: 1)();
  IntColumn get pid => integer().nullable().withDefault(const Constant(0))();
}
