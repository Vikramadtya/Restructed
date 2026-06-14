import 'package:flutter/material.dart';

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
        buildSectionHeader(Icons.tune, 'Advanced Options'),
        SwitchListTile(
          title: const Text('Strict Mode (Nuclear Option)'),
          subtitle: const Text(
            'Forces you to type a paragraph to disable this rule later.',
          ),
          value: isStrictMode,
          activeTrackColor: const Color(0xFF6366F1),
          onChanged: onStrictModeChanged,
          activeThumbColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: Theme.of(context).colorScheme.surface,
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
