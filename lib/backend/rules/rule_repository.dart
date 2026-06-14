import 'package:restructed/backend/rules/block_rule.dart';

/// Core interface for managing User-defined Block Rules (both Domains and macOS Apps).
/// This defines the repository contract which the Infrastructure layer implements.
abstract class RuleRepository {
  /// Fetches all stored block rules from the database.
  Future<List<BlockRule>> getAllRules();

  /// Fetches rules belonging to a specific category (e.g. 'Social Media').
  Future<List<BlockRule>> getRulesByCategoryId(String categoryId);

  /// Looks up a single block rule by its unique UUID.
  Future<BlockRule?> getRuleById(String id);

  /// Persists a new block rule to the database.
  Future<void> createRule(BlockRule rule);

  /// Updates an existing block rule.
  Future<void> updateRule(BlockRule rule);

  /// Permanently deletes a block rule.
  Future<void> deleteRule(String id);
}
