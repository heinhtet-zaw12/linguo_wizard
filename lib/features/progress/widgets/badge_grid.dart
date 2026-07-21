import 'package:flutter/material.dart' hide Badge;
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/badge_config.dart';
import '../../../core/models/badge.dart';
import '../../../core/theme/app_theme.dart';

/// Displays all badge definitions in a 3-column grid.
///
/// Earned badges show in full color; unearned badges are greyed out.
class BadgeGrid extends StatelessWidget {
  const BadgeGrid({
    super.key,
    required this.earnedBadges,
  });

  /// List of badges the user has earned (matched by badge ID).
  final List<Badge> earnedBadges;

  @override
  Widget build(BuildContext context) {
    final earnedIds = earnedBadges.map((b) => b.id).toSet();

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
          Text(
            'Badges',
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${earnedIds.length} of ${badgeDefinitions.length} earned',
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: badgeDefinitions.length,
            itemBuilder: (context, index) {
              final definition = badgeDefinitions[index];
              final isEarned = earnedIds.contains(definition.id);
              return _BadgeCard(
                name: definition.name,
                description: definition.description,
                isEarned: isEarned,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.name,
    required this.description,
    required this.isEarned,
  });

  final String name;
  final String description;
  final bool isEarned;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isEarned
            ? AppColors.accentGold.withValues(alpha: 0.15)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isEarned
              ? AppColors.accentGold.withValues(alpha: 0.4)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isEarned ? Icons.emoji_events_rounded : Icons.emoji_events_outlined,
            color: isEarned ? AppColors.accentGold : Colors.grey.withValues(alpha: 0.4),
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isEarned ? AppColors.textDark : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
