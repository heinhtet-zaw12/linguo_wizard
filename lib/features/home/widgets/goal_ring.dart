import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';

/// Circular progress indicator showing daily XP goal progress.
class GoalRing extends StatelessWidget {
  const GoalRing({
    super.key,
    required this.currentXp,
    this.targetXp = 50,
  });

  final int currentXp;
  final int targetXp;

  @override
  Widget build(BuildContext context) {
    final progress = (currentXp / targetXp).clamp(0.0, 1.0);

    return GlassCard(
      padding: AppSpacing.all5,
      child: Row(
        children: [
          // Progress ring
          SizedBox(
            width: 64,
            height: 64,
            child: CustomPaint(
              painter: _RingPainter(progress: progress),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTextStyles.headingSmall(color: AppColors.accentCyan),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Goal',
                  style: AppTextStyles.headingMedium(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '$currentXp / $targetXp XP',
                  style: AppTextStyles.labelMedium(color: AppColors.warning),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Background ring
    final bgPaint = Paint()
      ..color = AppColors.borderSubtle
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = AppGradients.accent.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
