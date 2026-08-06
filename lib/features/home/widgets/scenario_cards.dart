import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/theme/app_gradients.dart';
import '../../scenario_selection/models/scenario.dart';
import '../../scenario_selection/viewmodels/scenario_selection_viewmodel.dart';
import '../../../core/theme/app_text_styles.dart';

/// Horizontal scrolling list of recommended scenario cards.
class ScenarioCards extends StatelessWidget {
  const ScenarioCards({super.key, required this.scenarios});

  final List<Scenario> scenarios;

  @override
  Widget build(BuildContext context) {
    if (scenarios.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No scenarios available. Complete onboarding first!',
            style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
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
          return _HomeScenarioCard(scenario: scenario)
              .animate()
              .fadeIn(duration: 400.ms, delay: (index * 50).ms)
              .slideX(begin: 0.1, duration: 400.ms, delay: (index * 50).ms);
        },
      ),
    );
  }
}

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
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient top stripe
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: AppGradients.accent,
                  borderRadius: AppRadius.xxs,
                ),
              ),
              const SizedBox(height: 12),
              // CEFR badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withValues(alpha: 0.2),
                  borderRadius: AppRadius.sm,
                ),
                child: Text(
                  scenario.cefrLevel,
                  style: AppTextStyles.headingSmall(color: AppColors.accentCyan),
                ),
              ),
              const SizedBox(height: 10),
              // Title
              Expanded(
                child: Text(
                  scenario.title,
                  style: AppTextStyles.headingSmall(color: AppColors.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              // Persona
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: AppColors.accentMid),
                  const SizedBox(width: 4),
                  Expanded(
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
      ),
    );
  }
}
