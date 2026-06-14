import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FocusScoreGauge extends StatelessWidget {
  final int score;
  const FocusScoreGauge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color getScoreColor() {
      if (score >= 80) return Colors.greenAccent;
      if (score >= 50) return Colors.orangeAccent;
      return Colors.redAccent;
    }

    String getScoreText() {
      if (score >= 80) return "Laser Focused 🎯";
      if (score >= 50) return "Needs Work 🚧";
      return "Distracted 🌪️";
    }

    return Container(
      decoration: BoxDecoration(
        color: getScoreColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: getScoreColor().withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: getScoreColor().withValues(alpha: 0.2),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: getScoreColor(),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: getScoreColor().withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    score.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Focus Score',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: getScoreColor(),
                      ),
                    ),
                    Text(
                      getScoreText(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: getScoreColor(),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
