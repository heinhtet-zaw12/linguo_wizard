import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

/// Circular streak indicator showing flame icon and day count.
class StreakRing extends StatelessWidget {
  const StreakRing({super.key, required this.streakDays});

  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final isActive = streakDays > 0;

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
          // Ring
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppColors.accentGold.withValues(alpha: 0.2)
                  : AppColors.primaryPinkLight.withValues(alpha: 0.3),
              border: Border.all(
                color: isActive ? AppColors.accentGold : AppColors.primaryPinkLight,
                width: 3,
              ),
            ),
            child: Center(
              child: isActive
                  ? const Text('🔥', style: TextStyle(fontSize: 28))
                  : Icon(
                      Icons.local_fire_department_outlined,
                      size: 28,
                      color: AppColors.textMuted.withValues(alpha: 0.5),
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
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isActive
                      ? 'Keep it going! Practice today.'
                      : 'Complete a scenario to start.',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
