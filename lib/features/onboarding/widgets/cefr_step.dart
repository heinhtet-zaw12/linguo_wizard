import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/onboarding_data.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_shadows.dart';

/// Step 2: Pick a CEFR level.
class CefrStep extends StatelessWidget {
  const CefrStep({
    super.key,
    required this.selectedLevel,
    required this.onSelected,
  });

  final String? selectedLevel;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's your level?",
            style: AppTextStyles.displayMedium(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll match scenarios to your skill',
            style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          // Level description cards
          Expanded(
            child: ListView.separated(
              itemCount: kCefrLevels.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final level = kCefrLevels[index];
                final isSelected = selectedLevel == level;
                return _CefrLevelCard(
                  level: level,
                  isSelected: isSelected,
                  onTap: () => onSelected(level),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CefrLevelCard extends StatelessWidget {
  const _CefrLevelCard({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  final String level;
  final bool isSelected;
  final VoidCallback onTap;

  String get _description {
    switch (level) {
      case 'A1':
        return 'Beginner — I know basic phrases';
      case 'A2':
        return 'Elementary — I can handle simple conversations';
      case 'B1':
        return 'Intermediate — I can discuss familiar topics';
      case 'B2':
        return 'Upper-Intermediate — I can express myself fluently';
      case 'C1':
        return 'Advanced — I can handle complex situations';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentStart.withValues(alpha: 0.15) : AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accentCyan : AppColors.borderSubtle,
            width: 1.5,
          ),
          boxShadow: isSelected ? AppShadows.glowBlue : AppShadows.elevation1,
        ),
        child: Row(
          children: [
            // Level badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentCyan.withValues(alpha: 0.25)
                    : AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  level,
                  style: AppTextStyles.headingMedium(
                    color: isSelected ? AppColors.textOnAccent : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _description,
                style: AppTextStyles.bodyMedium(
                  color: isSelected ? AppColors.textOnAccent : AppColors.textSecondary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.accentCyan, size: 22)
            else
              Icon(Icons.circle_outlined, color: AppColors.textTertiary, size: 22),
          ],
        ),
      ),
    );
  }
}
