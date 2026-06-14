import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:restructed/ui/core/app_providers.dart';
import 'package:restructed/backend/categories/category.dart';
import '../analytics/analytics_screen.dart';
import '../settings/settings_screen.dart';
import 'package:restructed/ui/rules/rule_list_tile.dart';
import 'package:restructed/ui/rules/rule_dialog.dart';
import '../categories/categories_screen.dart';
import 'permission_screen.dart';

// Navigation State
class SidebarIndex extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final sidebarIndexProvider = NotifierProvider<SidebarIndex, int>(
  () => SidebarIndex(),
);

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setCategory(String? categoryId) => state = categoryId;
}

final selectedCategoryIdProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
      () => SelectedCategoryNotifier(),
    );

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(appInitializationProvider);
    
    if (init.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Starting Daemon & Syncing OS...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    
    if (init.hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.alertCircle, color: Colors.redAccent, size: 64),
                const SizedBox(height: 16),
                const Text('Failed to Start Security Daemon', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(
                  init.error.toString().replaceAll('Exception: ', ''),
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => ref.invalidate(appInitializationProvider),
                  child: const Text('Retry Connection'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isAuth = ref.watch(authStatusProvider);
    if (!isAuth) {
      return const PermissionScreen();
    }

    final selectedIndex = ref.watch(sidebarIndexProvider);

    Widget mainContent;
    switch (selectedIndex) {
      case 0:
        mainContent = const RulesView();
        break;
      case 1:
        final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
        if (selectedCategoryId != null) {
          mainContent = CategoryRulesScreen(categoryId: selectedCategoryId);
        } else {
          mainContent = const CategoriesScreen();
        }
        break;
      case 2:
        mainContent = const AnalyticsScreen();
        break;
      case 3:
        mainContent = const SettingsScreen();
        break;
      default:
        mainContent = const Center(child: Text('Coming Soon'));
    }

    return Scaffold(
      body: Row(
        children: [
          // Glassmorphic Sidebar
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
              border: Border(
                right: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    Text(
                      'Restructed',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        letterSpacing: 1.2,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                      ),
                    ).animate().fadeIn().slideY(begin: -0.2),
                    const SizedBox(height: 48),
                    _SidebarItem(
                      index: 0,
                      icon: LucideIcons.shield,
                      label: 'Rules',
                      selectedIndex: selectedIndex,
                    ),
                    _SidebarItem(
                      index: 1,
                      icon: LucideIcons.folder,
                      label: 'Categories',
                      selectedIndex: selectedIndex,
                    ),
                    _SidebarItem(
                      index: 2,
                      icon: LucideIcons.barChart2,
                      label: 'Analytics',
                      selectedIndex: selectedIndex,
                    ),
                    _SidebarItem(
                      index: 3,
                      icon: LucideIcons.settings,
                      label: 'Settings',
                      selectedIndex: selectedIndex,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Main Content Area
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: AnimatedSwitcher(
                  duration: 300.ms,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(selectedIndex),
                    child: mainContent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends ConsumerWidget {
  final int index;
  final IconData icon;
  final String label;
  final int selectedIndex;

  const _SidebarItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = index == selectedIndex;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            ref.read(sidebarIndexProvider.notifier).setIndex(index);
            ref.read(selectedCategoryIdProvider.notifier).setCategory(null);
          },
          hoverColor: colorScheme.primary.withValues(alpha: 0.1),
          child: AnimatedContainer(
            duration: 200.ms,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected 
                ? colorScheme.primary.withValues(alpha: 0.2) 
                : Colors.transparent,
              border: isSelected 
                ? Border.all(color: colorScheme.primary.withValues(alpha: 0.5))
                : Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 20,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RulesView extends ConsumerWidget {
  const RulesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsyncValue = ref.watch(rulesProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Active Rules',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn().slideX(),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                // Deep Focus: Activate all rules and categories
                final rules = await ref
                    .read(ruleRepositoryProvider)
                    .getAllRules();
                final categories = await ref
                    .read(categoryRepositoryProvider)
                    .getAllCategories();

                final daemonApi = ref.read(daemonApiProvider);
                
                for (final cat in categories) {
                  if (!cat.isActive) {
                    final updatedCat = cat.copyWith(isActive: true, syncStatus: 'staged');
                    await ref
                        .read(categoryRepositoryProvider)
                        .updateCategory(updatedCat);
                    await daemonApi.triggerSync();
                  }
                }
                for (final rule in rules) {
                  if (!rule.isActive) {
                    final updatedRule = rule.copyWith(
                          isActive: true,
                          lastActivatedAt: DateTime.now(),
                          syncStatus: 'staged',
                        );
                    await ref
                        .read(ruleRepositoryProvider)
                        .updateRule(updatedRule);
                    await daemonApi.triggerSync();
                  }
                }

                ref.invalidate(rulesProvider);
                ref.invalidate(categoriesProvider);
              },
              icon: const Icon(LucideIcons.zap),
              label: const Text('DEEP FOCUS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shadowColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
              ),
            ).animate().fadeIn(delay: 100.ms).scale(),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => showRuleDialog(context, ref),
              icon: const Icon(LucideIcons.plus),
              label: const Text('Add Rule'),
            ).animate().fadeIn(delay: 200.ms).scale(),
          ],
        ),
        const SizedBox(height: 32),
        TextField(
          onChanged: (val) => ref.read(searchQueryProvider.notifier).setQuery(val),
          decoration: InputDecoration(
            hintText: 'Search rules by domain...',
            prefixIcon: const Icon(LucideIcons.search),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),
        const SizedBox(height: 24),
        Expanded(
          child: rulesAsyncValue.when(
            data: (rules) {
              final filteredRules = rules
                  .where(
                    (r) => r.domain.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
                  )
                  .toList();

              if (filteredRules.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.shieldOff, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No rules found.',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ).animate().fadeIn().scale(),
                    ],
                  )
                );
              }
              return ListView.builder(
                itemCount: filteredRules.length,
                itemBuilder: (context, index) =>
                    RuleListTile(rule: filteredRules[index])
                        .animate()
                        .fadeIn(delay: (50 * index).ms)
                        .slideX(begin: 0.1),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}

class CategoryRulesScreen extends ConsumerWidget {
  final String categoryId;
  const CategoryRulesScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsyncValue = ref.watch(rulesByCategoryProvider(categoryId));
    final categoriesAsync = ref.watch(categoriesProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    final categoryName = categoriesAsync.maybeWhen(
      data: (categories) => categories
          .firstWhere(
            (c) => c.id == categoryId,
            orElse: () => const Category(id: '', name: 'Rules'),
          )
          .name,
      orElse: () => 'Rules',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => ref
                  .read(selectedCategoryIdProvider.notifier)
                  .setCategory(null),
            ),
            const SizedBox(width: 8),
            Text(
              categoryName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () =>
                  showRuleDialog(context, ref, initialCategoryId: categoryId),
              icon: const Icon(LucideIcons.plus),
              label: const Text('Add Rule'),
            ).animate().fadeIn(delay: 200.ms).scale(),
          ],
        ).animate().fadeIn().slideX(),
        const SizedBox(height: 32),
        TextField(
          onChanged: (val) => ref.read(searchQueryProvider.notifier).setQuery(val),
          decoration: InputDecoration(
            hintText: 'Search rules by domain...',
            prefixIcon: const Icon(LucideIcons.search),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),
        const SizedBox(height: 24),
        Expanded(
          child: rulesAsyncValue.when(
            data: (rules) {
              final filteredRules = rules
                  .where(
                    (r) => r.domain.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
                  )
                  .toList();

              if (filteredRules.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.shieldOff, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No rules found.',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ).animate().fadeIn().scale(),
                    ],
                  )
                );
              }
              return ListView.builder(
                itemCount: filteredRules.length,
                itemBuilder: (context, index) =>
                    RuleListTile(rule: filteredRules[index])
                        .animate()
                        .fadeIn(delay: (50 * index).ms)
                        .slideX(begin: 0.1),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}
