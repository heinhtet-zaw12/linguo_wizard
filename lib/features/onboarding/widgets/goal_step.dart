import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../models/onboarding_data.dart';

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
            style: GoogleFonts.fredoka(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll tailor scenarios to match',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
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
          color: isSelected ? AppColors.primaryPink : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryPink : AppColors.primaryPinkLight,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppColors.shadowPink : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
