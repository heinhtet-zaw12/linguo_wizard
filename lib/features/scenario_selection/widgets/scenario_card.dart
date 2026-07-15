import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../conversation/models/scenario.dart';

/// A card displaying a scenario's title, description, CEFR badge, and category.
class ScenarioCard extends StatelessWidget {
  const ScenarioCard({
    super.key,
    required this.scenario,
    required this.onTap,
  });

  final Scenario scenario;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowPink,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
            BoxShadow(
              color: Color(0x99FFFFFF),
              blurRadius: 8,
              offset: Offset(0, -3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CEFR badge + category
            Row(
              children: [
                _CefrBadge(level: scenario.cefrLevel),
                const SizedBox(width: 8),
                Text(
                  scenario.category.toUpperCase(),
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              scenario.title,
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Description
            Expanded(
              child: Text(
                scenario.description,
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            // Persona hint
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: AppColors.primaryPink),
                const SizedBox(width: 4),
                Text(
                  scenario.personaName,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryPinkDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CefrBadge extends StatelessWidget {
  const _CefrBadge({required this.level});
  final String level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        level,
        style: GoogleFonts.fredoka(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}
