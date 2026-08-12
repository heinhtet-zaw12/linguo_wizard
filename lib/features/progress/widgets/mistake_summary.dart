import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../viewmodels/progress_viewmodel.dart';
import '../../../core/theme/app_text_styles.dart';

/// Displays a summary of mistake patterns for the last 7 days.
class MistakeSummary extends StatelessWidget {
  const MistakeSummary({
    super.key,
    required this.stats,
  });

  final MistakeStats stats;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: AppSpacing.all5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mistake Summary',
            style: AppTextStyles.headingMedium(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Last 7 days',
            style: AppTextStyles.labelSmall(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatItem(
                icon: Icons.check_circle_outline,
                label: 'Accuracy',
                value: '${stats.accuracyPercent.round()}%',
                color: stats.accuracyPercent >= 80
                    ? AppColors.success
                    : stats.accuracyPercent >= 50
                        ? AppColors.warning
                        : AppColors.danger,
              ),
              const SizedBox(width: 12),
              _StatItem(
                icon: Icons.rule_outlined,
                label: 'Grammar',
                value: '${stats.grammarMistakes}',
                color: AppColors.danger,
              ),
              const SizedBox(width: 12),
              _StatItem(
                icon: Icons.translate_outlined,
                label: 'Vocabulary',
                value: '${stats.vocabularyGaps}',
                color: AppColors.accentStart,
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
          borderRadius: AppRadius.sm,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.headingMedium(),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
