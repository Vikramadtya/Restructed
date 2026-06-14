import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:restructed/backend/analytics/block_attempt.dart';

/// A widget that displays a bar chart showing what time of day the user is most distracted.
class TimeOfDayCard extends StatelessWidget {
  final List<BlockAttempt> attempts;

  const TimeOfDayCard({super.key, required this.attempts});

  @override
  Widget build(BuildContext context) {
    int morning = 0; // 6am - 12pm
    int afternoon = 0; // 12pm - 6pm
    int evening = 0; // 6pm - 12am
    int night = 0; // 12am - 6am

    for (var a in attempts) {
      final hour = a.attemptedAt.hour;
      if (hour >= 6 && hour < 12) {
        morning++;
      } else if (hour >= 12 && hour < 18) {
        afternoon++;
      } else if (hour >= 18 && hour < 24) {
        evening++;
      } else {
        night++;
      }
    }

    final maxVal = [morning, afternoon, evening, night].reduce(max).toDouble();
    final maxValueWithPadding = maxVal > 0 ? maxVal * 1.2 : 5.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'When Are You Distracted?',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValueWithPadding,
                  barTouchData: const BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          String text;
                          switch (value.toInt()) {
                            case 0:
                              text = 'Morning';
                              break;
                            case 1:
                              text = 'Afternoon';
                              break;
                            case 2:
                              text = 'Evening';
                              break;
                            case 3:
                              text = 'Night';
                              break;
                            default:
                              text = '';
                              break;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(text, style: style),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    makeGroup(0, morning.toDouble(), Colors.orangeAccent),
                    makeGroup(1, afternoon.toDouble(), Colors.blueAccent),
                    makeGroup(2, evening.toDouble(), Colors.deepPurpleAccent),
                    makeGroup(3, night.toDouble(), Colors.indigoAccent),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData makeGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: y == 0 ? 5 : y * 1.5,
            color: color.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}
