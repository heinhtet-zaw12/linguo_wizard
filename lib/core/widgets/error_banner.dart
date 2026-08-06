import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// Reusable error banner for displaying error messages.
/// Used in auth screens and other forms.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.padding = const EdgeInsets.all(12),
  });

  final String message;
  final VoidCallback? onDismiss;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.15),
        borderRadius: AppRadius.md,
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: AppColors.danger,
          ),
          const SizedBox(width: AppSpacing.s2),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.labelMedium(color: AppColors.danger),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.danger,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}
