import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// Flexible info row with optional icon and optional trailing value.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    this.icon,
    required this.label,
    this.value,
  });

  final IconData? icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSizing.iconMd, color: AppColors.textTertiary),
            const SizedBox(width: AppSpacing.s3),
          ],
          Expanded(
            child: Text(label, style: AppTextStyles.bodyMedium(color: AppColors.textSecondary)),
          ),
          if (value != null)
            Text(value!, style: AppTextStyles.labelLarge(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
