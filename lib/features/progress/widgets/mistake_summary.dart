import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../viewmodels/progress_viewmodel.dart';

/// Displays a summary of mistake patterns for the last 7 days.
///
/// Shows overall accuracy percentage, grammar mistakes count,
/// and vocabulary gaps count. Per D-15: summary only, no trend charts.
class MistakeSummary extends StatelessWidget {
  const MistakeSummary({
    super.key,
    required this.stats,
  });

  /// Mistake statistics to display.
  final MistakeStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPink.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mistake Summary',
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last 7 days',
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatItem(
                icon: Icons.check_circle_outline,
                label: 'Accuracy',
                value: '${stats.accuracyPercent.round()}%',
                color: stats.accuracyPercent >= 80
                    ? Colors.green
                    : stats.accuracyPercent >= 50
                        ? AppColors.accentGold
                        : AppColors.accentCoral,
              ),
              const SizedBox(width: 12),
              _StatItem(
                icon: Icons.rule_outlined,
                label: 'Grammar',
                value: '${stats.grammarMistakes}',
                color: AppColors.accentCoral,
              ),
              const SizedBox(width: 12),
              _StatItem(
                icon: Icons.translate_outlined,
                label: 'Vocabulary',
                value: '${stats.vocabularyGaps}',
                color: AppColors.primaryPinkDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
