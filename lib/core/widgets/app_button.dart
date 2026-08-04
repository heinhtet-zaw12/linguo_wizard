import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// Unified button component with multiple variants.
enum AppButtonVariant { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final button = switch (variant) {
      AppButtonVariant.primary => _buildPrimary(),
      AppButtonVariant.secondary => _buildSecondary(),
      AppButtonVariant.ghost => _buildGhost(),
    };

    if (isExpanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Widget _buildPrimary() {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentPrimary,
        disabledBackgroundColor: AppColors.accentPrimaryLight,
        foregroundColor: AppColors.textOnAccent,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
        elevation: 2,
        shadowColor: AppColors.shadowColor,
      ),
      child: _buildChild(AppColors.textOnAccent),
    );
  }

  Widget _buildSecondary() {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: AppColors.borderSubtle, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      ),
      child: _buildChild(AppColors.textPrimary),
    );
  }

  Widget _buildGhost() {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildChild(AppColors.accentPrimary),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }

    final textStyle = AppTextStyles.labelLarge(color: color);

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizing.iconLg, color: color),
          const SizedBox(width: AppSpacing.s2),
          Text(label, style: textStyle),
        ],
      );
    }

    return Text(label, style: textStyle);
  }
}
