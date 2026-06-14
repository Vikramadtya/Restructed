import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:restructed/backend/core/database.dart';
import 'package:restructed/backend/categories/category_repository_impl.dart';
import 'package:restructed/backend/rules/rule_repository_impl.dart';
import 'package:restructed/backend/analytics/analytics_repository_impl.dart';
import 'package:restructed/backend/settings/settings_service.dart';

import 'package:restructed/backend/categories/category_repository.dart';
import 'package:restructed/backend/rules/rule_repository.dart';
import 'package:restructed/backend/analytics/analytics_repository.dart';

final getIt = GetIt.instance;

Future<void> setupInjection() async {
  // Database
  final db = AppDatabase();
  getIt.registerSingleton<AppDatabase>(db);

  // Repositories
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<RuleRepository>(() => RuleRepositoryImpl(getIt()));
  getIt.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(getIt()),
  );

  // Blocking Engine is now handled entirely by the Daemon architecture
  // Services
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerLazySingleton<SettingsService>(() => SettingsService(getIt()));
  getIt.registerLazySingleton<Logger>(
    () => Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    ),
  );
}
