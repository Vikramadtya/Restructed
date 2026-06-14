import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:restructed/backend/rules/block_rule.dart' as entity;
import 'package:restructed/backend/rules/rule_repository.dart';
import 'package:restructed/backend/core/database.dart';

class RuleRepositoryImpl implements RuleRepository {
  final AppDatabase db;

  RuleRepositoryImpl(this.db);

  entity.BlockRule mapToEntity(BlockRule driftRule) {
    List<int>? parsedDays;
    if (driftRule.scheduledDays != null) {
      try {
        parsedDays = List<int>.from(
          jsonDecode(driftRule.scheduledDays!) as Iterable,
        );
      } catch (_) {}
    }

    return entity.BlockRule(
      id: driftRule.id,
      categoryId: driftRule.categoryId,
      domain: driftRule.domain,
      blockDuration: Duration(seconds: driftRule.blockDurationSeconds),
      isActive: driftRule.isActive,
      lastActivatedAt: driftRule.lastActivatedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(driftRule.lastActivatedAt!)
          : null,
      isStrictMode: driftRule.isStrictMode,
      isAppRule: driftRule.isAppRule,
      scheduledDays: parsedDays,
      startTime: driftRule.startTime,
      endTime: driftRule.endTime,
      syncStatus: driftRule.syncStatus,
    );
  }

  BlockRulesCompanion mapToCompanion(entity.BlockRule rule) {
    return BlockRulesCompanion(
      id: Value(rule.id),
      categoryId: Value(rule.categoryId),
      domain: Value(rule.domain),
      blockDurationSeconds: Value(rule.blockDuration.inSeconds),
      isActive: Value(rule.isActive),
      lastActivatedAt: Value(rule.lastActivatedAt?.millisecondsSinceEpoch),
      isStrictMode: Value(rule.isStrictMode),
      isAppRule: Value(rule.isAppRule),
      scheduledDays: Value(
        rule.scheduledDays != null ? jsonEncode(rule.scheduledDays) : null,
      ),
      startTime: Value(rule.startTime),
      endTime: Value(rule.endTime),
      syncStatus: Value(rule.syncStatus),
    );
  }

  @override
  Future<void> createRule(entity.BlockRule rule) async {
    await db.into(db.blockRules).insert(mapToCompanion(rule));
  }

  @override
  Future<void> deleteRule(String id) async {
    await (db.delete(db.blockRules)..where((r) => r.id.equals(id))).go();
  }

  @override
  Future<List<entity.BlockRule>> getAllRules() async {
    final rules = await db.select(db.blockRules).get();
    return rules.map(mapToEntity).toList();
  }

  @override
  Future<entity.BlockRule?> getRuleById(String id) async {
    final rule = await (db.select(
      db.blockRules,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    if (rule == null) return null;
    return mapToEntity(rule);
  }

  @override
  Future<List<entity.BlockRule>> getRulesByCategoryId(String categoryId) async {
    final rules = await (db.select(
      db.blockRules,
    )..where((r) => r.categoryId.equals(categoryId))).get();
    return rules.map(mapToEntity).toList();
  }

  @override
  Future<void> updateRule(entity.BlockRule rule) async {
    await db.update(db.blockRules).replace(mapToCompanion(rule));
  }
}
