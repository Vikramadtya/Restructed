import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

    return Scaffold(
      body: Column(
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
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Organize your blocking rules with categories.',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => showCategoryDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Add Category'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            onChanged: (val) =>
                ref.read(searchQueryProvider.notifier).setQuery(val),
            decoration: InputDecoration(
              hintText: 'Search categories...',
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
          const SizedBox(height: 24),
          Expanded(
            child: categoriesAsyncValue.when(
              data: (categories) {
                final filteredCategories = categories
                    .where(
                      (c) => c.name.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

                if (filteredCategories.isEmpty) {
                  return Center(
                    child: Text(
                      'No categories found.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    mainAxisExtent: 280,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final cat = filteredCategories[index];

                    int ruleCount = 0;
                    rulesAsyncValue.whenData((rules) {
                      ruleCount = rules
                          .where((r) => r.categoryId == cat.id)
                          .length;
                    });

                    return CategoryCard(category: cat, ruleCount: ruleCount);
                  },
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

class CategoryCard extends ConsumerWidget {
  final Category category;
  final int ruleCount;

  const CategoryCard({
    super.key,
    required this.category,
    required this.ruleCount,
  });

  Color getCategoryColor(String? name) {
    if (name == null) return Colors.grey;
    final lower = name.toLowerCase();
    if (lower.contains('social')) return const Color(0xFF8B5CF6); // Purple
    if (lower.contains('entertainment') || lower.contains('video')) {
      return const Color(0xFFEF4444); // Red
    }
    if (lower.contains('news')) return const Color(0xFF3B82F6); // Blue
    if (lower.contains('gaming')) return const Color(0xFF10B981); // Green
    if (lower.contains('shop')) return const Color(0xFFF59E0B); // Yellow
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = getCategoryColor(category.name);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        ref.read(selectedCategoryIdProvider.notifier).setCategory(category.id);
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                child: IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => showCategoryDialog(
                    context,
                    ref,
                    existingCategory: category,
                  ),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
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
                      : Icon(Icons.category, color: color, size: 28),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      category.name,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  if (category.syncStatus == 'failed')
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$ruleCount sites',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Spacer(),
              Switch(
                value: category.isActive,
                activeTrackColor: const Color(0xFF6366F1),
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
            ],
          ),
        ),
      ),
    );
  }
}
