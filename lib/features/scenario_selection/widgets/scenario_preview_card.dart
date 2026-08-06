import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/cefr_badge.dart';
import '../../../core/widgets/info_row.dart';
import '../models/scenario.dart';
import '../../../core/theme/app_text_styles.dart';

/// A read-only preview card for a generated custom scenario.
///
/// Shows the scenario's title, persona, description, goal, and opening message
/// in a claymorphism card layout. No editing controls — per D-10.
class ScenarioPreviewCard extends StatelessWidget {
  const ScenarioPreviewCard({
    super.key,
    required this.scenario,
  });

  final Scenario scenario;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CEFR badge + category
          Row(
            children: [
              CefrBadge(level: scenario.cefrLevel),
              const SizedBox(width: 8),
              Text(
                scenario.category.toUpperCase(),
                style: AppTextStyles.labelSmall(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            scenario.title,
            style: AppTextStyles.headingLarge(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          // Persona
          InfoRow(
            icon: Icons.person_outline,
            label: scenario.personaName,
          ),
          const SizedBox(height: 8),
          // Description
          InfoRow(
            icon: Icons.description_outlined,
            label: scenario.personaDescription,
          ),
          const SizedBox(height: 8),
          // Goal
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.flag_outlined,
                    size: 16, color: AppColors.accentCyan),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    scenario.goalDescription,
                    style: AppTextStyles.labelMedium(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Opening message
          InfoRow(
            icon: Icons.chat_outlined,
            label: 'Opening: "${scenario.openingMessage}"',
          ),
          if (scenario.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: scenario.tags.map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tag,
                    style: AppTextStyles.labelSmall(color: AppColors.accentCyan),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
