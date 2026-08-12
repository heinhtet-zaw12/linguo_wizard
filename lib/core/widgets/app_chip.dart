import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_gradients.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

/// Glass-pill selection chip with selected/unselected states.
class GlassChip extends StatelessWidget {
  const GlassChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: AppSizing.chipHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.accent : null,
          color: selected ? null : AppColors.surfaceGlass,
          borderRadius: AppRadius.pill,
          border: Border.all(
            color: selected
                ? AppColors.accentStart
                : AppColors.borderGlow,
            width: 1,
          ),
          boxShadow: selected ? AppShadows.glowCyan : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelUppercase(
              color: selected
                  ? AppColors.textOnAccent
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
