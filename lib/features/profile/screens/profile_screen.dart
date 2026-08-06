import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../../../core/theme/app_text_styles.dart';

/// Profile tab screen displaying user info and account actions.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(profileViewModelProvider);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: asyncState.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.accentStart),
            ),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to load profile',
                    style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => ref.invalidate(profileViewModelProvider),
                    child: Text(
                      'Retry',
                      style: AppTextStyles.labelLarge(color: AppColors.accentStart),
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

  Widget _buildContent(BuildContext context, WidgetRef ref, ProfileState state) {
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
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 12),
              Text(
                state.error!,
                style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(profileViewModelProvider.notifier).refresh();
      },
      color: AppColors.accentStart,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: AppTextStyles.displayMedium(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            _buildAvatarSection(state),
            const SizedBox(height: 24),
            _buildStatsRow(state),
            const SizedBox(height: 24),
            _buildAccountInfo(state),
            const SizedBox(height: 24),
            _buildSettingsSection(context, ref),
            const SizedBox(height: 24),
            _buildLogoutButton(context, ref),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(ProfileState state) {
    final initials = state.displayName.isNotEmpty
        ? state.displayName[0].toUpperCase()
        : 'U';

    return Center(
      child: Column(
        children: [
          // Gradient-bordered avatar circle
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.accent,
              boxShadow: AppShadows.glowBlue,
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface1,
              ),
              child: state.photoUrl != null
                  ? ClipOval(
                      child: Image.network(
                        state.photoUrl!,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildInitials(initials),
                      ),
                    )
                  : _buildInitials(initials),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            state.displayName,
            style: AppTextStyles.headingLarge(color: AppColors.textPrimary),
          ),
          if (state.email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              state.email,
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInitials(String initials) {
    return Center(
      child: Text(
        initials,
        style: AppTextStyles.displayMedium(color: AppColors.accentStart),
      ),
    );
  }

  Widget _buildStatsRow(ProfileState state) {
    return Row(
      children: [
        StatCard(
          icon: Icons.star_rounded,
          iconColor: AppColors.accentStart,
          value: '${state.totalXp}',
          label: 'Total XP',
        ),
        const SizedBox(width: 12),
        StatCard(
          icon: Icons.local_fire_department_rounded,
          iconColor: AppColors.warning,
          value: '${state.currentStreak}',
          label: 'Day Streak',
        ),
        const SizedBox(width: 12),
        StatCard(
          icon: Icons.check_circle_outline_rounded,
          iconColor: AppColors.success,
          value: '${state.scenariosCompleted}',
          label: 'Scenarios',
        ),
      ],
    );
  }

  Widget _buildAccountInfo(ProfileState state) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          InfoRow(label: 'Level', value: state.levelName),
          const Divider(height: 20),
          InfoRow(label: 'CEFR Level', value: state.cefrLevel),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    // Dark-only theme — no toggle UI. Settings section is minimal.
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: AppTextStyles.headingSmall(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.dark_mode_outlined,
                size: 22,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Dark Mode',
                  style: AppTextStyles.bodyMedium(color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentStart.withValues(alpha: 0.15),
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  'Always On',
                  style: AppTextStyles.labelSmall(color: AppColors.accentStart),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return AppButton(
      label: 'Sign Out',
      variant: AppButtonVariant.ghost,
      icon: Icons.logout_rounded,
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              'Sign Out',
              style: AppTextStyles.headingSmall(),
            ),
            content: Text(
              'Are you sure you want to sign out?',
              style: AppTextStyles.bodyMedium(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Sign Out',
                  style: AppTextStyles.labelLarge(color: AppColors.danger),
                ),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          await ref.read(profileViewModelProvider.notifier).signOut();
          if (context.mounted) {
            context.go('/login');
          }
        }
      },
    );
  }
}
