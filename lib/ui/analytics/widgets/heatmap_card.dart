import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:restructed/backend/analytics/block_attempt.dart';

class HeatmapCard extends StatelessWidget {
  final List<BlockAttempt> attempts;

  const HeatmapCard({super.key, required this.attempts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Generate data for last 30 days
    final today = DateTime.now();
    final heatmapData = <DateTime, int>{};
    int maxHits = 0;

    for (int i = 29; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final cleanDate = DateTime(date.year, date.month, date.day);
      final count = attempts
          .where(
            (a) =>
                a.attemptedAt.year == date.year &&
                a.attemptedAt.month == date.month &&
                a.attemptedAt.day == date.day,
          )
          .length;
      heatmapData[cleanDate] = count;
      if (count > maxHits) maxHits = count;
    }

    // Prepare grid items (7 rows for days of week, columns for weeks)
    final weeks = <List<MapEntry<DateTime, int>>>[];
    List<MapEntry<DateTime, int>> currentWeek = [];

    final entries = heatmapData.entries.toList();
    for (var entry in entries) {
      currentWeek.add(entry);
      if (entry.key.weekday == DateTime.sunday || entry == entries.last) {
        // Pad the start of the first week if necessary
        if (weeks.isEmpty &&
            currentWeek.length < 7 &&
            currentWeek.first.key.weekday != DateTime.monday) {
          final padding = currentWeek.first.key.weekday - 1; // monday = 1
          for (int i = 0; i < padding; i++) {
            currentWeek.insert(
              0,
              MapEntry(
                currentWeek.first.key.subtract(const Duration(days: 1)),
                -1,
              ),
            );
          }
        }
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distraction Intensity (Last 30 Days)',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Gap(32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day Labels
                    Padding(
                      padding: const EdgeInsets.only(top: 16, right: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          dayLabel('Mon'),
                          const Gap(14),
                          dayLabel('Wed'),
                          const Gap(14),
                          dayLabel('Fri'),
                          const Gap(14),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: weeks.map((week) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: Column(
                                children: List.generate(7, (index) {
                                  if (index < week.length) {
                                    final entry = week[index];
                                    if (entry.value == -1) {
                                      return const Gap(18, crossAxisExtent: 18); // Padding
                                    }
          
                                    final count = entry.value;
                                    final intensity = maxHits == 0
                                        ? 0.0
                                        : (count / maxHits);
                                    Color boxColor;
                                    if (count == 0) {
                                      boxColor = Colors.white.withValues(alpha: 0.05);
                                    } else {
                                      boxColor = Color.lerp(
                                        Colors.redAccent.withValues(alpha: 0.3),
                                        Colors.redAccent,
                                        intensity,
                                      )!;
                                    }
          
                                    return Tooltip(
                                      message:
                                          "${DateFormat('MMM d').format(entry.key)}: $count blocks",
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        margin: const EdgeInsets.only(bottom: 6),
                                        decoration: BoxDecoration(
                                          color: boxColor,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox(width: 18, height: 24);
                                }),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Focused',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Gap(8),
                    legendBox(Colors.white.withValues(alpha: 0.05)),
                    legendBox(Colors.redAccent.withValues(alpha: 0.3)),
                    legendBox(Colors.redAccent.withValues(alpha: 0.6)),
                    legendBox(Colors.redAccent),
                    const Gap(8),
                    const Text(
                      'Distracted',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dayLabel(String text) =>
      Text(text, style: const TextStyle(fontSize: 10, color: Colors.grey));

  Widget legendBox(Color color) => Container(
    width: 14,
    height: 14,
    margin: const EdgeInsets.symmetric(horizontal: 2),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(3),
    ),
  );
}
