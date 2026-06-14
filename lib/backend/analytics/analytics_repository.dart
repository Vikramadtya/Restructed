import 'package:restructed/backend/analytics/block_attempt.dart';

abstract class AnalyticsRepository {
  Future<void> logAttempt(String domain);
  Future<List<BlockAttempt>> getAttemptsForDomain(String domain);
  Future<List<BlockAttempt>> getAllAttempts();
  Stream<List<BlockAttempt>> watchAllAttempts();
  Future<void> clearOldAttempts(DateTime before);
}
