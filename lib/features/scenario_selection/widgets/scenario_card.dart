import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/cefr_badge.dart';
import '../models/scenario.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_shadows.dart';

/// A card displaying a scenario's title, description, CEFR badge, category,
/// featured badge, difficulty dots, and persona.
class ScenarioCard extends StatelessWidget {
  const ScenarioCard({
    super.key,
    required this.scenario,
    required this.onTap,
    this.trailing,
    this.showTwistBadge = false,
    this.onTwistTap,
  });

  final Scenario scenario;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showTwistBadge;
  final VoidCallback? onTwistTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gradient top stripe
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: AppGradients.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                // CEFR badge + category + featured badge
                Row(
                  children: [
                    CefrBadge(level: scenario.cefrLevel),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        scenario.category.toUpperCase(),
                        style: AppTextStyles.labelSmall(color: AppColors.textTertiary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (scenario.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 10, color: AppColors.warning),
                            const SizedBox(width: 2),
                            Text(
                              'Featured',
                              style: AppTextStyles.labelLarge(color: AppColors.warning),
                            ),
                          ],
                        ),
                      ),
                    ?trailing,
                  ],
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  scenario.title,
                  style: AppTextStyles.headingMedium(color: AppColors.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Description
                Expanded(
                  child: Text(
                    scenario.description,
                    style: AppTextStyles.labelMedium(color: AppColors.textSecondary),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                // Difficulty dots + persona
                Row(
                  children: [
                    ...List.generate(3, (i) {
                      final filled = i < scenario.difficultyRating.clamp(1, 5) / 2;
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled
                              ? AppColors.accentMid.withValues(alpha: 0.6)
                              : AppColors.borderSubtle,
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    Icon(Icons.person_outline, size: 14, color: AppColors.accentMid),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        scenario.personaName,
                        style: AppTextStyles.labelSmall(color: AppColors.textTertiary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Twist badge overlay (top-right corner)
          if (showTwistBadge && onTwistTap != null)
            Positioned(
              top: 0,
              right: 0,
              child: Tooltip(
                message: 'Play again with a twist',
                child: GestureDetector(
                  onTap: () {
                    onTwistTap?.call();
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(12),
                      ),
                      boxShadow: [AppShadows.glowCyan[0]],
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppColors.surfaceBase,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
