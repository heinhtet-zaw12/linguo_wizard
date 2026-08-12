import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_theme.dart';
import 'app_card.dart';

/// Base shimmer animation wrapper that applies a subtle gradient shimmer
/// effect consistent with the app's dark purple theme.
class ShimmerSkeleton extends StatelessWidget {
  const ShimmerSkeleton({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? AppColors.surface2,
      highlightColor: highlightColor ?? AppColors.surface3,
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

/// A rounded rectangle placeholder block used for text/content placeholders.
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: borderRadius ?? AppRadius.sm,
      ),
    );
  }
}

/// A circular placeholder block (for avatars, rings, etc.).
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface2,
      ),
    );
  }
}

/// Skeleton placeholder that mimics the StreakRing layout.
///
/// Shows a glass card with a circle on the left and two text blocks on the right.
class StreakRingSkeleton extends StatelessWidget {
  const StreakRingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: GlassCard(
        padding: AppSpacing.all5,
        child: Row(
          children: [
            // Circle placeholder (flame icon area)
            const SkeletonCircle(size: 64),
            const SizedBox(width: 16),
            // Text placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBlock(width: 120, height: 18),
                  const SizedBox(height: 8),
                  const SkeletonBlock(width: 160, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton placeholder that mimics the GoalRing layout.
///
/// Shows a glass card with a progress ring circle on the left and text blocks on the right.
class GoalRingSkeleton extends StatelessWidget {
  const GoalRingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: GlassCard(
        padding: AppSpacing.all5,
        child: Row(
          children: [
            // Progress ring placeholder
            const SkeletonCircle(size: 64),
            const SizedBox(width: 16),
            // Text placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBlock(width: 100, height: 18),
                  const SizedBox(height: 8),
                  const SkeletonBlock(width: 80, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton placeholder that mimics the DailyChallengeCard layout.
///
/// Shows a glass card with heading text, description blocks, and a button area.
class DailyChallengeCardSkeleton extends StatelessWidget {
  const DailyChallengeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: GlassCard(
        padding: AppSpacing.all5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Heading + badge
            Row(
              children: [
                const SkeletonBlock(width: 140, height: 18),
                const SizedBox(width: 10),
                const SkeletonBlock(width: 48, height: 20, borderRadius: AppRadius.sm),
              ],
            ),
            const SizedBox(height: 12),
            // Row 2: Description line 1
            const SkeletonBlock(width: double.infinity, height: 14),
            const SizedBox(height: 8),
            // Row 3: Description line 2
            const SkeletonBlock(width: 200, height: 14),
            const SizedBox(height: 12),
            // Row 4: Countdown text
            const SkeletonBlock(width: 100, height: 12),
            const SizedBox(height: 16),
            // Row 5: Button
            const SkeletonBlock(width: double.infinity, height: 48, borderRadius: AppRadius.md),
          ],
        ),
      ),
    );
  }
}

/// Skeleton placeholder for a single scenario card (used in both Home horizontal
/// scroll and Scenario Selection grid).
///
/// Shows a glass card with a gradient stripe, badge, title lines, and persona row.
class ScenarioCardSkeleton extends StatelessWidget {
  const ScenarioCardSkeleton({super.key, this.aspectRatio = 0.78});

  /// Aspect ratio for grid layout (matches ScenarioSelection grid).
  /// Use 1.0 or omit for a simpler horizontal card.
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient top stripe placeholder
            SkeletonBlock(
              width: double.infinity,
              height: 4,
              borderRadius: AppRadius.xxs,
            ),
            const SizedBox(height: 12),
            // CEFR badge placeholder
            SkeletonBlock(width: 40, height: 20, borderRadius: AppRadius.sm),
            const SizedBox(height: 12),
            // Title line 1
            const SkeletonBlock(width: double.infinity, height: 16),
            const SizedBox(height: 8),
            // Title line 2
            const SkeletonBlock(width: 140, height: 16),
            const SizedBox(height: 8),
            // Description lines
            const SkeletonBlock(width: double.infinity, height: 12),
            const SizedBox(height: 6),
            const SkeletonBlock(width: 180, height: 12),
            const Spacer(),
            // Persona row
            Row(
              children: [
                const SkeletonCircle(size: 14),
                const SizedBox(width: 6),
                const SkeletonBlock(width: 80, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A row of horizontal scrolling scenario card skeletons (for Home screen).
class ScenarioCardsSkeleton extends StatelessWidget {
  const ScenarioCardsSkeleton({super.key, this.cardCount = 4});

  final int cardCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: cardCount,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 200,
            child: _HomeScenarioCardSkeleton(),
          );
        },
      ),
    );
  }
}

/// Skeleton for a single Home screen scenario card (narrower than grid cards).
class _HomeScenarioCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient top stripe
            SkeletonBlock(
              width: double.infinity,
              height: 4,
              borderRadius: AppRadius.xxs,
            ),
            const SizedBox(height: 12),
            // CEFR badge
            SkeletonBlock(width: 40, height: 20, borderRadius: AppRadius.sm),
            const SizedBox(height: 10),
            // Title
            const SkeletonBlock(width: double.infinity, height: 16),
            const SizedBox(height: 6),
            const SkeletonBlock(width: 120, height: 16),
            const Spacer(),
            // Persona
            Row(
              children: [
                const SkeletonCircle(size: 14),
                const SizedBox(width: 4),
                const SkeletonBlock(width: 60, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A grid of shimmer skeleton cards for the Scenario Selection screen.
///
/// Shows a 2-column grid matching the layout of the real scenario grid.
class ScenarioGridSkeleton extends StatelessWidget {
  const ScenarioGridSkeleton({super.key, this.cardCount = 6});

  final int cardCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: cardCount,
      itemBuilder: (context, index) {
        return const ScenarioCardSkeleton(aspectRatio: 0.78);
      },
    );
  }
}

/// Skeleton for the category tab bar (horizontal scrolling chips).
class CategoryTabsSkeleton extends StatelessWidget {
  const CategoryTabsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.horizontal4,
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ShimmerSkeleton(
              child: SkeletonBlock(
                width: 70 + (index % 2) * 20,
                height: 34,
                borderRadius: AppRadius.xl,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton for the CEFR chip bar.
class CefrChipsSkeleton extends StatelessWidget {
  const CefrChipsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ShimmerSkeleton(
            child: SkeletonBlock(
              width: 48,
              height: 32,
              borderRadius: AppRadius.pill,
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress Screen Skeletons
// ─────────────────────────────────────────────────────────────────────────────

/// Skeleton for the Level Progress card (GlassCard with icon row + progress bar + XP text).
class LevelProgressSkeleton extends StatelessWidget {
  const LevelProgressSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: GlassCard(
        padding: AppSpacing.all5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: icon + label + level name
            Row(
              children: [
                const SkeletonCircle(size: 20),
                const SizedBox(width: 8),
                const SkeletonBlock(width: 50, height: 14),
                const Spacer(),
                const SkeletonBlock(width: 70, height: 16),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            const SkeletonBlock(width: double.infinity, height: 12, borderRadius: AppRadius.sm),
            const SizedBox(height: 8),
            // XP text
            const SkeletonBlock(width: 200, height: 12),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for a single StatCard (icon circle + value + label).
class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ShimmerSkeleton(
        child: GlassCard(
          padding: AppSpacing.all4,
          child: Column(
            children: [
              const SkeletonCircle(size: AppSizing.avatarSm),
              const SizedBox(height: AppSpacing.s2),
              const SkeletonBlock(width: 40, height: 20),
              const SizedBox(height: AppSpacing.s1),
              const SkeletonBlock(width: 60, height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton for a row of 3 StatCards (Streak, XP, Scenarios).
class StatsRowSkeleton extends StatelessWidget {
  const StatsRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        StatCardSkeleton(),
        SizedBox(width: 12),
        StatCardSkeleton(),
        SizedBox(width: 12),
        StatCardSkeleton(),
      ],
    );
  }
}

/// Skeleton for the Badge Grid card (heading + 3-column grid of badge placeholders).
class BadgeGridSkeleton extends StatelessWidget {
  const BadgeGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: GlassCard(
        padding: AppSpacing.all5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + subtitle
            const SkeletonBlock(width: 80, height: 18),
            const SizedBox(height: 6),
            const SkeletonBlock(width: 120, height: 12),
            const SizedBox(height: 12),
            // 3-column grid of badge cards (shrinkWrap — safe inside SingleChildScrollView)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return ShimmerSkeleton(
                  child: GlassCard(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SkeletonCircle(size: 28),
                        const SizedBox(height: 6),
                        SkeletonBlock(
                          width: 40 + (index % 2) * 10,
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for the Mistake Summary card (heading + 3 stat items in a row).
class MistakeSummarySkeleton extends StatelessWidget {
  const MistakeSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: GlassCard(
        padding: AppSpacing.all5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const SkeletonBlock(width: 130, height: 18),
            const SizedBox(height: 6),
            // Subtitle
            const SkeletonBlock(width: 80, height: 12),
            const SizedBox(height: 12),
            // 3 stat items
            Row(
              children: List.generate(3, (i) => Expanded(
                child: Container(
                  margin: i < 2 ? const EdgeInsets.only(right: 12) : EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: AppRadius.sm,
                  ),
                  child: Column(
                    children: [
                      const SkeletonCircle(size: 22),
                      const SizedBox(height: 4),
                      SkeletonBlock(width: 30, height: 16),
                      const SizedBox(height: 2),
                      SkeletonBlock(width: 50, height: 10),
                    ],
                  ),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full Progress Screen skeleton — all sections in a single scrollable column.
class ProgressScreenSkeleton extends StatelessWidget {
  const ProgressScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const SkeletonBlock(width: 160, height: 28),
          const SizedBox(height: 20),
          // Level Progress
          const LevelProgressSkeleton(),
          const SizedBox(height: 16),
          // Stats Row
          const StatsRowSkeleton(),
          const SizedBox(height: 20),
          // Badge Grid
          const BadgeGridSkeleton(),
          const SizedBox(height: 20),
          // Mistake Summary
          const MistakeSummarySkeleton(),
          const SizedBox(height: 20),
          // Button placeholder
          const SkeletonBlock(width: double.infinity, height: 52, borderRadius: AppRadius.md),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Screen Skeletons
// ─────────────────────────────────────────────────────────────────────────────

/// Skeleton for the avatar section (gradient-bordered circle + name + email).
class AvatarSectionSkeleton extends StatelessWidget {
  const AvatarSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // Avatar circle
          const SkeletonCircle(size: 80),
          const SizedBox(height: 12),
          // Name
          const SkeletonBlock(width: 140, height: 20),
          const SizedBox(height: 8),
          // Email
          const SkeletonBlock(width: 180, height: 14),
        ],
      ),
    );
  }
}

/// Skeleton for the Account Info card (InfoRow placeholders).
class AccountInfoSkeleton extends StatelessWidget {
  const AccountInfoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Row 1: Level
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
              child: Row(
                children: [
                  const SkeletonBlock(width: 40, height: 14),
                  const Spacer(),
                  const SkeletonBlock(width: 60, height: 14),
                ],
              ),
            ),
            const Divider(height: 20),
            // Row 2: CEFR Level
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
              child: Row(
                children: [
                  const SkeletonBlock(width: 70, height: 14),
                  const Spacer(),
                  const SkeletonBlock(width: 30, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for the Settings card (heading + single row with icon + label + badge).
class SettingsCardSkeleton extends StatelessWidget {
  const SettingsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading
            const SkeletonBlock(width: 80, height: 16),
            const SizedBox(height: 12),
            // Setting row
            Row(
              children: [
                const SkeletonCircle(size: 22),
                const SizedBox(width: 12),
                const SkeletonBlock(width: 100, height: 14),
                const Spacer(),
                SkeletonBlock(width: 70, height: 24, borderRadius: AppRadius.pill),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Full Profile Screen skeleton — all sections in a single scrollable column.
class ProfileScreenSkeleton extends StatelessWidget {
  const ProfileScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const SkeletonBlock(width: 100, height: 28),
          const SizedBox(height: 24),
          // Avatar Section
          const AvatarSectionSkeleton(),
          const SizedBox(height: 24),
          // Stats Row
          const StatsRowSkeleton(),
          const SizedBox(height: 24),
          // Account Info
          const AccountInfoSkeleton(),
          const SizedBox(height: 24),
          // Settings
          const SettingsCardSkeleton(),
          const SizedBox(height: 24),
          // Button placeholder
          const SkeletonBlock(width: double.infinity, height: 52, borderRadius: AppRadius.md),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
