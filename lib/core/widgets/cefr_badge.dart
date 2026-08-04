import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// CEFR level badge (A1, A2, B1, B2, C1).
class CefrBadge extends StatelessWidget {
  const CefrBadge({super.key, required this.level});
  final String level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s2,
        vertical: AppSpacing.s1,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentSecondary.withValues(alpha: 0.25),
        borderRadius: AppRadius.sm,
      ),
      child: Text(
        level,
        style: AppTextStyles.labelSmall(color: AppColors.textPrimary),
      ),
    );
  }
}
