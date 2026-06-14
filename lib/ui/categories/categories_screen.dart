import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:gap/gap.dart';

import 'package:restructed/ui/core/app_providers.dart';
import 'package:restructed/backend/categories/category.dart';
import 'package:restructed/ui/categories/category_dialog.dart';
import 'package:restructed/ui/dashboard/dashboard_screen.dart'; // for selectedCategoryIdProvider

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    final rulesAsyncValue = ref.watch(rulesProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return categoriesAsyncValue.when(
      data: (categories) => _buildContent(context, ref, categories, rulesAsyncValue, false, searchQuery),
      loading: () => Skeletonizer(
        enabled: true,
        child: _buildContent(
          context,
          ref,
          [
            const Category(id: '1', name: 'Social Media', isActive: true),
            const Category(id: '2', name: 'Entertainment', isActive: false),
            const Category(id: '3', name: 'News', isActive: true),
            const Category(id: '4', name: 'Gaming', isActive: false),
          ],
          rulesAsyncValue,
          true,
          '',
        ),
      ),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Category> categories,
    AsyncValue<List<dynamic>> rulesAsyncValue,
    bool isLoading,
    String searchQuery,
  ) {
    final filteredCategories = categories
        .where(
          (c) => c.name.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: MacosTheme.of(context).typography.largeTitle.copyWith(fontWeight: FontWeight.bold),
                  ).animate().fadeIn().slideX(),
                  const Gap(8),
                  Text(
                    'Organize your blocking rules with categories.',
                    style: TextStyle(color: MacosColors.systemGrayColor),
                  ).animate().fadeIn(delay: 100.ms),
                ],
              ),
            ),
            PushButton(
              controlSize: ControlSize.large,
              onPressed: () => showCategoryDialog(context, ref),
              child: const Text('Add Category'),
            ).animate().scale(delay: 100.ms),
          ],
        ),
        const Gap(24),
        MacosTextField(
          placeholder: 'Search categories...',
          onChanged: (val) =>
              ref.read(searchQueryProvider.notifier).setQuery(val),
          prefix: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: MacosIcon(LucideIcons.search, size: 16),
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),
        const Gap(24),
        Expanded(
          child: filteredCategories.isEmpty && !isLoading
              ? Center(
                  child: Text(
                    'No categories found.',
                    style: TextStyle(
                      color: MacosTheme.of(context).typography.body.color,
                    ),
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    mainAxisExtent: 280,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final cat = filteredCategories[index];

                    int ruleCount = isLoading ? 5 : 0;
                    if (!isLoading) {
                      rulesAsyncValue.whenData((rules) {
                        ruleCount = rules
                            .where((r) => r.categoryId == cat.id)
                            .length;
                      });
                    }

                    return CategoryCard(category: cat, ruleCount: ruleCount)
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: 100 + (index * 50)))
                        .scale(begin: const Offset(0.95, 0.95));
                  },
                ),
        ),
      ],
    );
  }
}

class CategoryCard extends ConsumerWidget {
  final Category category;
  final int ruleCount;

  const CategoryCard({
    super.key,
    required this.category,
    required this.ruleCount,
  });

  Color getCategoryColor(String? name) {
    if (name == null) return MacosColors.systemGrayColor;
    final lower = name.toLowerCase();
    if (lower.contains('social')) return MacosColors.systemPurpleColor;
    if (lower.contains('entertainment') || lower.contains('video')) {
      return MacosColors.systemRedColor;
    }
    if (lower.contains('news')) return MacosColors.systemBlueColor;
    if (lower.contains('gaming')) return MacosColors.systemGreenColor;
    if (lower.contains('shop')) return MacosColors.systemYellowColor;
    return MacosColors.systemGrayColor;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = getCategoryColor(category.name);
    final theme = MacosTheme.of(context);
    final isDark = MacosTheme.brightnessOf(context) == Brightness.dark;

    return GestureDetector(
      onTap: () {
        ref.read(selectedCategoryIdProvider.notifier).setCategory(category.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.canvasColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? const Color(0xFFFFFFFF).withValues(alpha: 0.05)
                : const Color(0xFF000000).withValues(alpha: 0.05),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: MacosIconButton(
                  icon: const MacosIcon(
                    LucideIcons.edit2,
                    color: MacosColors.systemGrayColor,
                    size: 20,
                  ),
                  onPressed: () => showCategoryDialog(
                    context,
                    ref,
                    existingCategory: category,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: category.icon != null && category.icon!.isNotEmpty
                      ? Text(
                          category.icon!,
                          style: const TextStyle(fontSize: 28),
                        )
                      : MacosIcon(LucideIcons.folder, color: color, size: 28),
                ),
              ),
              const Gap(12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      category.name,
                      style: TextStyle(
                        color: theme.typography.body.color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (category.syncStatus == 'staged')
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: ProgressCircle(),
                      ),
                    ),
                  if (category.syncStatus == 'failed')
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: MacosIcon(LucideIcons.alertCircle, color: MacosColors.systemRedColor, size: 16),
                    ),
                ],
              ),
              const Gap(4),
              Text(
                '$ruleCount sites',
                style: const TextStyle(color: MacosColors.systemGrayColor, fontSize: 12),
              ),
              const Spacer(),
              MacosSwitch(
                value: category.isActive,
                activeColor: const MacosColor(0xFF007AFF),
                onChanged: (val) async {
                  try {
                    final daemonApi = ref.read(daemonApiProvider);
                    final categoryRepo = ref.read(categoryRepositoryProvider);
                    final updatedCategory = category.copyWith(isActive: val, syncStatus: 'staged');
                    await categoryRepo.updateCategory(updatedCategory);
                    await daemonApi.triggerSync();
                    
                    ref.invalidate(categoriesProvider);
                    ref.invalidate(rulesByCategoryProvider);
                  } catch (e) {
                    // Handled implicitly by daemonApi failure states, or talker.
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
