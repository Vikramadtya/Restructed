import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
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
      return MacosWindow(
        child: MacosScaffold(
          children: [
            ContentArea(
              builder: (context, controller) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    ProgressCircle(),
                    SizedBox(height: 16),
                    Text('Starting Daemon & Syncing OS...', style: TextStyle(color: MacosColors.systemGrayColor)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    if (init.hasError) {
      return MacosWindow(
        child: MacosScaffold(
          children: [
            ContentArea(
              builder: (context, controller) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const MacosIcon(LucideIcons.alertCircle, color: MacosColors.systemRedColor, size: 64),
                      const SizedBox(height: 16),
                      const Text('Failed to Start Security Daemon', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text(
                        init.error.toString().replaceAll('Exception: ', ''),
                        style: const TextStyle(color: MacosColors.systemRedColor, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      PushButton(
                        controlSize: ControlSize.large,
                        onPressed: () => ref.invalidate(appInitializationProvider),
                        child: const Text('Retry Connection'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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

    return MacosWindow(
      sidebar: Sidebar(
        minWidth: 200,
        builder: (context, scrollController) {
          return SidebarItems(
            currentIndex: selectedIndex,
            onChanged: (int index) {
              ref.read(sidebarIndexProvider.notifier).setIndex(index);
              ref.read(selectedCategoryIdProvider.notifier).setCategory(null);
            },
            items: const [
              SidebarItem(
                leading: MacosIcon(LucideIcons.shield),
                label: Text('Rules'),
              ),
              SidebarItem(
                leading: MacosIcon(LucideIcons.folder),
                label: Text('Categories'),
              ),
              SidebarItem(
                leading: MacosIcon(LucideIcons.barChart2),
                label: Text('Analytics'),
              ),
              SidebarItem(
                leading: MacosIcon(LucideIcons.settings),
                label: Text('Settings'),
              ),
            ],
          );
        },
      ),
      child: MacosScaffold(
        toolBar: const ToolBar(
          title: Text('Restructed'),
          titleWidth: 150.0,
        ),
        children: [
          ContentArea(
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: mainContent,
              );
            },
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Active Rules',
              style: MacosTheme.of(context).typography.largeTitle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn().slideX(),
            const Spacer(),
            PushButton(
              controlSize: ControlSize.large,
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
              child: const Text('DEEP FOCUS'),
            ).animate().fadeIn(delay: 100.ms).scale(),
            const SizedBox(width: 12),
            PushButton(
              controlSize: ControlSize.large,
              onPressed: () => showRuleDialog(context, ref),
              child: const Text('Add Rule'),
            ).animate().fadeIn(delay: 200.ms).scale(),
          ],
        ),
        const SizedBox(height: 20),
        MacosTextField(
          placeholder: 'Search rules by domain...',
          onChanged: (val) =>
              ref.read(searchQueryProvider.notifier).setQuery(val),
          prefix: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: MacosIcon(LucideIcons.search, size: 16),
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
            loading: () => const Center(child: ProgressCircle()),
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
            MacosIconButton(
              icon: const MacosIcon(LucideIcons.arrowLeft),
              onPressed: () => ref
                  .read(selectedCategoryIdProvider.notifier)
                  .setCategory(null),
            ),
            const SizedBox(width: 8),
            Text(
              categoryName,
              style: MacosTheme.of(context).typography.largeTitle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            PushButton(
              controlSize: ControlSize.large,
              onPressed: () =>
                  showRuleDialog(context, ref, initialCategoryId: categoryId),
              child: const Text('Add Rule'),
            ).animate().fadeIn(delay: 200.ms).scale(),
          ],
        ).animate().fadeIn().slideX(),
        const SizedBox(height: 20),
        MacosTextField(
          placeholder: 'Search rules by domain...',
          onChanged: (val) =>
              ref.read(searchQueryProvider.notifier).setQuery(val),
          prefix: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: MacosIcon(LucideIcons.search, size: 16),
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
            loading: () => const Center(child: ProgressCircle()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}
