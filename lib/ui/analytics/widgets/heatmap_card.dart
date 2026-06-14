import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restructed/backend/analytics/block_attempt.dart';

/// A widget that displays a GitHub-style heatmap of blocked distraction attempts over the last 30 days.
class HeatmapCard extends StatelessWidget {
  final List<BlockAttempt> attempts;

  const HeatmapCard({super.key, required this.attempts});

  @override
  Widget build(BuildContext context) {
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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distraction Intensity (Last 30 Days)',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day Labels
                Padding(
                  padding: const EdgeInsets.only(top: 16, right: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      dayLabel('Mon'),
                      const SizedBox(height: 12),
                      dayLabel('Wed'),
                      const SizedBox(height: 12),
                      dayLabel('Fri'),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: weeks.map((week) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Column(
                            children: List.generate(7, (index) {
                              if (index < week.length) {
                                final entry = week[index];
                                if (entry.value == -1) {
                                  return const SizedBox(
                                    width: 14,
                                    height: 14,
                                  ); // Padding
                                }

                                final count = entry.value;
                                final intensity = maxHits == 0
                                    ? 0.0
                                    : (count / maxHits);
                                Color boxColor;
                                if (count == 0) {
                                  boxColor =
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white10
                                      : Colors.black12;
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
                                    width: 14,
                                    height: 14,
                                    margin: const EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      color: boxColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox(width: 14, height: 18);
                            }),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Focused',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                legendBox(
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
                ),
                legendBox(Colors.redAccent.withValues(alpha: 0.3)),
                legendBox(Colors.redAccent.withValues(alpha: 0.6)),
                legendBox(Colors.redAccent),
                const SizedBox(width: 8),
                const Text(
                  'Distracted',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget dayLabel(String text) =>
      Text(text, style: const TextStyle(fontSize: 10, color: Colors.grey));

  Widget legendBox(Color color) => Container(
    width: 12,
    height: 12,
    margin: const EdgeInsets.symmetric(horizontal: 2),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}
