import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:gap/gap.dart';

import 'package:restructed/ui/core/app_providers.dart';
import 'package:restructed/backend/rules/block_rule.dart';
import 'package:restructed/backend/categories/category.dart';
import 'rule_dialog.dart';

class RuleListTile extends ConsumerStatefulWidget {
  final BlockRule rule;

  const RuleListTile({super.key, required this.rule});

  @override
  ConsumerState<RuleListTile> createState() => _RuleListTileState();
}

class _RuleListTileState extends ConsumerState<RuleListTile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final category = categoriesAsync.maybeWhen(
      data: (categories) => categories.firstWhere(
        (c) => c.id == widget.rule.categoryId,
        orElse: () => const Category(id: '', name: 'Uncategorized'),
      ),
      orElse: () => const Category(id: '', name: 'Loading...'),
    );

    final bool isCategoryActive = category.isActive;
    final bool isEffectivelyActive = widget.rule.isActive && isCategoryActive;

    final theme = Theme.of(context);

    Widget trailingIcon = const Icon(LucideIcons.shield, size: 28);
    if (!widget.rule.isAppRule && widget.rule.domain.isNotEmpty) {
      trailingIcon = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: 'https://www.google.com/s2/favicons?domain=${widget.rule.domain}&sz=128',
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Icon(LucideIcons.globe, size: 28, color: Colors.grey),
          errorWidget: (context, url, error) => const Icon(LucideIcons.globe2, size: 28, color: Colors.grey),
        ),
      );
    } else if (widget.rule.isAppRule) {
      trailingIcon = const Icon(
        LucideIcons.monitor,
        size: 28,
        color: Colors.grey,
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: 200.ms,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isEffectivelyActive
              ? theme.colorScheme.surface.withValues(alpha: 0.8)
              : theme.colorScheme.surface.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovering
                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.05),
            width: _isHovering ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (_isHovering && isEffectivelyActive)
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 12,
                spreadRadius: 2,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  isEffectivelyActive
                      ? trailingIcon
                            .animate(onPlay: (controller) => controller.repeat())
                            .shimmer(
                              duration: 3000.ms,
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            )
                      : ColorFiltered(
                          colorFilter: const ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 1, 0,
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
                              widget.rule.domain,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isEffectivelyActive
                                    ? theme.textTheme.bodyLarge?.color
                                    : theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                                decoration: isEffectivelyActive ? null : TextDecoration.lineThrough,
                              ),
                            ),
                            if (widget.rule.syncStatus == 'staged')
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            if (widget.rule.syncStatus == 'failed')
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(LucideIcons.alertCircle, color: Colors.redAccent, size: 16),
                              ),
                          ],
                        ),
                        const Gap(4),
                        Text(
                          "${category.name} • ${widget.rule.blockDuration.inMinutes >= 36500 * 24 * 60 ? 'Indefinite' : '${widget.rule.blockDuration.inMinutes} mins'}${!isCategoryActive ? ' (Category Disabled)' : ''}${widget.rule.syncStatus == 'staged' ? ' • Syncing...' : ''}${widget.rule.syncStatus == 'failed' ? ' • Sync Failed' : ''}",
                          style: TextStyle(
                            color: widget.rule.syncStatus == 'failed' 
                                ? Colors.redAccent 
                                : isEffectivelyActive
                                    ? theme.colorScheme.primary
                                    : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.rule.isStrictMode && isEffectivelyActive)
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
                        value: widget.rule.isActive,
                        activeColor: theme.colorScheme.primary,
                        onChanged: !isCategoryActive
                            ? null
                            : (val) async {
                                if (widget.rule.isStrictMode && !val) {
                                  final textController = TextEditingController();
                                  final passed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      icon: const Icon(LucideIcons.shieldAlert, size: 64, color: Colors.redAccent),
                                      title: const Text('Strict Mode Active'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'To disable this rule, type: "I am giving up on my productivity"',
                                          ),
                                          const Gap(16),
                                          TextField(
                                            controller: textController,
                                            autofocus: true,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                            ),
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
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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
                                      ],
                                    ),
                                  );
                                  if (passed != true) return;
                                }
          
                                try {
                                  final daemonApi = ref.read(daemonApiProvider);
                                  final ruleRepo = ref.read(ruleRepositoryProvider);
                                  final updatedRule = widget.rule.copyWith(isActive: val, syncStatus: 'staged');
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
                      IconButton(
                        icon: const Icon(LucideIcons.edit2, size: 20),
                        onPressed: () => showRuleDialog(context, ref, existingRule: widget.rule),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 20),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              icon: const Icon(LucideIcons.alertTriangle, color: Colors.redAccent, size: 64),
                              title: const Text('Delete Rule'),
                              content: const Text(
                                'Are you sure you want to delete this rule?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              await ref.read(ruleRepositoryProvider).deleteRule(widget.rule.id);
                              await ref.read(daemonApiProvider).triggerSync();
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
          ),
        ),
      ),
    );
  }
}
