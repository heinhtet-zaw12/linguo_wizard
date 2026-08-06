import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../scenario_selection/models/scenario.dart';
import '../../scenario_selection/viewmodels/scenario_selection_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../../core/theme/app_text_styles.dart';

/// Hero card on the Home dashboard showing today's Daily Challenge.
///
/// Displays a countdown timer, challenge description, and "Start Challenge"
/// button. Switches to a "Challenge Complete!" state with checkmark
/// once the user has completed today's challenge.
class DailyChallengeCard extends ConsumerStatefulWidget {
  const DailyChallengeCard({super.key});

  @override
  ConsumerState<DailyChallengeCard> createState() => _DailyChallengeCardState();
}

class _DailyChallengeCardState extends ConsumerState<DailyChallengeCard> {
  Timer? _countdownTimer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final service = ref.read(dailyChallengeServiceProvider);
    setState(() {
      _timeRemaining = service.timeUntilNextChallenge;
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challengeState = ref.watch(dailyChallengeProvider);
    final completedState = ref.watch(challengeCompletedProvider);
    final isCompleted = completedState.valueOrNull ?? false;

    return challengeState.when(
      loading: () => _buildSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
      data: (scenario) {
        if (scenario == null) return const SizedBox.shrink();
        return _buildCard(context, scenario: scenario, isCompleted: isCompleted);
      },
    );
  }

  Widget _buildSkeleton() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: AppRadius.lg,
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required Scenario scenario,
    required bool isCompleted,
  }) {
    final countdownText = ref.read(dailyChallengeServiceProvider)
        .formatCountdown(_timeRemaining);

    final isUrgent = _timeRemaining.inHours < 1 && _timeRemaining.inMinutes > 0;

    return GlassCard(
      glowColor: AppColors.accentCyan.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Row 1: Heading + 2x XP badge ───
          Row(
            children: [
              Text(
                "Today's Challenge",
                style: AppTextStyles.headingMedium(color: AppColors.textPrimary),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: AppRadius.sm,
                ),
                child: Text(
                  '2x XP',
                  style: AppTextStyles.labelSmall(color: AppColors.surfaceBase),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ─── Row 2: Challenge description ───
          Text(
            scenario.description,
            style: AppTextStyles.labelMedium(color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // ─── Row 3: Countdown timer ───
          Text(
            countdownText,
            style: AppTextStyles.labelSmall(
              color: isUrgent ? AppColors.danger : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 14),

          // ─── Row 4: Action button or completed state ───
          if (isCompleted)
            _buildCompletedState()
          else
            _buildStartButton(scenario),
        ],
      ),
    );
  }

  Widget _buildCompletedState() {
    return Row(
      children: [
        const Icon(Icons.check_circle, size: 20, color: AppColors.success),
        const SizedBox(width: 8),
        Text(
          'Challenge Complete! +100 XP',
          style: AppTextStyles.labelMedium(color: AppColors.success),
        ),
      ],
    );
  }

  Widget _buildStartButton(Scenario scenario) {
    return AppButton(
      label: 'Start Challenge',
      onPressed: () {
        ref.read(selectedScenarioProvider.notifier).state = scenario;
        context.push('/conversation/${scenario.id}');
      },
    );
  }
}
