import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gap/gap.dart';

import 'package:restructed/ui/core/app_providers.dart';
import 'package:restructed/backend/rules/block_rule.dart';
import 'package:restructed/backend/categories/category.dart';
import 'rule_dialog.dart';

class RuleListTile extends ConsumerWidget {
  final BlockRule rule;

  const RuleListTile({super.key, required this.rule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final category = categoriesAsync.maybeWhen(
      data: (categories) => categories.firstWhere(
        (c) => c.id == rule.categoryId,
        orElse: () => const Category(id: '', name: 'Uncategorized'),
      ),
      orElse: () => const Category(id: '', name: 'Loading...'),
    );

    final bool isCategoryActive = category.isActive;
    final bool isEffectivelyActive = rule.isActive && isCategoryActive;

    final theme = MacosTheme.of(context);
    final isDark = MacosTheme.brightnessOf(context) == Brightness.dark;

    Widget trailingIcon = const MacosIcon(LucideIcons.shield, size: 28);
    if (!rule.isAppRule && rule.domain.isNotEmpty) {
      trailingIcon = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl:
              'https://www.google.com/s2/favicons?domain=${rule.domain}&sz=128',
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const MacosIcon(LucideIcons.globe, size: 28, color: MacosColors.systemGrayColor),
          errorWidget: (context, url, error) =>
              const MacosIcon(LucideIcons.globe2, size: 28, color: MacosColors.systemGrayColor),
        ),
      );
    } else if (rule.isAppRule) {
      trailingIcon = const MacosIcon(
        LucideIcons.monitor,
        size: 28,
        color: MacosColors.systemGrayColor,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isEffectivelyActive
            ? theme.canvasColor
            : (isDark
                  ? const Color(0xFFFFFFFF).withValues(alpha: 0.05)
                  : const Color(0xFF000000).withValues(alpha: 0.02)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MacosColors.systemGrayColor.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            isEffectivelyActive
                ? trailingIcon
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                        duration: 3000.ms,
                        color: MacosColors.systemBlueColor.withValues(alpha: 0.3),
                      )
                : ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
                    child: Opacity(opacity: 0.5, child: trailingIcon),
                  ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        rule.domain,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isEffectivelyActive
                              ? theme.typography.body.color
                              : theme.typography.body.color?.withValues(alpha: 0.5),
                          decoration: isEffectivelyActive ? null : TextDecoration.lineThrough,
                        ),
                      ),
                      if (rule.syncStatus == 'staged')
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: ProgressCircle(),
                          ),
                        ),
                      if (rule.syncStatus == 'failed')
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: MacosIcon(LucideIcons.alertCircle, color: MacosColors.systemRedColor, size: 16),
                        ),
                    ],
                  ),
                  const Gap(4),
                  Text(
                    "${category.name} • ${rule.blockDuration.inMinutes >= 36500 * 24 * 60 ? 'Indefinite' : '${rule.blockDuration.inMinutes} mins'}${!isCategoryActive ? ' (Category Disabled)' : ''}${rule.syncStatus == 'staged' ? ' • Syncing...' : ''}${rule.syncStatus == 'failed' ? ' • Sync Failed' : ''}",
                    style: TextStyle(
                      color: rule.syncStatus == 'failed' 
                          ? MacosColors.systemRedColor 
                          : isEffectivelyActive
                              ? MacosColors.systemBlueColor
                              : theme.typography.body.color?.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (rule.isStrictMode && isEffectivelyActive)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: MacosColors.systemRedColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: MacosColors.systemRedColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Text(
                      'STRICT',
                      style: TextStyle(
                        color: MacosColors.systemRedColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                MacosSwitch(
                  value: rule.isActive,
                  onChanged: !isCategoryActive
                      ? null
                      : (val) async {
                          if (rule.isStrictMode && !val) {
                            final textController = TextEditingController();
                            final passed = await showMacosAlertDialog<bool>(
                              context: context,
                              builder: (ctx) => MacosAlertDialog(
                                appIcon: const MacosIcon(LucideIcons.shieldAlert, size: 64, color: MacosColors.systemRedColor),
                                title: const Text('Strict Mode Active'),
                                message: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'To disable this rule, type: "I am giving up on my productivity"',
                                    ),
                                    const Gap(16),
                                    MacosTextField(
                                      controller: textController,
                                      autofocus: true,
                                      onSubmitted: (text) {
                                        if (text.trim().toLowerCase() ==
                                            'i am giving up on my productivity') {
                                          Navigator.pop(ctx, true);
                                        } else {
                                          Navigator.pop(ctx, false);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                primaryButton: PushButton(
                                  controlSize: ControlSize.large,
                                  color: MacosColors.systemRedColor,
                                  onPressed: () {
                                    if (textController.text.trim().toLowerCase() ==
                                        'i am giving up on my productivity') {
                                      Navigator.pop(ctx, true);
                                    } else {
                                      Navigator.pop(ctx, false);
                                    }
                                  },
                                  child: const Text('Disable Rule'),
                                ),
                                secondaryButton: PushButton(
                                  controlSize: ControlSize.large,
                                  secondary: true,
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                              ),
                            );
                            if (passed != true) return;
                          }
    
                          try {
                            final daemonApi = ref.read(daemonApiProvider);
                            final ruleRepo = ref.read(ruleRepositoryProvider);
                            final updatedRule = rule.copyWith(isActive: val, syncStatus: 'staged');
                            await ruleRepo.updateRule(updatedRule);
                            await daemonApi.triggerSync();
                            ref.invalidate(rulesProvider);
                            ref.invalidate(rulesByCategoryProvider);
                          } catch (e) {
                            // Handled
                          }
                        },
                ),
                const Gap(8),
                MacosIconButton(
                  icon: const MacosIcon(LucideIcons.edit2, size: 20),
                  onPressed: () => showRuleDialog(context, ref, existingRule: rule),
                ),
                MacosIconButton(
                  icon: const MacosIcon(LucideIcons.trash2, color: MacosColors.systemRedColor, size: 20),
                  onPressed: () async {
                    final confirm = await showMacosAlertDialog<bool>(
                      context: context,
                      builder: (ctx) => MacosAlertDialog(
                        appIcon: const MacosIcon(LucideIcons.alertTriangle, color: MacosColors.systemRedColor, size: 64),
                        title: const Text('Delete Rule'),
                        message: const Text(
                          'Are you sure you want to delete this rule?',
                        ),
                        primaryButton: PushButton(
                          controlSize: ControlSize.large,
                          color: MacosColors.systemRedColor,
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete'),
                        ),
                        secondaryButton: PushButton(
                          controlSize: ControlSize.large,
                          secondary: true,
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                      ),
                    );
                    if (confirm == true) {
                      try {
                        await ref.read(ruleRepositoryProvider).deleteRule(rule.id);
                        await ref.read(daemonApiProvider).triggerSync();
                        // Do not invalidate providers or wait for DB here.
                      } catch (e) {
                        // Handled
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
