import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Standard screen background with gradient.
/// Replaces the repeated LinearGradient decoration in every screen.
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
  });

  final Widget child;

  /// Custom gradient colors. Defaults to backgroundStart → backgroundMid → backgroundEnd.
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors ??
              [
                AppColors.backgroundStart,
                AppColors.backgroundMid,
                AppColors.backgroundEnd,
              ],
        ),
      ),
      child: child,
    );
  }
}
