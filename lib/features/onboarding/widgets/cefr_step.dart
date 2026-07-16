import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../models/onboarding_data.dart';

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
            style: GoogleFonts.fredoka(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll match scenarios to your skill',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
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
        child: Row(
          children: [
            // Level badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : AppColors.accentGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  level,
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _description,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textDark,
                  height: 1.3,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 22)
            else
              Icon(Icons.circle_outlined, color: AppColors.primaryPinkLight, size: 22),
          ],
        ),
      ),
    );
  }
}
