import 'package:flutter/material.dart' hide Badge;

import '../../../core/config/badge_config.dart';
import '../../../core/models/badge.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/theme/app_text_styles.dart';

/// Displays all badge definitions in a 3-column grid.
class BadgeGrid extends StatelessWidget {
  const BadgeGrid({
    super.key,
    required this.earnedBadges,
  });

  final List<Badge> earnedBadges;

  @override
  Widget build(BuildContext context) {
    final earnedIds = earnedBadges.map((b) => b.id).toSet();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Badges',
            style: AppTextStyles.headingMedium(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            '${earnedIds.length} of ${badgeDefinitions.length} earned',
            style: AppTextStyles.labelSmall(color: AppColors.textTertiary),
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
    return GlassCard(
      padding: const EdgeInsets.all(10),
      glowColor: isEarned ? AppColors.warning.withValues(alpha: 0.2) : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isEarned ? Icons.emoji_events_rounded : Icons.emoji_events_outlined,
            color: isEarned ? AppColors.warning : AppColors.textTertiary,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: AppTextStyles.labelSmall(
              color: isEarned ? AppColors.textPrimary : AppColors.textTertiary,
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
