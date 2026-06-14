import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:gap/gap.dart';

import 'package:restructed/ui/core/app_providers.dart';
import 'package:restructed/ui/dashboard/app_selector_dialog.dart';

class RuleBasicInfo extends ConsumerWidget {
  final String? categoryId;
  final ValueChanged<String?> onCategoryChanged;
  final bool isAppRule;
  final ValueChanged<bool> onAppRuleChanged;
  final TextEditingController domainController;
  final FocusNode domainFocusNode;
  final VoidCallback onFormatDomain;

  const RuleBasicInfo({
    super.key,
    required this.categoryId,
    required this.onCategoryChanged,
    required this.isAppRule,
    required this.onAppRuleChanged,
    required this.domainController,
    required this.domainFocusNode,
    required this.onFormatDomain,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader(LucideIcons.info, 'Basic Information'),
        categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'No categories available. Please create a category first.',
                  style: TextStyle(color: MacosColors.systemRedColor),
                ),
              );
            }

            return MacosPopupButton<String>(
              value: categoryId,
              hint: const Text('Select a category'),
              items: categories
                  .map(
                    (c) => MacosPopupMenuItem<String>(value: c.id, child: Text(c.name)),
                  )
                  .toList(),
              onChanged: onCategoryChanged,
            );
          },
          loading: () => const ProgressCircle(),
          error: (e, s) => Text('Error loading categories: $e'),
        ),
        const Gap(24),
        Container(
          decoration: BoxDecoration(
            color: MacosTheme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MacosColors.systemGrayColor.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Target Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Gap(12),
              Row(
                children: [
                  Expanded(
                    child: PushButton(
                      controlSize: ControlSize.large,
                      secondary: isAppRule,
                      onPressed: () => onAppRuleChanged(false),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MacosIcon(LucideIcons.globe, size: 16),
                          Gap(8),
                          Text('Website Domain'),
                        ],
                      ),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: PushButton(
                      controlSize: ControlSize.large,
                      secondary: !isAppRule,
                      onPressed: () => onAppRuleChanged(true),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MacosIcon(LucideIcons.monitor, size: 16),
                          Gap(8),
                          Text('macOS Application'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Gap(16),
        Row(
          children: [
            Expanded(
              child: MacosTextField(
                controller: domainController,
                focusNode: domainFocusNode,
                placeholder: isAppRule
                    ? 'App Name (e.g. Discord)'
                    : 'Website URL or Domain',
                prefix: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: MacosIcon(isAppRule ? LucideIcons.monitor : LucideIcons.globe, size: 16, color: MacosColors.systemGrayColor),
                ),
                suffix: isAppRule
                    ? MacosIconButton(
                        icon: const MacosIcon(LucideIcons.search, color: MacosColors.systemBlueColor, size: 16),
                        onPressed: () async {
                          final selectedApp = await showMacosAlertDialog<String>(
                            context: context,
                            builder: (ctx) => const AppSelectorDialog(),
                          );
                          if (selectedApp != null) {
                            domainController.text = selectedApp;
                          }
                        },
                      )
                    : MacosIconButton(
                        icon: const MacosIcon(
                          LucideIcons.wand2,
                          color: MacosColors.systemBlueColor,
                          size: 16,
                        ),
                        onPressed: onFormatDomain,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          MacosIcon(icon, color: MacosColors.systemBlueColor, size: 20),
          const Gap(8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: MacosColors.systemGrayColor,
            ),
          ),
        ],
      ),
    );
  }
}
