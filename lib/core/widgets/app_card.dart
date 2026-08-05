import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_shadows.dart';

/// Glass-style card container with frosted backdrop blur.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.borderRadius,
    this.elevation = 1,
    this.color,
    this.enableGlass = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final int elevation;
  final Color? color;
  final bool enableGlass;

  @override
  Widget build(BuildContext context) {
    final shadows = switch (elevation) {
      1 => AppShadows.elevation1,
      2 => AppShadows.elevation2,
      3 => AppShadows.elevation3,
      4 => AppShadows.elevation4,
      _ => AppShadows.elevation1,
    };

    final radius = borderRadius ?? AppRadius.md;
    final cardColor = color ?? AppColors.surfacePrimary;

    if (!enableGlass) {
      return _buildPlain(cardColor, radius, shadows);
    }

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding ?? AppSpacing.all4,
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? AppColors.borderSubtle,
              width: 0.5,
            ),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildPlain(
    Color cardColor,
    BorderRadius radius,
    List<BoxShadow> shadows,
  ) {
    return Container(
      padding: padding ?? AppSpacing.all4,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: radius,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : Border.all(color: AppColors.borderSubtle, width: 0.5),
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}
