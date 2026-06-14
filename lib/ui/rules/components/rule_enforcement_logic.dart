import 'package:flutter/material.dart';
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
        buildSectionHeader(Icons.schedule, 'Enforcement Logic'),
        SegmentedButton<RuleMode>(
          segments: const [
            ButtonSegment(
              value: RuleMode.duration,
              icon: Icon(Icons.timer),
              label: Text('Countdown Timer'),
            ),
            ButtonSegment(
              value: RuleMode.schedule,
              icon: Icon(Icons.calendar_month),
              label: Text('Recurring Schedule'),
            ),
          ],
          selected: {ruleMode},
          onSelectionChanged: (Set<RuleMode> newSelection) {
            onRuleModeChanged(newSelection.first);
          },
        ),
        const SizedBox(height: 24),
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
        SwitchListTile(
          title: const Text('Indefinite Block'),
          subtitle: const Text(
            'Keep this blocked forever until manually disabled.',
          ),
          value: isIndefinite,
          onChanged: onIndefiniteChanged,
          activeThumbColor: const Color(0xFF6366F1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: Theme.of(context).colorScheme.surface,
        ),
        if (!isIndefinite) ...[
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: durationController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Value',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Required';
                    if (double.tryParse(val) == null) return 'Invalid number';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  initialValue: durationUnit,
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ['Hours', 'Days', 'Weeks', 'Months']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Days',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 1; i <= 7; i++)
                FilterChip(
                  label: Text(
                    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i - 1],
                  ),
                  selected: scheduledDays.contains(i),
                  selectedColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  checkmarkColor: const Color(0xFF6366F1),
                  onSelected: (_) => onDayToggled(i),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Active Hours',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime:
                          startTime ?? const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (t != null) onStartTimeChanged(t);
                  },
                  icon: const Icon(Icons.wb_sunny_outlined, size: 18),
                  label: Text(
                    startTime == null
                        ? 'Start Time'
                        : startTime!.format(context),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime:
                          endTime ?? const TimeOfDay(hour: 17, minute: 0),
                    );
                    if (t != null) onEndTimeChanged(t);
                  },
                  icon: const Icon(Icons.nights_stay_outlined, size: 18),
                  label: Text(
                    endTime == null ? 'End Time' : endTime!.format(context),
                  ),
                ),
              ),
            ],
          ),
          if (startTime != null || endTime != null)
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
        ],
      ),
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
