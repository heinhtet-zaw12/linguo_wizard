import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../scenario_selection/models/scenario.dart';
import '../../scenario_selection/viewmodels/scenario_selection_viewmodel.dart';

/// Horizontal scrolling list of recommended scenario cards.
class ScenarioCards extends StatelessWidget {
  const ScenarioCards({super.key, required this.scenarios});

  final List<Scenario> scenarios;

  @override
  Widget build(BuildContext context) {
    if (scenarios.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowPink.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No scenarios available. Complete onboarding first!',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: scenarios.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final scenario = scenarios[index];
          return _HomeScenarioCard(scenario: scenario);
        },
      ),
    );
  }
}

/// A single scenario card for the home screen.
class _HomeScenarioCard extends ConsumerWidget {
  const _HomeScenarioCard({required this.scenario});

  final Scenario scenario;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedScenarioProvider.notifier).state = scenario;
        context.push('/conversation/${scenario.id}');
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowPink,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Color(0x99FFFFFF),
              blurRadius: 8,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CEFR badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                scenario.cefrLevel,
                style: GoogleFonts.fredoka(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Title
            Text(
              scenario.title,
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Persona
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: AppColors.primaryPink),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    scenario.personaName,
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryPinkDark,
                    ),
                    overflow: TextOverflow.ellipsis,
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
