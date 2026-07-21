import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/streak_ring.dart';
import '../widgets/goal_ring.dart';
import '../widgets/scenario_cards.dart';
import '../widgets/guest_banner.dart';

/// Home dashboard screen shown after onboarding.
///
/// Displays welcome header, streak, daily goal, recommended scenarios,
/// and a guest sign-up banner when appropriate.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(homeProvider);
    final isGuest = ref.watch(isGuestProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgTop, AppColors.bgBottom],
          ),
        ),
        child: SafeArea(
          child: asyncState.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            ),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to load data',
                    style: GoogleFonts.quicksand(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => ref.invalidate(homeProvider),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryPinkDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            data: (state) => _buildContent(context, ref, state, isGuest),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    HomeState state,
    bool isGuest,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(homeProvider.notifier).refresh();
      },
      color: AppColors.primaryPink,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Welcome Header ───
            Text(
              'Hello, ${state.displayName ?? 'Guest'}!',
              style: GoogleFonts.fredoka(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'What shall we practice today?',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),

            // ─── Guest Banner ───
            if (isGuest) ...[
              const GuestBanner(),
              const SizedBox(height: 16),
            ],

            // ─── Streak Ring ───
            StreakRing(streakDays: state.streakDays),
            const SizedBox(height: 12),

            // ─── Goal Ring ───
            GoalRing(currentXp: state.totalXp),
            const SizedBox(height: 20),

            // ─── Recommended Scenarios ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recommended',
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/scenarios'),
                  child: Text(
                    'Browse All',
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryPinkDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ─── Scenario Cards ───
            ScenarioCards(scenarios: state.recommendedScenarios),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
