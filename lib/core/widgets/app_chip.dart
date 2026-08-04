import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// Selection chip with selected/unselected states.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        height: AppSizing.chipHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentPrimary : AppColors.surfaceSecondary,
          borderRadius: AppRadius.sm,
          border: Border.all(
            color: isSelected ? AppColors.accentPrimary : AppColors.borderSubtle,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium(
              color: isSelected ? AppColors.textOnAccent : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
