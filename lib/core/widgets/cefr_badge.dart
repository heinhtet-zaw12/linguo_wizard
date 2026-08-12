import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_shadows.dart';
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
        color: AppColors.surfaceGlass,
        borderRadius: AppRadius.pill,
        border: Border.all(color: AppColors.accentCyan, width: 1),
        boxShadow: AppShadows.glowCyan,
      ),
      child: Text(
        level,
        style: AppTextStyles.labelUppercase(color: AppColors.accentCyan),
      ),
    );
  }
}
