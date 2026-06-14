import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:macos_ui/macos_ui.dart';

class FocusScoreGauge extends StatelessWidget {
  final int score;
  const FocusScoreGauge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    Color getScoreColor() {
      if (score >= 80) return MacosColors.systemGreenColor;
      if (score >= 50) return MacosColors.systemOrangeColor;
      return MacosColors.systemRedColor;
    }

    String getScoreText() {
      if (score >= 80) return "Laser Focused";
      if (score >= 50) return "Needs Work";
      return "Distracted";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: getScoreColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: getScoreColor().withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: getScoreColor(),
              shape: BoxShape.circle,
            ),
            child: Text(
              score.toString(),
              style: const TextStyle(
                color: MacosColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Focus Score',
                style: MacosTheme.of(context).typography.caption1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: getScoreColor(),
                ),
              ),
              Text(
                getScoreText(),
                style: MacosTheme.of(context).typography.headline.copyWith(
                  fontWeight: FontWeight.bold,
                  color: getScoreColor(),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}
