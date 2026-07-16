import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../models/onboarding_data.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What language are\nyou learning?',
            style: GoogleFonts.fredoka(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your target language',
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
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              name,
              style: GoogleFonts.quicksand(
                fontSize: 14,
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
