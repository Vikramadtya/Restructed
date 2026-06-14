import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  final SharedPreferences prefs;

  SettingsService(this.prefs);

  int get rotationTimeMinutes => prefs.getInt('rotation_time') ?? 5;
  int get evictionTimeMinutes => prefs.getInt('eviction_time') ?? 10;

  Future<void> setRotationTimeMinutes(int value) async {
    await prefs.setInt('rotation_time', value);
  }

  Future<void> setEvictionTimeMinutes(int value) async {
    await prefs.setInt('eviction_time', value);
  }

  Future<bool> isDarkMode() async {
    return prefs.getBool('dark_mode') ?? true;
  }

  Future<void> setDarkMode(bool value) async {
    await prefs.setBool('dark_mode', value);
  }

  bool get disablePrivateRelay =>
      prefs.getBool('disable_private_relay') ?? true;

  Future<void> setDisablePrivateRelay(bool value) async {
    await prefs.setBool('disable_private_relay', value);
  }

  int get analyticsDebounceSeconds =>
      prefs.getInt('analytics_debounce_seconds') ?? 5;

  Future<void> setAnalyticsDebounceSeconds(int value) async {
    await prefs.setInt('analytics_debounce_seconds', value);
  }

  int get analyticsRetentionDays =>
      prefs.getInt('analytics_retention_days') ?? 30;

  Future<void> setAnalyticsRetentionDays(int value) async {
    await prefs.setInt('analytics_retention_days', value);
  }
}
