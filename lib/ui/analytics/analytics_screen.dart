import 'dart:math';
import 'package:flutter/material.dart' show CircleAvatar, LinearProgressIndicator, Colors, Wrap, LayoutBuilder;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:gap/gap.dart';

import 'package:restructed/ui/core/app_providers.dart';
import 'package:restructed/backend/analytics/block_attempt.dart';

import 'widgets/summary_card.dart';
import 'widgets/heatmap_card.dart';
import 'widgets/time_of_day_card.dart';
import 'widgets/focus_score_gauge.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attemptsAsync = ref.watch(attemptsProvider);

    return attemptsAsync.when(
      data: (attempts) => _buildContent(context, ref, attempts, false),
      loading: () => Skeletonizer(
        enabled: true,
        child: _buildContent(context, ref, [], true),
      ),
      error: (e, s) => Center(child: Text('Error loading analytics: $e')),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<BlockAttempt> attempts,
    bool isLoading,
  ) {
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
    final int currentStreak = isLoading ? 5 : calculateCurrentStreak(attempts);
    final int bestStreak = isLoading ? 12 : calculateBestStreak(attempts);
    final int todayCount = isLoading ? 3 : todayAttempts.length;

    // Productivity Gamification (Focus Score)
    int focusScore = 50;
    focusScore += (currentStreak * 2);
    focusScore -= (todayCount * 5);

    final rulesAsync = ref.watch(rulesProvider);
    final hasScheduledRules = rulesAsync.maybeWhen(
      data: (rules) => rules.any(
        (r) => r.scheduledDays != null && r.scheduledDays!.isNotEmpty,
      ),
      orElse: () => false,
    );
    if (hasScheduledRules) focusScore += 10;

    focusScore = focusScore.clamp(0, 100);
    
    // Fallback domains for skeleton
    final displayDomains = isLoading && sortedDomains.isEmpty 
      ? [MapEntry('reddit.com', 45), MapEntry('twitter.com', 20)] 
      : sortedDomains;

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
                style: MacosTheme.of(context).typography.largeTitle.copyWith(fontWeight: FontWeight.bold),
              ).animate().fadeIn().slideX(),
              FocusScoreGauge(
                score: isLoading ? 85 : focusScore,
              ).animate().fadeIn().scale(),
            ],
          ),
          const Gap(24),

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
                      value: todayCount.toString(),
                      icon: LucideIcons.shieldAlert,
                      color: MacosColors.systemBlueColor,
                    ),
                  ),
                  SizedBox(
                    width: 250,
                    child: SummaryCard(
                      title: 'Current Streak',
                      value: '$currentStreak Days',
                      icon: LucideIcons.flame,
                      color: currentStreak > 0
                          ? MacosColors.systemOrangeColor
                          : MacosColors.systemGrayColor,
                    ),
                  ),
                  SizedBox(
                    width: 250,
                    child: SummaryCard(
                      title: 'Best Streak',
                      value: '$bestStreak Days',
                      icon: LucideIcons.award,
                      color: MacosColors.systemYellowColor,
                    ),
                  ),
                  SizedBox(
                    width: 250,
                    child: SummaryCard(
                      title: 'Total Blocks',
                      value: isLoading ? '120' : totalAttempts.toString(),
                      icon: LucideIcons.slash,
                      color: MacosColors.systemRedColor,
                    ),
                  ),
                ],
              );
            },
          ),
          const Gap(32),

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
          const Gap(32),

          Text(
            'Most Distracting Targets',
            style: MacosTheme.of(context).typography.title1.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 300.ms),
          const Gap(16),

          if (!isLoading && displayDomains.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'No blocked attempts yet! Great job focusing!',
                ),
              ),
            ).animate().fadeIn(delay: 400.ms)
          else
            Container(
              decoration: BoxDecoration(
                color: MacosTheme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: MacosColors.systemGrayColor.withValues(alpha: 0.2)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: min(displayDomains.length, 10),
                separatorBuilder: (context, index) =>
                    Container(height: 1, color: MacosColors.systemGrayColor.withValues(alpha: 0.2)),
                itemBuilder: (context, index) {
                  final e = displayDomains[index];
                  final percentage = totalAttempts > 0
                      ? (e.value / totalAttempts)
                      : (isLoading ? 0.6 : 0.0);
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: MacosColors.systemRedColor.withValues(alpha: 0.1),
                          child: const MacosIcon(
                            LucideIcons.globe,
                            color: MacosColors.systemRedColor,
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.key,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Gap(8),
                              Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: percentage,
                                      backgroundColor: MacosColors.systemGrayColor.withValues(alpha: 0.2),
                                      color: MacosColors.systemRedColor,
                                      minHeight: 6,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const Gap(16),
                                  Text(
                                    '${(percentage * 100).toStringAsFixed(1)}%',
                                    style: MacosTheme.of(context).typography.footnote,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Gap(16),
                        Text(
                          '${e.value} hits',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1);
                },
              ),
            ),
        ],
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
        final currentCleanDays = diff;
        if (currentCleanDays > bestStreak) bestStreak = currentCleanDays;
      }
    }

    return bestStreak;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
