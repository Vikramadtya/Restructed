import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restructed/backend/core/injection.dart';

import 'package:restructed/backend/categories/category_repository.dart';
import 'package:restructed/backend/rules/rule_repository.dart';
import 'package:restructed/backend/analytics/analytics_repository.dart';
import 'package:logger/logger.dart';
import 'package:restructed/backend/rules/block_rule.dart';
import 'package:restructed/backend/analytics/block_attempt.dart';
import 'package:restructed/backend/categories/category.dart';
import 'package:restructed/backend/daemon_client/daemon_connection.dart';
import 'package:restructed/backend/daemon_client/daemon_api.dart';
import 'package:restructed/backend/daemon_client/daemon_service.dart';
import 'package:restructed/backend/daemon_client/daemon_launcher.dart';
import 'package:restructed/backend/settings/settings_service.dart';

// Services
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return getIt<SettingsService>();
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    loadTheme();
    return ThemeMode.dark; // Default while loading
  }

  Future<void> loadTheme() async {
    final settings = ref.read(settingsServiceProvider);
    final isDark = await settings.isDarkMode();
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final settings = ref.read(settingsServiceProvider);
    final isDark = state == ThemeMode.dark;
    await settings.setDarkMode(!isDark);
    state = !isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

// Repositories
final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => getIt<CategoryRepository>(),
);
final ruleRepositoryProvider = Provider<RuleRepository>(
  (ref) => getIt<RuleRepository>(),
);
final analyticsRepositoryProvider = Provider<AnalyticsRepository>(
  (ref) => getIt<AnalyticsRepository>(),
);

final daemonLauncherProvider = Provider<DaemonLauncher>((ref) {
  final logger = getIt<Logger>();
  return DaemonLauncher(logger);
});

class AuthStatusNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.read(daemonLauncherProvider).token != null;
  }

  void checkAuth() {
    state = ref.read(daemonLauncherProvider).token != null;
  }
}

final authStatusProvider = NotifierProvider<AuthStatusNotifier, bool>(() {
  return AuthStatusNotifier();
});

// Daemon Layer
final daemonConnectionManagerProvider = Provider<DaemonConnectionManager>((ref) {
  final logger = getIt<Logger>();
  final launcher = ref.read(daemonLauncherProvider);
  final manager = DaemonConnectionManager(logger, launcher);
  // Auto-connect on startup
  manager.connect();
  ref.onDispose(() => manager.dispose());
  return manager;
});

final daemonApiProvider = Provider<DaemonApi>((ref) {
  return DaemonApi(
    ref.read(daemonConnectionManagerProvider),
    ref.read(ruleRepositoryProvider),
    ref.read(categoryRepositoryProvider),
    ref.read(settingsServiceProvider),
  );
});

final daemonServiceProvider = Provider<DaemonService>((ref) {
  return DaemonService(
    ref.read(daemonConnectionManagerProvider),
    ref.read(ruleRepositoryProvider),
    ref.read(categoryRepositoryProvider),
    ref.read(analyticsRepositoryProvider),
    ref.read(settingsServiceProvider),
    getIt<Logger>(),
    () {
      // Invalidate providers when daemon sync is complete
      ref.invalidate(rulesProvider);
      ref.invalidate(rulesByCategoryProvider);
      ref.invalidate(categoriesProvider);
    },
    () {
      // Invalidate analytics
      ref.invalidate(attemptsProvider);
    },
  );
});

// State Providers for UI
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.read(categoryRepositoryProvider).getAllCategories();
});

final rulesProvider = FutureProvider<List<BlockRule>>((ref) {
  return ref.read(ruleRepositoryProvider).getAllRules();
});

final rulesByCategoryProvider = FutureProvider.family<List<BlockRule>, String>((
  ref,
  categoryId,
) {
  return ref.read(ruleRepositoryProvider).getRulesByCategoryId(categoryId);
});

final attemptsProvider = StreamProvider<List<BlockAttempt>>((ref) {
  final retentionDays = ref
      .read(settingsServiceProvider)
      .analyticsRetentionDays;
  final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
  ref.read(analyticsRepositoryProvider).clearOldAttempts(cutoff);

  return ref.read(analyticsRepositoryProvider).watchAllAttempts();
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

final appInitializationProvider = FutureProvider<void>((ref) async {
  // Initialize the DaemonService so it starts listening to TCP events
  ref.read(daemonServiceProvider);

  final daemonApi = ref.read(daemonApiProvider);
  await daemonApi.triggerSync();
});
