import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/onboarding_data.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_shadows.dart';

/// Step 3: Pick a learning goal.
class GoalStep extends StatelessWidget {
  const GoalStep({
    super.key,
    required this.selectedGoal,
    required this.onSelected,
  });

  final String? selectedGoal;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's your goal?",
            style: AppTextStyles.displayMedium(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll tailor scenarios to match',
            style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: kGoals.map((entry) {
                final icon = entry.key;
                final label = entry.value;
                final isSelected = selectedGoal == label;
                return _GoalCard(
                  icon: icon,
                  label: label,
                  isSelected: isSelected,
                  onTap: () => onSelected(label),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String icon;
  final String label;
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
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 10),
            Text(
              label,
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
