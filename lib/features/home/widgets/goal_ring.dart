import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_text_styles.dart';

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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPink.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Progress ring
          SizedBox(
            width: 64,
            height: 64,
            child: CustomPaint(
              painter: _RingPainter(progress: progress),
              child: Center(
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: AppTextStyles.headingSmall(color: AppColors.primaryPinkDark),
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
                  style: AppTextStyles.headingMedium(color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  '$currentXp / $targetXp XP',
                  style: AppTextStyles.labelMedium(color: AppColors.primaryPinkDark),
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
      ..color = AppColors.primaryPinkLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = AppColors.primaryPink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
