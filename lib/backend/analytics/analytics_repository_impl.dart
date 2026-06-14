import 'package:drift/drift.dart';
import 'package:restructed/backend/analytics/block_attempt.dart' as entity;
import 'package:restructed/backend/analytics/analytics_repository.dart';
import 'package:restructed/backend/core/database.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AppDatabase db;

  AnalyticsRepositoryImpl(this.db);

  entity.BlockAttempt mapToEntity(BlockAttempt driftAttempt) {
    return entity.BlockAttempt(
      id: driftAttempt.id,
      domain: driftAttempt.domain,
      attemptedAt: DateTime.fromMillisecondsSinceEpoch(
        driftAttempt.attemptedAt,
      ),
    );
  }

  @override
  Future<void> logAttempt(String domain) async {
    await db
        .into(db.blockAttempts)
        .insert(
          BlockAttemptsCompanion(
            domain: Value(domain),
            attemptedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  @override
  Future<List<entity.BlockAttempt>> getAttemptsForDomain(String domain) async {
    final attempts = await (db.select(
      db.blockAttempts,
    )..where((a) => a.domain.equals(domain))).get();
    return attempts.map(mapToEntity).toList();
  }

  @override
  Future<List<entity.BlockAttempt>> getAllAttempts() async {
    final attempts =
        await (db.select(db.blockAttempts)..orderBy([
              (t) => OrderingTerm(
                expression: t.attemptedAt,
                mode: OrderingMode.desc,
              ),
            ]))
            .get();
    return attempts.map(mapToEntity).toList();
  }

  @override
  Stream<List<entity.BlockAttempt>> watchAllAttempts() {
    return (db.select(db.blockAttempts)..orderBy([
          (t) =>
              OrderingTerm(expression: t.attemptedAt, mode: OrderingMode.desc),
        ]))
        .watch()
        .map((rows) => rows.map(mapToEntity).toList());
  }

  @override
  Future<void> clearOldAttempts(DateTime before) async {
    await (db.delete(db.blockAttempts)..where(
          (a) =>
              a.attemptedAt.isSmallerThanValue(before.millisecondsSinceEpoch),
        ))
        .go();
  }
}
