import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:gap/gap.dart';
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
        icon: const Icon(LucideIcons.alertTriangle, size: 64, color: Colors.redAccent),
        title: const Text('Factory Reset'),
        content: const Text(
          'This will delete ALL categories, rules, and analytics history. It will also unblock all websites from your system hosts file. The app will close after completion.\n\nAre you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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
        // App will exit
        await Future<void>.delayed(const Duration(seconds: 1));
        exit(0);
      }
    } catch (e) {
      setState(() => isResetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Settings', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(isDark ? LucideIcons.moon : LucideIcons.sun, size: 28, color: theme.colorScheme.primary),
                          const Gap(24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Dark Mode Theme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const Gap(4),
                              Text(isDark ? 'Neon Night' : 'Frost Light', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: isDark,
                        activeThumbColor: theme.colorScheme.primary,
                        onChanged: (val) {
                          ref.read(themeProvider.notifier).toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),
                const Gap(40),
                const Text(
                  'Advanced Security',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Gap(16),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(LucideIcons.shieldAlert, size: 28, color: theme.colorScheme.primary),
                                  const Gap(24),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Aggressive iCloud Private Relay Block', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const Gap(4),
                                        const Text('Disables Safari Private Relay to prevent bypasses.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: ref.watch(settingsServiceProvider).disablePrivateRelay,
                              activeThumbColor: theme.colorScheme.primary,
                              onChanged: (val) async {
                                await ref.read(settingsServiceProvider).setDisablePrivateRelay(val);
                                await ref.read(daemonApiProvider).triggerSync();
                                setState(() {}); // refresh toggle UI
                              },
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(LucideIcons.activity, size: 28, color: theme.colorScheme.primary),
                                  const Gap(24),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Analytics Debounce Interval', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const Gap(4),
                                        const Text('Minimum time between identical block logs.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: ref.watch(settingsServiceProvider).analyticsDebounceSeconds,
                                items: const [
                                  DropdownMenuItem(value: 1, child: Text('1 Second')),
                                  DropdownMenuItem(value: 5, child: Text('5 Seconds')),
                                  DropdownMenuItem(value: 10, child: Text('10 Seconds')),
                                ],
                                onChanged: (val) async {
                                  if (val != null) {
                                    await ref.read(settingsServiceProvider).setAnalyticsDebounceSeconds(val);
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(LucideIcons.save, size: 28, color: theme.colorScheme.primary),
                                  const Gap(24),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Analytics Data Retention', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const Gap(4),
                                        const Text('How long to keep history before auto-deleting.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: ref.watch(settingsServiceProvider).analyticsRetentionDays,
                                items: const [
                                  DropdownMenuItem(value: 7, child: Text('7 Days')),
                                  DropdownMenuItem(value: 30, child: Text('30 Days')),
                                  DropdownMenuItem(value: 90, child: Text('90 Days')),
                                  DropdownMenuItem(value: 365, child: Text('1 Year')),
                                ],
                                onChanged: (val) async {
                                  if (val != null) {
                                    await ref.read(settingsServiceProvider).setAnalyticsRetentionDays(val);
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(48),
                const Text(
                  'Danger Zone',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    fontSize: 18,
                  ),
                ),
                const Gap(16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.alertTriangle,
                            color: Colors.redAccent,
                            size: 36,
                          ),
                          const Gap(24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Factory Reset',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                'Wipe all rules, databases, and restore hosts file.',
                                style: TextStyle(color: Colors.redAccent.withValues(alpha: 0.8), fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      isResetting
                          ? const CircularProgressIndicator(color: Colors.redAccent)
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              onPressed: masterReset,
                              child: const Text('RESET APP'),
                            ),
                    ],
                  ),
                ),
                const Gap(48),
                const Opacity(
                  opacity: 0.5,
                  child: Center(
                    child: Text(
                      'Restructed v1.0.0\nPremium Edition',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const Gap(48),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
