import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as ep;
import 'package:logger/logger.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:gap/gap.dart';

import 'package:restructed/backend/categories/category.dart';
import 'package:restructed/ui/core/app_providers.dart';
import 'package:restructed/backend/core/injection.dart';

void showCategoryDialog(
  BuildContext context,
  WidgetRef ref, {
  Category? existingCategory,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Category Dialog',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CategoryDialogWrapper(existingCategory: existingCategory),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          )),
          child: child,
        ),
      );
    },
  );
}

class CategoryDialogWrapper extends ConsumerStatefulWidget {
  final Category? existingCategory;

  const CategoryDialogWrapper({super.key, this.existingCategory});

  @override
  ConsumerState<CategoryDialogWrapper> createState() =>
      CategoryDialogWrapperState();
}

class CategoryDialogWrapperState extends ConsumerState<CategoryDialogWrapper> {
  final logger = getIt<Logger>();

  late TextEditingController nameController;
  late TextEditingController descController;

  String? selectedEmoji;
  bool isActive = true;
  bool isLoading = false;
  bool showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.existingCategory?.name ?? '',
    );
    descController = TextEditingController(
      text: widget.existingCategory?.description ?? '',
    );
    selectedEmoji = widget.existingCategory?.icon;
    isActive = widget.existingCategory?.isActive ?? true;
  }

  Future<void> saveCategory() async {
    if (nameController.text.trim().isEmpty) return;

    setState(() => isLoading = true);

    try {
      final name = nameController.text.trim();
      final cat = Category(
        id:
            widget.existingCategory?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        icon: selectedEmoji,
        description: descController.text.trim().isNotEmpty
            ? descController.text.trim()
            : null,
        isActive: isActive,
        isDefault: widget.existingCategory?.isDefault ?? false,
      );

      final daemonApi = ref.read(daemonApiProvider);
      final categoryRepo = ref.read(categoryRepositoryProvider);
      
      final stagedCategory = cat.copyWith(syncStatus: 'staged');

      if (widget.existingCategory == null) {
        await categoryRepo.createCategory(stagedCategory);
      } else {
        await categoryRepo.updateCategory(stagedCategory);
      }
      await daemonApi.triggerSync();

      ref.invalidate(categoriesProvider);
      ref.invalidate(rulesByCategoryProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e, stack) {
      logger.e('Error saving category', error: e, stackTrace: stack);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> deleteCategory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(LucideIcons.alertTriangle, color: Colors.redAccent, size: 64),
        title: const Text('Delete Category?'),
        content: const Text(
            'This will permanently delete the category and ALL of its associated rules. Are you sure?'),
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

    if (confirm != true) return;

    setState(() => isLoading = true);

    try {
      final daemonApi = ref.read(daemonApiProvider);
      final categoryRepo = ref.read(categoryRepositoryProvider);
      final ruleRepo = ref.read(ruleRepositoryProvider);

      // Delete all rules associated with this category
      final rules = await ruleRepo.getRulesByCategoryId(widget.existingCategory!.id);
      for (final rule in rules) {
        await ruleRepo.deleteRule(rule.id);
      }

      await categoryRepo.deleteCategory(widget.existingCategory!.id);
      await daemonApi.triggerSync();

      ref.invalidate(categoriesProvider);
      ref.invalidate(rulesByCategoryProvider);
      ref.invalidate(rulesProvider);
      if (mounted) {
        Navigator.of(context).pop(); // pop this dialog too
      }
    } catch (e, stack) {
      logger.e('Error deleting category', error: e, stackTrace: stack);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 500,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.existingCategory == null ? LucideIcons.folderPlus : LucideIcons.folderEdit,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const Gap(16),
                    Text(
                      widget.existingCategory == null ? 'Add New Category' : 'Edit Category',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Gap(32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () => setState(
                            () => showEmojiPicker = !showEmojiPicker,
                          ),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: showEmojiPicker
                                    ? theme.colorScheme.primary
                                    : Colors.white.withValues(alpha: 0.1),
                                width: showEmojiPicker ? 2.0 : 1.0,
                              ),
                            ),
                            child: Center(
                              child:
                                  selectedEmoji != null &&
                                      selectedEmoji!.isNotEmpty
                                  ? Text(
                                      selectedEmoji!,
                                      style: const TextStyle(
                                        fontSize: 32,
                                      ),
                                    )
                                  : const Icon(
                                      LucideIcons.smilePlus,
                                      size: 28,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                        ),
                        const Gap(8),
                        const Text(
                          'Icon',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Gap(24),
                    Expanded(
                      child: Column(
                        children: [
                          TextField(
                            controller: nameController,
                            autofocus: widget.existingCategory == null,
                            decoration: const InputDecoration(
                              labelText: 'Category Name',
                              hintText: 'e.g. Social Media',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const Gap(16),
                          TextField(
                            controller: descController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Description (Optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      
                if (showEmojiPicker) ...[
                  const Gap(16),
                  SizedBox(
                    height: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ep.EmojiPicker(
                        onEmojiSelected:
                            (ep.Category? category, ep.Emoji emoji) {
                              setState(() {
                                selectedEmoji = emoji.emoji;
                                showEmojiPicker = false;
                              });
                            },
                        config: ep.Config(
                          checkPlatformCompatibility: true,
                          emojiViewConfig: ep.EmojiViewConfig(
                            backgroundColor: theme.colorScheme.surface,
                          ),
                          categoryViewConfig: ep.CategoryViewConfig(
                            backgroundColor: theme.colorScheme.surface,
                          ),
                          bottomActionBarConfig: const ep.BottomActionBarConfig(
                            enabled: false,
                          ),
                          searchViewConfig: ep.SearchViewConfig(
                            backgroundColor: theme.colorScheme.surface,
                          )
                        ),
                      ),
                    ),
                  ),
                ],
      
                const Gap(24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enable Category',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Gap(4),
                            const Text(
                              'Turning this off instantly bypasses all rules inside.',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isActive,
                        activeColor: theme.colorScheme.primary,
                        onChanged: (val) => setState(() => isActive = val),
                      ),
                    ],
                  ),
                ),
                
                if (widget.existingCategory != null &&
                    !widget.existingCategory!.isDefault) ...[
                  const Gap(16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: isLoading ? null : deleteCategory,
                      icon: const Icon(LucideIcons.trash2, color: Colors.redAccent),
                      label: const Text('Delete Category', style: TextStyle(color: Colors.redAccent)),
                    ),
                  )
                ],
                const Gap(32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const Gap(16),
                    ElevatedButton(
                      onPressed: isLoading ? null : saveCategory,
                      child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              widget.existingCategory == null
                                  ? 'Create Category'
                                  : 'Update Category',
                            ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
