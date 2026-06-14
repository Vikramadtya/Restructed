import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as ep;
import 'package:logger/logger.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gap/gap.dart';

import 'package:restructed/backend/categories/category.dart';
import 'package:restructed/ui/core/app_providers.dart';
import 'package:restructed/backend/core/injection.dart';

void showCategoryDialog(
  BuildContext context,
  WidgetRef ref, {
  Category? existingCategory,
}) {
  showMacosAlertDialog(
    context: context,
    builder: (context) {
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
    final confirm = await showMacosAlertDialog<bool>(
      context: context,
      builder: (ctx) => MacosAlertDialog(
        appIcon: const MacosIcon(LucideIcons.alertTriangle, color: MacosColors.systemRedColor, size: 64),
        title: const Text('Delete Category?'),
        message: const Text(
            'This will permanently delete the category and ALL of its associated rules. Are you sure?'),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          color: MacosColors.systemRedColor,
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
        secondaryButton: PushButton(
          controlSize: ControlSize.large,
          secondary: true,
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
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
    return MacosAlertDialog(
      appIcon: MacosIcon(
        widget.existingCategory == null ? LucideIcons.folderPlus : LucideIcons.folderEdit,
        size: 56,
      ),
      title: Text(
        widget.existingCategory == null
            ? 'Add New Category'
            : 'Edit Category',
      ),
      message: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        color: MacosTheme.of(context).canvasColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: showEmojiPicker
                              ? MacosColors.systemBlueColor
                              : MacosColors.systemGrayColor.withValues(alpha: 0.2),
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
                            : const MacosIcon(
                                LucideIcons.smilePlus,
                                size: 28,
                                color: MacosColors.systemGrayColor,
                              ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  const Text(
                    'Icon',
                    style: TextStyle(
                      fontSize: 12,
                      color: MacosColors.systemGrayColor,
                    ),
                  ),
                ],
              ),
              const Gap(24),
              Expanded(
                child: Column(
                  children: [
                    MacosTextField(
                      controller: nameController,
                      placeholder: 'Category Name (e.g. Social Media)',
                      autofocus: widget.existingCategory == null,
                    ),
                    const Gap(16),
                    MacosTextField(
                      controller: descController,
                      placeholder: 'Description (Optional)',
                      maxLines: 2,
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
                  config: const ep.Config(
                    checkPlatformCompatibility: true,
                    viewOrderConfig: ep.ViewOrderConfig(
                      top: ep.EmojiPickerItem.searchBar,
                      middle: ep.EmojiPickerItem.emojiView,
                      bottom: ep.EmojiPickerItem.categoryBar,
                    ),
                    bottomActionBarConfig: ep.BottomActionBarConfig(
                      enabled: false,
                    ),
                  ),
                ),
              ),
            ),
          ],

          const Gap(24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enable Category',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Gap(4),
                    const Text(
                      'Turning this off instantly bypasses all rules inside.',
                      style: TextStyle(fontSize: 12, color: MacosColors.systemGrayColor),
                    ),
                  ],
                ),
              ),
              MacosSwitch(
                value: isActive,
                onChanged: (val) => setState(() => isActive = val),
              ),
            ],
          ),
          
          if (widget.existingCategory != null &&
              !widget.existingCategory!.isDefault) ...[
            const Gap(16),
            Align(
              alignment: Alignment.centerRight,
              child: PushButton(
                controlSize: ControlSize.regular,
                secondary: true,
                onPressed: isLoading ? null : deleteCategory,
                child: const Text('Delete Category', style: TextStyle(color: MacosColors.systemRedColor)),
              ),
            )
          ]
        ],
      ),
      primaryButton: PushButton(
        controlSize: ControlSize.large,
        onPressed: isLoading ? null : saveCategory,
        child: isLoading
            ? const ProgressCircle()
            : Text(
                widget.existingCategory == null
                    ? 'Create Category'
                    : 'Update Category',
              ),
      ),
      secondaryButton: PushButton(
        controlSize: ControlSize.large,
        secondary: true,
        onPressed: isLoading
            ? null
            : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
    );
  }
}
