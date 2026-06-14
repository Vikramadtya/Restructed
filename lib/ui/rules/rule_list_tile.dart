import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget trailingIcon = const Icon(Icons.shield, size: 28);
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
              const Icon(Icons.public, size: 28, color: Colors.grey),
          errorWidget: (context, url, error) =>
              const Icon(Icons.language, size: 28, color: Colors.grey),
        ),
      );
    } else if (rule.isAppRule) {
      trailingIcon = const Icon(
        Icons.desktop_mac,
        size: 28,
        color: Colors.grey,
      );
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      color: isEffectivelyActive
          ? theme.cardTheme.color
          : (isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.02)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: isEffectivelyActive
            ? trailingIcon
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: 3000.ms,
                    color: theme.primaryColor.withValues(alpha: 0.3),
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
        title: Row(
          children: [
            Text(
              rule.domain,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isEffectivelyActive
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                decoration: isEffectivelyActive ? null : TextDecoration.lineThrough,
              ),
            ),
            if (rule.syncStatus == 'staged')
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            if (rule.syncStatus == 'failed')
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
              ),
          ],
        ),
        subtitle: Text(
          "${category.name} • ${rule.blockDuration.inMinutes >= 36500 * 24 * 60 ? 'Indefinite' : '${rule.blockDuration.inMinutes} mins'}${!isCategoryActive ? ' (Category Disabled)' : ''}${rule.syncStatus == 'staged' ? ' • Syncing...' : ''}${rule.syncStatus == 'failed' ? ' • Sync Failed' : ''}",
          style: TextStyle(
            color: rule.syncStatus == 'failed' 
                ? Colors.redAccent 
                : isEffectivelyActive
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (rule.isStrictMode && isEffectivelyActive)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.5),
                  ),
                ),
                child: const Text(
                  'STRICT',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Switch(
              value: rule.isActive,
              onChanged: !isCategoryActive
                  ? null
                  : (val) async {
                      if (rule.isStrictMode && !val) {
                        final passed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Strict Mode Active'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'To disable this rule, type: "I am giving up on my productivity"',
                                ),
                                const SizedBox(height: 16),
                                TextField(
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
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => showRuleDialog(context, ref, existingRule: rule),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Rule'),
                    content: const Text(
                      'Are you sure you want to delete this rule?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    await ref.read(ruleRepositoryProvider).deleteRule(rule.id);
                    await ref.read(daemonApiProvider).triggerSync();
                    // Do not invalidate providers or wait for DB here.
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
