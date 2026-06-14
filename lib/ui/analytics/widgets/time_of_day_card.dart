import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:gap/gap.dart';
import 'package:restructed/backend/analytics/block_attempt.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MacosColors.systemGrayColor.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'When Are You Distracted?',
              style: MacosTheme.of(context).typography.title2.copyWith(fontWeight: FontWeight.bold),
            ),
            const Gap(32),
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
                          final style = MacosTheme.of(context).typography.caption1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: MacosColors.systemGrayColor,
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
                    makeGroup(0, morning.toDouble(), MacosColors.systemOrangeColor),
                    makeGroup(1, afternoon.toDouble(), MacosColors.systemBlueColor),
                    makeGroup(2, evening.toDouble(), MacosColors.systemPurpleColor),
                    makeGroup(3, night.toDouble(), MacosColors.systemIndigoColor),
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
