import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader(LucideIcons.sliders, 'Advanced Options'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Strict Mode (Nuclear Option)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Gap(4),
                  Text('Forces you to type a paragraph to disable this rule later.', style: TextStyle(color: MacosColors.systemGrayColor, fontSize: 12)),
                ],
              ),
            ),
            MacosSwitch(
              value: isStrictMode,
              activeColor: const MacosColor(0xFFFF3B30),
              onChanged: onStrictModeChanged,
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
