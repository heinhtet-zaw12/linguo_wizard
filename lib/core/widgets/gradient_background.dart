import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Standard screen background with animated mesh gradient.
/// Renders 3-4 static RadialGradient blobs on a Stack.
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background
        Container(color: AppColors.surfaceBase),
        // Blob 1: top-left, accentStart
        _blob(280, AppColors.accentStart, 0.07, -80, -40),
        // Blob 2: center-right, accentMid
        _blob(320, AppColors.accentMid, 0.05, 200, -60),
        // Blob 3: bottom-center, accentCyan
        _blob(260, AppColors.accentCyan, 0.06, -100, 80),
        // Content
        child,
      ],
    );
  }

  static Widget _blob(
    double size,
    Color color,
    double opacity,
    double left,
    double top,
  ) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
