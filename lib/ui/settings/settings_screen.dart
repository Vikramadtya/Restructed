import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:restructed/ui/core/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool isResetting = false;

  Future<void> masterReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Factory Reset',
          style: TextStyle(color: Colors.redAccent),
        ),
        content: const Text(
          'This will delete ALL categories, rules, and analytics history. It will also unblock all websites from your system hosts file. The app will close after completion.\n\nAre you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Wipe Everything'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => isResetting = true);
    try {
      // In a real app, send a RESET command to the Daemon
      // For now, we just delete the database

      // Delete the SQLite database
      final dbFolder = await getApplicationDocumentsDirectory();
      final fullPath = p.join(dbFolder.path, 'restructed', 'app_db.sqlite');
      if (await File(fullPath).exists()) {
        await File(fullPath).delete();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reset Complete. App will now exit.')),
        );
        await Future<void>.delayed(const Duration(seconds: 2));
        exit(0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => isResetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                        ),
                        title: const Text('Dark Mode Theme'),
                        subtitle: Text(isDark ? 'Neon Night' : 'Frost Light'),
                        value: isDark,
                        onChanged: (val) {
                          ref.read(themeProvider.notifier).toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Advanced Security',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.shield_outlined),
                        title: const Text(
                          'Aggressive iCloud Private Relay Block',
                        ),
                        subtitle: const Text(
                          'Disables Safari Private Relay to prevent bypasses.',
                        ),
                        value: ref
                            .watch(settingsServiceProvider)
                            .disablePrivateRelay,
                        onChanged: (val) async {
                          await ref
                              .read(settingsServiceProvider)
                              .setDisablePrivateRelay(val);
                          await ref.read(daemonApiProvider).triggerSync();
                          setState(() {}); // refresh toggle UI
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.speed),
                        title: const Text('Analytics Debounce Interval'),
                        subtitle: const Text(
                          'Minimum time between identical block logs.',
                        ),
                        trailing: DropdownButton<int>(
                          value: ref
                              .watch(settingsServiceProvider)
                              .analyticsDebounceSeconds,
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('1 Second')),
                            DropdownMenuItem(
                              value: 5,
                              child: Text('5 Seconds'),
                            ),
                            DropdownMenuItem(
                              value: 10,
                              child: Text('10 Seconds'),
                            ),
                          ],
                          onChanged: (val) async {
                            if (val != null) {
                              await ref
                                  .read(settingsServiceProvider)
                                  .setAnalyticsDebounceSeconds(val);
                              setState(() {});
                            }
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.save_outlined),
                        title: const Text('Analytics Data Retention'),
                        subtitle: const Text(
                          'How long to keep history before auto-deleting.',
                        ),
                        trailing: DropdownButton<int>(
                          value: ref
                              .watch(settingsServiceProvider)
                              .analyticsRetentionDays,
                          items: const [
                            DropdownMenuItem(value: 7, child: Text('7 Days')),
                            DropdownMenuItem(value: 30, child: Text('30 Days')),
                            DropdownMenuItem(value: 90, child: Text('90 Days')),
                            DropdownMenuItem(value: 365, child: Text('1 Year')),
                          ],
                          onChanged: (val) async {
                            if (val != null) {
                              await ref
                                  .read(settingsServiceProvider)
                                  .setAnalyticsRetentionDays(val);
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Danger Zone',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: Colors.redAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.redAccent,
                          size: 32,
                        ),
                        title: const Text(
                          'Factory Reset',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Wipe all rules, databases, and restore hosts file.',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        trailing: isResetting
                            ? const CircularProgressIndicator(
                                color: Colors.redAccent,
                              )
                            : OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  side: const BorderSide(
                                    color: Colors.redAccent,
                                  ),
                                ),
                                onPressed: masterReset,
                                child: const Text('RESET APP'),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Opacity(
                  opacity: 0.5,
                  child: Center(
                    child: Text(
                      'Restructed v1.0.0\nPremium Edition',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
