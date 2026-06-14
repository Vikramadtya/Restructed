import 'package:flutter/material.dart';

/// A circular progress gauge that displays the user's gamified Focus Score.
class FocusScoreGauge extends StatelessWidget {
  final int score;

  const FocusScoreGauge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    Color getScoreColor() {
      if (score >= 80) return Colors.greenAccent;
      if (score >= 50) return Colors.orangeAccent;
      return Colors.redAccent;
    }

    return Container(
      width: 120,
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: getScoreColor().withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CircularProgressIndicator(
              value: score / 100.0,
              strokeWidth: 8,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(getScoreColor()),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                score.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: getScoreColor(),
                ),
              ),
              const Text(
                'Focus Score',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
