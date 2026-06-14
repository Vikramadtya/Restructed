import 'package:flutter/material.dart';
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
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
                const SizedBox(height: 16),
                const Text('Failed to Start Security Daemon', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(
                  init.error.toString().replaceAll('Exception: ', ''),
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(appInitializationProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Connection'),
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
          // Navigation Rail (Material Sidebar)
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (int index) {
              ref.read(sidebarIndexProvider.notifier).setIndex(index);
              ref.read(selectedCategoryIdProvider.notifier).setCategory(null);
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.shield_outlined),
                selectedIcon: Icon(Icons.shield),
                label: Text('Rules'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.category_outlined),
                selectedIcon: Icon(Icons.category),
                label: Text('Categories'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: mainContent,
            ),
          ),
        ],
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton:
          FloatingActionButton.extended(
            onPressed: () => showRuleDialog(context, ref),
            label: const Text(
              'Add Rule',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            backgroundColor: Theme.of(context).primaryColor,
          ).animate().scale(
            delay: 200.ms,
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
      body: Column(
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
              FilledButton.icon(
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

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Deep Focus Activated! All rules and categories enabled.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.flash_on, color: Colors.white),
                label: const Text(
                  'DEEP FOCUS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                ),
              ).animate().fadeIn(delay: 100.ms).scale(),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (val) =>
                ref.read(searchQueryProvider.notifier).setQuery(val),
            decoration: InputDecoration(
              hintText: 'Search rules by domain...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),
          const SizedBox(height: 20),
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
                    child: const Text(
                      'No rules found.',
                    ).animate().fadeIn().scale(),
                  );
                }
                return ListView.builder(
                  itemCount: filteredRules.length,
                  itemBuilder: (context, index) =>
                      RuleListTile(rule: filteredRules[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton:
          FloatingActionButton.extended(
            onPressed: () =>
                showRuleDialog(context, ref, initialCategoryId: categoryId),
            label: const Text(
              'Add Rule',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            backgroundColor: Theme.of(context).primaryColor,
          ).animate().scale(
            delay: 200.ms,
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
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
            ],
          ).animate().fadeIn().slideX(),
          const SizedBox(height: 20),
          TextField(
            onChanged: (val) =>
                ref.read(searchQueryProvider.notifier).setQuery(val),
            decoration: InputDecoration(
              hintText: 'Search rules by domain...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),
          const SizedBox(height: 20),
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
                    child: const Text(
                      'No rules found.',
                    ).animate().fadeIn().scale(),
                  );
                }
                return ListView.builder(
                  itemCount: filteredRules.length,
                  itemBuilder: (context, index) =>
                      RuleListTile(rule: filteredRules[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
