import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/theme/app_text_styles.dart';

/// Displays the user's current level with an animated progress bar.
class LevelProgress extends StatelessWidget {
  const LevelProgress({
    super.key,
    required this.levelName,
    required this.progress,
    required this.currentXp,
    required this.nextLevelXp,
  });

  final String levelName;
  final double progress;
  final int currentXp;
  final int nextLevelXp;

  @override
  Widget build(BuildContext context) {
    final xpRemaining = nextLevelXp - currentXp;

    return GlassCard(
      padding: AppSpacing.all5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.school_rounded,
                color: AppColors.accentStart,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Level',
                style: AppTextStyles.labelMedium(color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                levelName,
                style: AppTextStyles.headingSmall(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Animated gradient progress bar
          ClipRRect(
            borderRadius: AppRadius.sm,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: AppRadius.sm,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: AppGradients.accent,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          Text(
            xpRemaining > 0
                ? '$currentXp / $nextLevelXp XP  ($xpRemaining XP to next level)'
                : '$currentXp XP  (Max level reached!)',
            style: AppTextStyles.labelSmall(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
