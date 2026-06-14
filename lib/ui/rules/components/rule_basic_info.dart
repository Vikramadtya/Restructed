import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader(context, LucideIcons.info, 'Basic Information'),
        categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'No categories available. Please create a category first.',
                  style: TextStyle(color: Colors.redAccent),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: categoryId,
                  hint: const Text('Select a category'),
                  isExpanded: true,
                  icon: const Icon(LucideIcons.chevronDown),
                  items: categories
                      .map(
                        (c) => DropdownMenuItem<String>(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: onCategoryChanged,
                ),
              ),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error loading categories: $e'),
        ),
        const Gap(24),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isAppRule ? theme.colorScheme.primary : theme.colorScheme.surface,
                        foregroundColor: !isAppRule ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color,
                        elevation: !isAppRule ? 4 : 0,
                      ),
                      onPressed: () => onAppRuleChanged(false),
                      icon: const Icon(LucideIcons.globe, size: 16),
                      label: const Text('Website Domain'),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAppRule ? theme.colorScheme.primary : theme.colorScheme.surface,
                        foregroundColor: isAppRule ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color,
                        elevation: isAppRule ? 4 : 0,
                      ),
                      onPressed: () => onAppRuleChanged(true),
                      icon: const Icon(LucideIcons.monitor, size: 16),
                      label: const Text('macOS Application'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Gap(16),
        TextField(
          controller: domainController,
          focusNode: domainFocusNode,
          decoration: InputDecoration(
            hintText: isAppRule
                ? 'App Name (e.g. Discord)'
                : 'Website URL or Domain',
            prefixIcon: Icon(isAppRule ? LucideIcons.monitor : LucideIcons.globe, size: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: isAppRule
                ? IconButton(
                    icon: Icon(LucideIcons.search, color: theme.colorScheme.primary, size: 20),
                    onPressed: () async {
                      final selectedApp = await showDialog<String>(
                        context: context,
                        builder: (ctx) => const AppSelectorDialog(),
                      );
                      if (selectedApp != null) {
                        domainController.text = selectedApp;
                      }
                    },
                  )
                : IconButton(
                    icon: Icon(
                      LucideIcons.wand2,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    onPressed: onFormatDomain,
                  ),
          ),
        ),
      ],
    );
  }

  Widget buildSectionHeader(BuildContext context, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const Gap(8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
