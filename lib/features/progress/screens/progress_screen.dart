import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/level_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/app_button.dart';
import '../viewmodels/progress_viewmodel.dart';
import '../widgets/badge_grid.dart';
import '../widgets/level_progress.dart';
import '../widgets/mistake_summary.dart';
import '../../../core/theme/app_text_styles.dart';

/// Progress tab screen displaying gamification stats.
///
/// Shows level progress, XP, streak, badges earned, and mistake summary.
/// Accessible as one of the 4 bottom nav tabs (per D-01).
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(progressViewModelProvider);

    return Scaffold(
      body: GradientBackground(
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
                    'Failed to load progress',
                    style: AppTextStyles.bodyMedium(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => ref.invalidate(progressViewModelProvider),
                    child: Text(
                      'Retry',
                      style: AppTextStyles.labelLarge(color: AppColors.primaryPinkDark),
                    ),
                  ),
                ],
              ),
            ),
            data: (state) => _buildContent(context, ref, state),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ProgressState state) {
    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 48,
                color: AppColors.textMuted.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                state.error!,
                style: AppTextStyles.bodyMedium(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(progressViewModelProvider.notifier).refresh();
      },
      color: AppColors.primaryPink,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ───
            Text(
              'Your Progress',
              style: AppTextStyles.displayMedium(color: AppColors.textDark),
            ),
            const SizedBox(height: 20),

            // ─── Level Progress ───
            _buildLevelProgress(state),
            const SizedBox(height: 16),

            // ─── Stats Row ───
            _buildStatsRow(state),
            const SizedBox(height: 20),

            // ─── Badge Grid ───
            BadgeGrid(earnedBadges: state.earnedBadges),
            const SizedBox(height: 20),

            // ─── Mistake Summary ───
            MistakeSummary(stats: state.mistakeStats),
            const SizedBox(height: 20),

            // ─── Leaderboard Button ───
            _buildLeaderboardButton(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelProgress(ProgressState state) {
    // Determine next level XP.
    final levels = LevelConfig.levels;
    final nextLevelIndex = (state.currentLevel + 1).clamp(0, levels.length - 1);
    final nextLevelXp = levels[nextLevelIndex].xpRequired;

    return LevelProgress(
      levelName: state.levelName,
      progress: state.levelProgress,
      currentXp: state.totalXp,
      nextLevelXp: nextLevelXp,
    );
  }

  Widget _buildStatsRow(ProgressState state) {
    return Row(
      children: [
        StatCard(
          icon: Icons.local_fire_department_rounded,
          iconColor: AppColors.accentGold,
          value: '${state.currentStreak}',
          label: 'Day Streak',
        ),
        const SizedBox(width: 12),
        StatCard(
          icon: Icons.star_rounded,
          iconColor: AppColors.primaryPink,
          value: '${state.totalXp}',
          label: 'Total XP',
        ),
        const SizedBox(width: 12),
        StatCard(
          icon: Icons.check_circle_outline_rounded,
          iconColor: Colors.green,
          value: '${state.scenariosCompleted}',
          label: 'Scenarios',
        ),
      ],
    );
  }

  Widget _buildLeaderboardButton(BuildContext context) {
    return AppButton(
      label: 'View Leaderboard',
      variant: AppButtonVariant.secondary,
      icon: Icons.leaderboard_rounded,
      onPressed: () => context.push('/leaderboard'),
    );
  }
}
