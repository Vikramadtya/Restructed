import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restructed/ui/core/app_providers.dart';
import 'package:restructed/backend/analytics/block_attempt.dart';

import 'widgets/summary_card.dart';
import 'widgets/heatmap_card.dart';
import 'widgets/time_of_day_card.dart';
import 'widgets/focus_score_gauge.dart';

/// The primary analytics dashboard.
/// It observes state from [attemptsProvider] and computes
/// focus streaks, most distracted domains, and renders the extracted UI widgets.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attemptsAsync = ref.watch(attemptsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: attemptsAsync.when(
        data: (attempts) {
          final today = DateTime.now();
          final todayAttempts = attempts
              .where(
                (a) =>
                    a.attemptedAt.day == today.day &&
                    a.attemptedAt.month == today.month &&
                    a.attemptedAt.year == today.year,
              )
              .toList();

          // Domain counts
          final domainCounts = <String, int>{};
          for (var a in attempts) {
            domainCounts[a.domain] = (domainCounts[a.domain] ?? 0) + 1;
          }
          final sortedDomains = domainCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final totalAttempts = attempts.length;

          // Streak Logic
          final int currentStreak = calculateCurrentStreak(attempts);
          final int bestStreak = calculateBestStreak(attempts);

          // Productivity Gamification (Focus Score)
          int focusScore = 50;
          focusScore += (currentStreak * 2);
          focusScore -= (todayAttempts.length * 5);

          final rulesAsync = ref.watch(rulesProvider);
          final hasScheduledRules = rulesAsync.maybeWhen(
            data: (rules) => rules.any(
              (r) => r.scheduledDays != null && r.scheduledDays!.isNotEmpty,
            ),
            orElse: () => false,
          );
          if (hasScheduledRules) focusScore += 10;

          focusScore = focusScore.clamp(0, 100);

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Analytics Dashboard',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ).animate().fadeIn().slideX(),
                    FocusScoreGauge(
                      score: focusScore,
                    ).animate().fadeIn().scale(),
                  ],
                ),
                const SizedBox(height: 24),

                // Summary Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: 250,
                          child: SummaryCard(
                            title: 'Blocked Today',
                            value: todayAttempts.length.toString(),
                            icon: Icons.shield,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(
                          width: 250,
                          child: SummaryCard(
                            title: 'Current Streak',
                            value: '$currentStreak Days',
                            icon: Icons.local_fire_department,
                            color: currentStreak > 0
                                ? Colors.orange
                                : Colors.grey,
                          ),
                        ),
                        SizedBox(
                          width: 250,
                          child: SummaryCard(
                            title: 'Best Streak',
                            value: '$bestStreak Days',
                            icon: Icons.emoji_events,
                            color: Colors.amber,
                          ),
                        ),
                        SizedBox(
                          width: 250,
                          child: SummaryCard(
                            title: 'Total Blocks',
                            value: totalAttempts.toString(),
                            icon: Icons.block,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Heatmap and Charts Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 900;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: isWide
                              ? constraints.maxWidth * 0.58
                              : constraints.maxWidth,
                          child: HeatmapCard(
                            attempts: attempts,
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                        ),
                        SizedBox(
                          width: isWide
                              ? (constraints.maxWidth * 0.42) - 16
                              : constraints.maxWidth,
                          child: TimeOfDayCard(
                            attempts: attempts,
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                Text(
                  'Most Distracting Targets',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 16),

                if (sortedDomains.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No blocked attempts yet! Great job focusing!',
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms)
                else
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: min(sortedDomains.length, 10),
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        final e = sortedDomains[index];
                        final percentage = totalAttempts > 0
                            ? (e.value / totalAttempts)
                            : 0.0;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.public,
                              color: Colors.redAccent,
                            ),
                          ),
                          title: Text(
                            e.key,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: percentage,
                                    backgroundColor: Colors.grey.withValues(alpha:
                                      0.2,
                                    ),
                                    color: Colors.redAccent,
                                    minHeight: 6,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${(percentage * 100).toStringAsFixed(1)}%',
                                ),
                              ],
                            ),
                          ),
                          trailing: Text(
                            '${e.value} hits',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1);
                      },
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading analytics: $e')),
      ),
    );
  }

  int calculateCurrentStreak(List<BlockAttempt> attempts) {
    if (attempts.isEmpty) return 0;

    final today = DateTime.now();
    final todayAttempts = attempts.where(
      (a) => isSameDay(a.attemptedAt, today),
    );

    // If you failed today, streak is 0
    if (todayAttempts.isNotEmpty) return 0;

    int streak = 0;
    // Start counting backwards from yesterday
    DateTime iterDate = today.subtract(const Duration(days: 1));
    while (true) {
      final hasAttempt = attempts.any(
        (a) => isSameDay(a.attemptedAt, iterDate),
      );
      if (hasAttempt) break;
      streak++;
      iterDate = iterDate.subtract(const Duration(days: 1));
      if (streak > 365) break;
    }

    // Add 1 for today since today has no attempts
    return streak + 1;
  }

  int calculateBestStreak(List<BlockAttempt> attempts) {
    if (attempts.isEmpty) return 0;

    // Sort attempts from oldest to newest
    final sortedAttempts = attempts.toList()
      ..sort((a, b) => a.attemptedAt.compareTo(b.attemptedAt));

    int bestStreak = 0;

    DateTime? lastAttemptDate;

    for (final attempt in sortedAttempts) {
      final date = DateTime(
        attempt.attemptedAt.year,
        attempt.attemptedAt.month,
        attempt.attemptedAt.day,
      );
      if (lastAttemptDate == null) {
        lastAttemptDate = date;
        continue;
      }

      final diff = date.difference(lastAttemptDate).inDays;
      if (diff > 1) {
        // Gap of clean days!
        final cleanDays = diff - 1;
        if (cleanDays > bestStreak) bestStreak = cleanDays;
      }

      lastAttemptDate = date;
    }

    // Check gap between last attempt and today
    if (lastAttemptDate != null) {
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      final diff = today.difference(lastAttemptDate).inDays;
      if (diff > 0) {
        final currentCleanDays =
            diff; // No minus 1 because today is also clean if diff > 0 and no attempts today
        if (currentCleanDays > bestStreak) bestStreak = currentCleanDays;
      }
    }

    return bestStreak;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
