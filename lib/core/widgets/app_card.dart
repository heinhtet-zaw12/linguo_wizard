import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_shadows.dart';

/// Glass-style card container with frosted backdrop blur.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.glowColor,
    this.elevation = 1,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? glowColor;
  final int elevation;

  @override
  Widget build(BuildContext context) {
    final shadows = switch (elevation) {
      2 => AppShadows.elevation2,
      3 => AppShadows.elevation3,
      _ => AppShadows.elevation1,
    };

    final radius = borderRadius ?? AppRadius.md;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? AppSpacing.all4,
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: radius,
            border: Border.all(
              color: glowColor ?? AppColors.borderSubtle,
              width: 0.5,
            ),
            boxShadow: [
              ...shadows,
              if (glowColor != null)
                BoxShadow(
                  color: glowColor!,
                  blurRadius: 20,
                  spreadRadius: -2,
                ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
