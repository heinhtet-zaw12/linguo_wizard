import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/onboarding_data.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_shadows.dart';

/// Step 1: Pick a target language.
class LanguageStep extends StatelessWidget {
  const LanguageStep({
    super.key,
    required this.selectedLanguage,
    required this.onSelected,
  });

  final String? selectedLanguage;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontal6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What language are\nyou learning?',
            style: AppTextStyles.displayMedium(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your target language',
            style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: kLanguages.map((entry) {
                final flag = entry.key;
                final name = entry.value;
                final isSelected = selectedLanguage == name;
                return _LanguageCard(
                  flag: flag,
                  name: name,
                  isSelected: isSelected,
                  onTap: () => onSelected(name),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.flag,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String flag;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentStart.withValues(alpha: 0.15) : AppColors.surfaceGlass,
          borderRadius: AppRadius.lg,
          border: Border.all(
            color: isSelected ? AppColors.accentCyan : AppColors.borderSubtle,
            width: 1.5,
          ),
          boxShadow: isSelected ? AppShadows.glowBlue : AppShadows.elevation1,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              name,
              style: AppTextStyles.labelLarge(
                color: isSelected ? AppColors.textOnAccent : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
