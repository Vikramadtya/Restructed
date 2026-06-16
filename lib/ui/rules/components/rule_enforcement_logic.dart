import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:gap/gap.dart';
import '../rule_dialog.dart' show RuleMode;

class RuleEnforcementLogic extends StatelessWidget {
  final RuleMode ruleMode;
  final ValueChanged<RuleMode> onRuleModeChanged;

  final bool isIndefinite;
  final ValueChanged<bool> onIndefiniteChanged;

  final TextEditingController durationController;
  final String durationUnit;
  final ValueChanged<String> onDurationUnitChanged;

  final List<int> scheduledDays;
  final ValueChanged<int> onDayToggled;

  final TimeOfDay? startTime;
  final ValueChanged<TimeOfDay?> onStartTimeChanged;
  final TimeOfDay? endTime;
  final ValueChanged<TimeOfDay?> onEndTimeChanged;

  const RuleEnforcementLogic({
    super.key,
    required this.ruleMode,
    required this.onRuleModeChanged,
    required this.isIndefinite,
    required this.onIndefiniteChanged,
    required this.durationController,
    required this.durationUnit,
    required this.onDurationUnitChanged,
    required this.scheduledDays,
    required this.onDayToggled,
    required this.startTime,
    required this.onStartTimeChanged,
    required this.endTime,
    required this.onEndTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader(context, LucideIcons.clock, 'Enforcement Logic'),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ruleMode == RuleMode.duration ? theme.colorScheme.primary : theme.colorScheme.surface,
                  foregroundColor: ruleMode == RuleMode.duration ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color,
                  elevation: ruleMode == RuleMode.duration ? 4 : 0,
                ),
                onPressed: () => onRuleModeChanged(RuleMode.duration),
                icon: const Icon(LucideIcons.timer, size: 16),
                label: const Text('Countdown Timer'),
              ),
            ),
            const Gap(8),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ruleMode == RuleMode.schedule ? theme.colorScheme.primary : theme.colorScheme.surface,
                  foregroundColor: ruleMode == RuleMode.schedule ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color,
                  elevation: ruleMode == RuleMode.schedule ? 4 : 0,
                ),
                onPressed: () => onRuleModeChanged(RuleMode.schedule),
                icon: const Icon(LucideIcons.calendarDays, size: 16),
                label: const Text('Recurring Schedule'),
              ),
            ),
          ],
        ),
        const Gap(24),
        if (ruleMode == RuleMode.duration)
          buildDurationSection(context)
        else
          buildScheduleSection(context),
      ],
    );
  }

  Widget buildDurationSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Indefinite Block', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Gap(4),
                  const Text('Keep this blocked forever until manually disabled.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Switch(
              value: isIndefinite,
              activeThumbColor: theme.colorScheme.primary,
              onChanged: onIndefiniteChanged,
            ),
          ],
        ),
        if (!isIndefinite) ...[
          const Gap(16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: durationController,
                  decoration: InputDecoration(
                    hintText: 'Value',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: durationUnit,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown),
                      items: ['Hours', 'Days', 'Weeks', 'Months']
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) onDurationUnitChanged(val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget buildScheduleSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Days',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Gap(16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 1; i <= 7; i++)
                GestureDetector(
                  onTap: () => onDayToggled(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: scheduledDays.contains(i) ? theme.colorScheme.primary.withValues(alpha: 0.2) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: scheduledDays.contains(i) ? theme.colorScheme.primary : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i - 1],
                      style: TextStyle(
                        color: scheduledDays.contains(i) ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
                        fontWeight: scheduledDays.contains(i) ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const Gap(32),
          const Text(
            'Active Hours',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.textTheme.bodyMedium?.color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: startTime ?? const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (time != null) {
                      onStartTimeChanged(time);
                    }
                  },
                  icon: const Icon(LucideIcons.sun, size: 16),
                  label: Text(startTime == null ? 'Start Time' : '${startTime!.hour}:${startTime!.minute.toString().padLeft(2, '0')}'),
                ),
              ),
              const Gap(16),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.textTheme.bodyMedium?.color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: endTime ?? const TimeOfDay(hour: 17, minute: 0),
                    );
                    if (time != null) {
                      onEndTimeChanged(time);
                    }
                  },
                  icon: const Icon(LucideIcons.moon, size: 16),
                  label: Text(endTime == null ? 'End Time' : '${endTime!.hour}:${endTime!.minute.toString().padLeft(2, '0')}'),
                ),
              ),
            ],
          ),
          if (startTime != null || endTime != null) ...[
            const Gap(16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  onStartTimeChanged(null);
                  onEndTimeChanged(null);
                },
                child: const Text('Clear Hours (All Day)'),
              ),
            ),
          ]
        ],
      ),
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
