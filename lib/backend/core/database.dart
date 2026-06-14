import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'tables/categories.dart';
import 'tables/block_rules.dart';
import 'tables/block_attempts.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Categories, BlockRules, BlockAttempts])
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 5) {
          try {
            await m.deleteTable('block_rules');
          } catch (_) {}
          try {
            await m.deleteTable('categories');
          } catch (_) {}
          try {
            await m.deleteTable('block_attempts');
          } catch (_) {}
          await m.createAll();
        }
      },
    );
  }
}

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'restructed', 'app_db.sqlite'));

    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }

    // Removed Android workaround as it's not applicable for macOS

    // Make sqlite3 pick a more suitable location for temporary files - the
    // one from the system may be inaccessible due to sandboxing.
    final cachebase = (await getTemporaryDirectory()).path;
    // We can't access /tmp on Android, which sqlite3 would try by default.
    // Explicitly tell it about the correct temporary directory.
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
