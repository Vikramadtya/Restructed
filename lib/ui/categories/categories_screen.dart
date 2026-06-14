import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ).animate().fadeIn().slideX(),
                  const Gap(8),
                  const Text(
                    'Organize your blocking rules with categories.',
                    style: TextStyle(color: Colors.grey),
                  ).animate().fadeIn(delay: 100.ms),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => showCategoryDialog(context, ref),
              icon: const Icon(LucideIcons.plus),
              label: const Text('Add Category'),
            ).animate().scale(delay: 100.ms),
          ],
        ),
        const Gap(32),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search categories...',
            prefixIcon: const Icon(LucideIcons.search),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onChanged: (val) =>
              ref.read(searchQueryProvider.notifier).setQuery(val),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),
        const Gap(24),
        Expanded(
          child: filteredCategories.isEmpty && !isLoading
              ? Center(
                  child: Text(
                    'No categories found.',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
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

class CategoryCard extends ConsumerStatefulWidget {
  final Category category;
  final int ruleCount;

  const CategoryCard({
    super.key,
    required this.category,
    required this.ruleCount,
  });

  @override
  ConsumerState<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends ConsumerState<CategoryCard> {
  bool _isHovering = false;

  Color getCategoryColor(String? name) {
    if (name == null) return Colors.grey;
    final lower = name.toLowerCase();
    if (lower.contains('social')) return Colors.purpleAccent;
    if (lower.contains('entertainment') || lower.contains('video')) {
      return Colors.redAccent;
    }
    if (lower.contains('news')) return Colors.blueAccent;
    if (lower.contains('gaming')) return Colors.greenAccent;
    if (lower.contains('shop')) return Colors.orangeAccent;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final color = getCategoryColor(widget.category.name);
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () {
          ref.read(selectedCategoryIdProvider.notifier).setCategory(widget.category.id);
        },
        child: AnimatedContainer(
          duration: 200.ms,
          decoration: BoxDecoration(
            color: widget.category.isActive 
                ? theme.colorScheme.surface.withValues(alpha: 0.8) 
                : theme.colorScheme.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovering
                  ? theme.colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.05),
              width: _isHovering ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (_isHovering && widget.category.isActive)
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(
                          LucideIcons.edit2,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => showCategoryDialog(
                          context,
                          ref,
                          existingCategory: widget.category,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: widget.category.icon != null && widget.category.icon!.isNotEmpty
                            ? Text(
                                widget.category.icon!,
                                style: const TextStyle(fontSize: 32),
                              )
                            : Icon(LucideIcons.folder, color: color, size: 32),
                      ),
                    ),
                    const Gap(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            widget.category.name,
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.category.syncStatus == 'staged')
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        if (widget.category.syncStatus == 'failed')
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(LucideIcons.alertCircle, color: Colors.redAccent, size: 16),
                          ),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      '${widget.ruleCount} rules',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const Spacer(),
                    Switch(
                      value: widget.category.isActive,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (val) async {
                        try {
                          final daemonApi = ref.read(daemonApiProvider);
                          final categoryRepo = ref.read(categoryRepositoryProvider);
                          final updatedCategory = widget.category.copyWith(isActive: val, syncStatus: 'staged');
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
          ),
        ),
      ),
    );
  }
}
