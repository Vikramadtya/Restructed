import 'package:drift/drift.dart';

class BlockAttempts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get domain => text()();
  IntColumn get attemptedAt => integer()(); // milliseconds since epoch
}
