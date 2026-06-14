import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:macos_ui/macos_ui.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader(LucideIcons.clock, 'Enforcement Logic'),
        Row(
          children: [
            Expanded(
              child: PushButton(
                controlSize: ControlSize.large,
                secondary: ruleMode != RuleMode.duration,
                onPressed: () => onRuleModeChanged(RuleMode.duration),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MacosIcon(LucideIcons.timer, size: 16),
                    Gap(8),
                    Text('Countdown Timer'),
                  ],
                ),
              ),
            ),
            const Gap(8),
            Expanded(
              child: PushButton(
                controlSize: ControlSize.large,
                secondary: ruleMode != RuleMode.schedule,
                onPressed: () => onRuleModeChanged(RuleMode.schedule),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MacosIcon(LucideIcons.calendarDays, size: 16),
                    Gap(8),
                    Text('Recurring Schedule'),
                  ],
                ),
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
                  Text('Keep this blocked forever until manually disabled.', style: TextStyle(color: MacosColors.systemGrayColor, fontSize: 12)),
                ],
              ),
            ),
            MacosSwitch(
              value: isIndefinite,
              activeColor: const MacosColor(0xFF007AFF),
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
                child: MacosTextField(
                  controller: durationController,
                  placeholder: 'Value',
                ),
              ),
              const Gap(16),
              Expanded(
                flex: 3,
                child: MacosPopupButton<String>(
                  value: durationUnit,
                  items: ['Hours', 'Days', 'Weeks', 'Months']
                      .map((u) => MacosPopupMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) onDurationUnitChanged(val);
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget buildScheduleSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MacosColors.systemGrayColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Days',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Gap(12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 1; i <= 7; i++)
                GestureDetector(
                  onTap: () => onDayToggled(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: scheduledDays.contains(i) ? MacosColors.systemBlueColor.withValues(alpha: 0.2) : MacosColors.systemGrayColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: scheduledDays.contains(i) ? MacosColors.systemBlueColor : MacosColors.systemGrayColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i - 1],
                      style: TextStyle(
                        color: scheduledDays.contains(i) ? MacosColors.systemBlueColor : MacosTheme.of(context).typography.body.color,
                        fontWeight: scheduledDays.contains(i) ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const Gap(20),
          const Text(
            'Active Hours (macOS native time picker to be implemented)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: PushButton(
                  controlSize: ControlSize.large,
                  secondary: true,
                  onPressed: () {
                    // Time picker not fully available in macos_ui, usually requires custom widget
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const MacosIcon(LucideIcons.sun, size: 16),
                      const Gap(8),
                      Text(startTime == null ? 'Start Time' : '${startTime!.hour}:${startTime!.minute.toString().padLeft(2, '0')}'),
                    ],
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: PushButton(
                  controlSize: ControlSize.large,
                  secondary: true,
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const MacosIcon(LucideIcons.moon, size: 16),
                      const Gap(8),
                      Text(endTime == null ? 'End Time' : '${endTime!.hour}:${endTime!.minute.toString().padLeft(2, '0')}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (startTime != null || endTime != null) ...[
            const Gap(12),
            Align(
              alignment: Alignment.centerRight,
              child: PushButton(
                controlSize: ControlSize.small,
                secondary: true,
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
