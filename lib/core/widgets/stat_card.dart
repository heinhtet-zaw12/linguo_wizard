import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

/// Stat card displaying an icon, value, and label.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.animate = true,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final card = Expanded(
      child: Container(
        padding: AppSpacing.all4,
        decoration: BoxDecoration(
          color: AppColors.surfacePrimary,
          borderRadius: AppRadius.md,
          boxShadow: AppShadows.elevation1,
        ),
        child: Column(
          children: [
            Icon(icon, size: AppSizing.iconLg, color: iconColor),
            const SizedBox(height: AppSpacing.s2),
            Text(value, style: AppTextStyles.displayMedium(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.s1),
            Text(label, style: AppTextStyles.labelMedium(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );

    if (!animate) return card;
    return card
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.15, duration: 400.ms, curve: Curves.easeOut);
  }
}
