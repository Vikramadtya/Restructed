import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as ep;
import 'package:logger/logger.dart';
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
    barrierLabel: 'Dismiss',
    pageBuilder: (context, animation, secondaryAnimation) {
      return CategoryDialogWrapper(existingCategory: existingCategory);
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
  final formKey = GlobalKey<FormState>();
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
    if (!formKey.currentState!.validate()) return;

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving category: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> deleteCategory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category?'),
        content: const Text(
            'This will permanently delete the category and ALL of its associated rules. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
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
      if (mounted) Navigator.of(context).pop();
    } catch (e, stack) {
      logger.e('Error deleting category', error: e, stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting category: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: 500,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.existingCategory == null
                          ? 'Add New Category'
                          : 'Edit Category',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Form(
                  key: formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              InkWell(
                                onTap: () => setState(
                                  () => showEmojiPicker = !showEmojiPicker,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: showEmojiPicker
                                          ? const Color(0xFF6366F1)
                                          : Colors.white12,
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
                                            Icons.add_reaction_outlined,
                                            size: 28,
                                            color: Colors.grey,
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Icon',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Category Name',
                                hintText: 'e.g. Social Media',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (val) =>
                                  val == null || val.trim().isEmpty
                                  ? 'Required'
                                  : null,
                              autofocus: widget.existingCategory == null,
                            ),
                          ),
                        ],
                      ),

                      if (showEmojiPicker) ...[
                        const SizedBox(height: 16),
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
                              config: const ep.Config(
                                checkPlatformCompatibility: true,
                                viewOrderConfig: ep.ViewOrderConfig(
                                  top: ep.EmojiPickerItem.searchBar,
                                  middle: ep.EmojiPickerItem.emojiView,
                                  bottom: ep.EmojiPickerItem.categoryBar,
                                ),
                                emojiViewConfig: ep.EmojiViewConfig(
                                  backgroundColor: Color(0xFF131A2C),
                                ),
                                categoryViewConfig: ep.CategoryViewConfig(
                                  backgroundColor: Color(0xFF131A2C),
                                  dividerColor: Colors.transparent,
                                ),
                                searchViewConfig: ep.SearchViewConfig(
                                  backgroundColor: Color(0xFF131A2C),
                                ),
                                bottomActionBarConfig: ep.BottomActionBarConfig(
                                  enabled: false,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                      TextFormField(
                        controller: descController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Material(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Enable Category',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: const Text(
                              'Turning this off instantly bypasses all rules inside.',
                              style: TextStyle(fontSize: 12),
                            ),
                            value: isActive,
                            onChanged: (val) => setState(() => isActive = val),
                            activeThumbColor: const Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.existingCategory != null &&
                        !widget.existingCategory!.isDefault)
                      TextButton.icon(
                        onPressed: isLoading ? null : deleteCategory,
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        label: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: isLoading ? null : saveCategory,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        backgroundColor: const Color(0xFF6366F1),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.existingCategory == null
                                  ? 'Create Category'
                                  : 'Update Category',
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
