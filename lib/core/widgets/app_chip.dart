import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// Glass-pill selection chip with selected/unselected states.
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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: AppSizing.chipHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentPrimary
              : AppColors.surfaceGlass,
          borderRadius: AppRadius.full,
          border: Border.all(
            color: isSelected
                ? AppColors.accentPrimary
                : AppColors.borderSubtle,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accentPrimary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.full,
          child: BackdropFilter(
            filter: isSelected
                ? ImageFilter.blur()
                : ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.labelMedium(
                  color: isSelected
                      ? AppColors.textOnAccent
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
