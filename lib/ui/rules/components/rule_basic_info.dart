import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        buildSectionHeader(Icons.info_outline, 'Basic Information'),
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

            return DropdownButtonFormField<String>(
              initialValue: categoryId,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.folder_outlined),
              ),
              items: categories
                  .map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                  )
                  .toList(),
              onChanged: onCategoryChanged,
              validator: (val) =>
                  val == null ? 'Please select a category' : null,
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error loading categories: $e'),
        ),
        const SizedBox(height: 24),
        Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Target Type',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text('Website Domain'),
                        icon: Icon(Icons.language),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('macOS Application'),
                        icon: Icon(Icons.desktop_mac),
                      ),
                    ],
                    selected: {isAppRule},
                    onSelectionChanged: (Set<bool> newSelection) {
                      onAppRuleChanged(newSelection.first);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: domainController,
          focusNode: domainFocusNode,
          decoration: InputDecoration(
            labelText: isAppRule
                ? 'App Name (e.g. Discord)'
                : 'Website URL or Domain',
            hintText: isAppRule
                ? 'Select an application from your Mac'
                : 'Paste a full URL, we will extract the domain',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(isAppRule ? Icons.desktop_mac : Icons.language),
            suffixIcon: isAppRule
                ? IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF6366F1)),
                    tooltip: 'Browse Applications',
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
                    icon: const Icon(
                      Icons.auto_fix_high,
                      color: Color(0xFF6366F1),
                    ),
                    tooltip: 'Extract Domain',
                    onPressed: onFormatDomain,
                  ),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Target cannot be empty';
            }
            if (!isAppRule && val.contains('://') && val.endsWith(' ')) {
              return 'Please press the magic wand to extract the domain';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6366F1), size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
