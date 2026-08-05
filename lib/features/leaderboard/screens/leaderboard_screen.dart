import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_background.dart';
import '../viewmodels/leaderboard_viewmodel.dart';
import '../../../core/theme/app_text_styles.dart';

/// Full-screen leaderboard showing top users ranked by XP.
///
/// Top 3 entries get gold/silver/bronze styling. Current user is highlighted.
/// Accessible from Progress screen as a push route (no bottom nav).
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEntries = ref.watch(leaderboardViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: AppTextStyles.headingLarge(color: AppColors.textDark),
        ),
        backgroundColor: AppColors.backgroundStart,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: GradientBackground(
        child: asyncEntries.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryPink),
          ),
          error: (e, _) => Center(
            child: Text(
              'Failed to load leaderboard',
              style: AppTextStyles.bodyMedium(color: AppColors.textMuted),
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
                      color: AppColors.textMuted.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No entries yet',
                      style: AppTextStyles.bodyLarge(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complete scenarios to appear here!',
                      style: AppTextStyles.labelMedium(color: AppColors.textMuted),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.read(leaderboardViewModelProvider.notifier).refresh();
              },
              color: AppColors.primaryPink,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        ? const Color(0xFFFFD700) // Gold
        : entry.rank == 2
            ? const Color(0xFFC0C0C0) // Silver
            : entry.rank == 3
                ? const Color(0xFFCD7F32) // Bronze
                : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppColors.primaryPink.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: entry.isCurrentUser
            ? Border.all(color: AppColors.primaryPink.withValues(alpha: 0.4), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPink.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
                      style: AppTextStyles.headingSmall(color: AppColors.textMuted),
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
                  style: AppTextStyles.labelLarge(color: AppColors.textDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Level ${entry.currentLevel + 1}',
                  style: AppTextStyles.labelSmall(color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          // XP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${entry.totalXp} XP',
              style: AppTextStyles.headingSmall(color: AppColors.accentGold),
            ),
          ),
        ],
      ),
    );
  }
}
