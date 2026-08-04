import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_shadows.dart';

/// Glass-style card container.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.borderRadius,
    this.elevation = 1,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final int elevation;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final shadows = switch (elevation) {
      1 => AppShadows.elevation1,
      2 => AppShadows.elevation2,
      3 => AppShadows.elevation3,
      4 => AppShadows.elevation4,
      _ => AppShadows.elevation1,
    };

    return Container(
      padding: padding ?? AppSpacing.all4,
      decoration: BoxDecoration(
        color: color ?? AppColors.surfacePrimary,
        borderRadius: borderRadius ?? AppRadius.md,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : Border.all(color: AppColors.borderSubtle, width: 0.5),
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}
