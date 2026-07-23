import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../scenario_selection/models/scenario.dart';
import '../../scenario_selection/viewmodels/scenario_selection_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';

/// Hero card on the Home dashboard showing today's Daily Challenge.
///
/// Displays a countdown timer, challenge description, and "Start Challenge"
/// button. Switches to a "Challenge Complete!" state with gold checkmark
/// once the user has completed today's challenge.
///
/// Countdown timer updates every minute via Timer.periodic. Timer is
/// cancelled in dispose() to prevent memory leaks (Pitfall 3 prevention).
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

  /// Skeleton placeholder shown while the challenge is loading.
  Widget _buildSkeleton() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: const Border(
          left: BorderSide(color: AppColors.accentGold, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPink.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }

  /// Main card layout per UI-SPEC Screen 3.
  Widget _buildCard(
    BuildContext context, {
    required Scenario scenario,
    required bool isCompleted,
  }) {
    final countdownText = ref.read(dailyChallengeServiceProvider)
        .formatCountdown(_timeRemaining);

    // Urgency: coral if less than 1 hour remaining.
    final isUrgent = _timeRemaining.inHours < 1 && _timeRemaining.inMinutes > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: const Border(
          left: BorderSide(color: AppColors.accentGold, width: 2),
        ),
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
          // ─── Row 1: Heading + 2x XP badge ───
          Row(
            children: [
              Text(
                "Today's Challenge",
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 10),
              // 2x XP pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentGold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '2x XP',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ─── Row 2: Challenge description ───
          Text(
            scenario.description,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // ─── Row 3: Countdown timer ───
          Text(
            countdownText,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isUrgent ? AppColors.accentCoral : AppColors.textMuted,
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

  /// Completed state: gold checkmark + "Challenge Complete! +100 XP"
  Widget _buildCompletedState() {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          size: 20,
          color: AppColors.accentGold,
        ),
        const SizedBox(width: 8),
        Text(
          'Challenge Complete! +100 XP',
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.accentGold,
          ),
        ),
      ],
    );
  }

  /// Primary action button that navigates to the conversation.
  Widget _buildStartButton(Scenario scenario) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ref.read(selectedScenarioProvider.notifier).state = scenario;
          context.push('/conversation/${scenario.id}');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPink,
          foregroundColor: AppColors.textLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
        child: Text(
          'Start Challenge',
          style: GoogleFonts.fredoka(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        ),
      ),
    );
  }
}
