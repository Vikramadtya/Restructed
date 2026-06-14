import 'package:drift/drift.dart';
import 'categories.dart';

class BlockRules extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get domain => text()();
  IntColumn get blockDurationSeconds => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get lastActivatedAt => integer().nullable()();
  BoolColumn get isStrictMode => boolean().withDefault(const Constant(false))();
  BoolColumn get isAppRule => boolean().withDefault(const Constant(false))();
  TextColumn get scheduledDays => text().nullable()(); // JSON string
  TextColumn get startTime => text().nullable()(); // HH:MM
  TextColumn get endTime => text().nullable()(); // HH:MM
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}
