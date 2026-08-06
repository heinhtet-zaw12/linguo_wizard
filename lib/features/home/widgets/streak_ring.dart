import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/theme/app_text_styles.dart';

/// Circular streak indicator showing flame icon and day count.
class StreakRing extends StatelessWidget {
  const StreakRing({super.key, required this.streakDays});

  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final isActive = streakDays > 0;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Ring
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppColors.warning.withValues(alpha: 0.2)
                  : AppColors.surfaceGlass,
              border: Border.all(
                color: isActive ? AppColors.warning : AppColors.borderSubtle,
                width: 3,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.local_fire_department,
                size: 28,
                color: isActive ? AppColors.warning : AppColors.textTertiary,
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
                  isActive ? '$streakDays Day Streak!' : 'Start Your Streak!',
                  style: AppTextStyles.headingMedium(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  isActive
                      ? 'Keep it going! Practice today.'
                      : 'Complete a scenario to start.',
                  style: AppTextStyles.labelMedium(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
