import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/app_card.dart';
import '../viewmodels/leaderboard_viewmodel.dart';
import '../../../core/theme/app_text_styles.dart';

/// Full-screen leaderboard showing top users ranked by XP.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEntries = ref.watch(leaderboardViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: AppTextStyles.headingLarge(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: GradientBackground(
        child: asyncEntries.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accentStart),
          ),
          error: (e, _) => Center(
            child: Text(
              'Failed to load leaderboard',
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
            ),
          ),
          data: (entries) {
            if (entries.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.leaderboard_outlined,
                      size: 48,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No entries yet',
                      style: AppTextStyles.bodyLarge(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complete scenarios to appear here!',
                      style: AppTextStyles.labelMedium(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.read(leaderboardViewModelProvider.notifier).refresh();
              },
              color: AppColors.accentStart,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: 8),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return _LeaderboardTile(entry: entry);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final isTop3 = entry.rank <= 3;
    final rankColor = entry.rank == 1
        ? AppColors.warning // Gold
        : entry.rank == 2
            ? AppColors.textSecondary // Silver
            : entry.rank == 3
                ? AppColors.accentStart // Bronze (blue-violet)
                : AppColors.textTertiary;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      glowColor: entry.isCurrentUser
          ? AppColors.accentCyanGlow.withValues(alpha: 0.3)
          : null,
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTop3 ? rankColor.withValues(alpha: 0.2) : Colors.transparent,
            ),
            child: Center(
              child: isTop3
                  ? Icon(
                      entry.rank == 1
                          ? Icons.emoji_events_rounded
                          : Icons.emoji_events_outlined,
                      color: rankColor,
                      size: 18,
                    )
                  : Text(
                      '${entry.rank}',
                      style: AppTextStyles.headingSmall(color: AppColors.textTertiary),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Name and level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: AppTextStyles.labelLarge(
                    color: entry.isCurrentUser ? AppColors.accentCyan : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Level ${entry.currentLevel + 1}',
                  style: AppTextStyles.labelSmall(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),

          // XP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: AppRadius.pill,
            ),
            child: Text(
              '${entry.totalXp} XP',
              style: AppTextStyles.headingSmall(color: AppColors.warning),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: Duration(milliseconds: entry.rank * 50))
        .slideY(begin: 0.05, duration: 300.ms, delay: Duration(milliseconds: entry.rank * 50));
  }
}
