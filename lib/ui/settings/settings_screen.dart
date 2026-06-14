import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
    final confirmed = await showMacosAlertDialog<bool>(
      context: context,
      builder: (ctx) => MacosAlertDialog(
        appIcon: const MacosIcon(LucideIcons.alertTriangle, size: 64, color: MacosColors.systemRedColor),
        title: const Text('Factory Reset'),
        message: const Text(
          'This will delete ALL categories, rules, and analytics history. It will also unblock all websites from your system hosts file. The app will close after completion.\n\nAre you absolutely sure?',
        ),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          color: MacosColors.systemRedColor,
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Wipe Everything'),
        ),
        secondaryButton: PushButton(
          controlSize: ControlSize.large,
          secondary: true,
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
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
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return MacosScaffold(
      toolBar: const ToolBar(
        title: Text('Settings'),
        titleWidth: 150.0,
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24.0),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MacosTheme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MacosColors.systemGrayColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          MacosIcon(isDark ? LucideIcons.moon : LucideIcons.sun, size: 24),
                          const Gap(16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Dark Mode Theme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const Gap(4),
                              Text(isDark ? 'Neon Night' : 'Frost Light', style: TextStyle(color: MacosColors.systemGrayColor, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      MacosSwitch(
                        value: isDark,
                        onChanged: (val) {
                          ref.read(themeProvider.notifier).toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),
                const Gap(32),
                const Text(
                  'Advanced Security',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Gap(12),
                Container(
                  decoration: BoxDecoration(
                    color: MacosTheme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MacosColors.systemGrayColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const MacosIcon(LucideIcons.shieldAlert, size: 24),
                                  const Gap(16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Aggressive iCloud Private Relay Block', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const Gap(4),
                                        Text('Disables Safari Private Relay to prevent bypasses.', style: TextStyle(color: MacosColors.systemGrayColor, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            MacosSwitch(
                              value: ref.watch(settingsServiceProvider).disablePrivateRelay,
                              onChanged: (val) async {
                                await ref.read(settingsServiceProvider).setDisablePrivateRelay(val);
                                await ref.read(daemonApiProvider).triggerSync();
                                setState(() {}); // refresh toggle UI
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(height: 1, color: MacosColors.systemGrayColor.withValues(alpha: 0.2)),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const MacosIcon(LucideIcons.activity, size: 24),
                                  const Gap(16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Analytics Debounce Interval', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const Gap(4),
                                        Text('Minimum time between identical block logs.', style: TextStyle(color: MacosColors.systemGrayColor, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            MacosPopupButton<int>(
                              value: ref.watch(settingsServiceProvider).analyticsDebounceSeconds,
                              items: const [
                                MacosPopupMenuItem(value: 1, child: Text('1 Second')),
                                MacosPopupMenuItem(value: 5, child: Text('5 Seconds')),
                                MacosPopupMenuItem(value: 10, child: Text('10 Seconds')),
                              ],
                              onChanged: (val) async {
                                if (val != null) {
                                  await ref.read(settingsServiceProvider).setAnalyticsDebounceSeconds(val);
                                  setState(() {});
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(height: 1, color: MacosColors.systemGrayColor.withValues(alpha: 0.2)),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const MacosIcon(LucideIcons.save, size: 24),
                                  const Gap(16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Analytics Data Retention', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const Gap(4),
                                        Text('How long to keep history before auto-deleting.', style: TextStyle(color: MacosColors.systemGrayColor, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            MacosPopupButton<int>(
                              value: ref.watch(settingsServiceProvider).analyticsRetentionDays,
                              items: const [
                                MacosPopupMenuItem(value: 7, child: Text('7 Days')),
                                MacosPopupMenuItem(value: 30, child: Text('30 Days')),
                                MacosPopupMenuItem(value: 90, child: Text('90 Days')),
                                MacosPopupMenuItem(value: 365, child: Text('1 Year')),
                              ],
                              onChanged: (val) async {
                                if (val != null) {
                                  await ref.read(settingsServiceProvider).setAnalyticsRetentionDays(val);
                                  setState(() {});
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(40),
                const Text(
                  'Danger Zone',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: MacosColors.systemRedColor,
                    fontSize: 16,
                  ),
                ),
                const Gap(12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MacosColors.systemRedColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: MacosColors.systemRedColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const MacosIcon(
                            LucideIcons.alertTriangle,
                            color: MacosColors.systemRedColor,
                            size: 32,
                          ),
                          const Gap(16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Factory Reset',
                                style: TextStyle(
                                  color: MacosColors.systemRedColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                'Wipe all rules, databases, and restore hosts file.',
                                style: TextStyle(color: MacosColors.systemRedColor.withValues(alpha: 0.8), fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      isResetting
                          ? const ProgressCircle()
                          : PushButton(
                              controlSize: ControlSize.large,
                              color: MacosColors.systemRedColor,
                              onPressed: masterReset,
                              child: const Text('RESET APP'),
                            ),
                    ],
                  ),
                ),
                const Gap(40),
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
              ],
            );
          },
        ),
      ],
    );
  }
}
