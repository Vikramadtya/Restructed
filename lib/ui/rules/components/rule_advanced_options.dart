import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:gap/gap.dart';

class RuleAdvancedOptions extends StatelessWidget {
  final bool isStrictMode;
  final ValueChanged<bool> onStrictModeChanged;

  const RuleAdvancedOptions({
    super.key,
    required this.isStrictMode,
    required this.onStrictModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader(context, LucideIcons.sliders, 'Advanced Options'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Strict Mode (Nuclear Option)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    const Gap(4),
                    const Text('Forces you to type a paragraph to disable this rule later.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: isStrictMode,
                activeThumbColor: Colors.redAccent,
                onChanged: onStrictModeChanged,
              ),
            ],
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
