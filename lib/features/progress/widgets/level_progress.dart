import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

/// Displays the user's current level with an animated progress bar.
///
/// Shows level name, progress fraction (0-100%), and XP remaining to next level.
class LevelProgress extends StatelessWidget {
  const LevelProgress({
    super.key,
    required this.levelName,
    required this.progress,
    required this.currentXp,
    required this.nextLevelXp,
  });

  /// Name of the current level (e.g. "Beginner", "Elementary").
  final String levelName;

  /// Progress fraction toward the next level (0.0 to 1.0).
  final double progress;

  /// Current total XP.
  final int currentXp;

  /// XP required for the next level.
  final int nextLevelXp;

  @override
  Widget build(BuildContext context) {
    final xpRemaining = nextLevelXp - currentXp;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level label and name
          Row(
            children: [
              Icon(
                Icons.school_rounded,
                color: AppColors.primaryPinkDark,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Level',
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              Text(
                levelName,
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Animated progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 12,
                  backgroundColor: AppColors.primaryPinkLight.withValues(alpha: 0.4),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // XP info
          Text(
            xpRemaining > 0
                ? '$currentXp / $nextLevelXp XP  ($xpRemaining XP to next level)'
                : '$currentXp XP  (Max level reached!)',
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
