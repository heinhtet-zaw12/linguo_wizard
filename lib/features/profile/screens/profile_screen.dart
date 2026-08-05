import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
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
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            ),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to load profile',
                    style: AppTextStyles.bodyMedium(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => ref.invalidate(profileViewModelProvider),
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
        ref.read(profileViewModelProvider.notifier).refresh();
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
              'Profile',
              style: AppTextStyles.displayMedium(color: AppColors.textDark),
            ),
            const SizedBox(height: 24),

            // ─── Avatar + Name ───
            _buildAvatarSection(state),
            const SizedBox(height: 24),

            // ─── Stats Row ───
            _buildStatsRow(state),
            const SizedBox(height: 24),

            // ─── Account Info ───
            _buildAccountInfo(state),
            const SizedBox(height: 24),

            // ─── Settings ───
            _buildSettingsSection(context, ref),
            const SizedBox(height: 24),

            // ─── Logout Button ───
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryPinkLight,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowPink.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: state.photoUrl != null
                ? ClipOval(
                    child: Image.network(
                      state.photoUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildInitials(initials),
                    ),
                  )
                : _buildInitials(initials),
          ),
          const SizedBox(height: 12),
          Text(
            state.displayName,
            style: AppTextStyles.headingLarge(color: AppColors.textDark),
          ),
          if (state.email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              state.email,
              style: AppTextStyles.bodyMedium(color: AppColors.textMuted),
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
        style: AppTextStyles.displayMedium(color: AppColors.primaryPinkDark),
      ),
    );
  }

  Widget _buildStatsRow(ProfileState state) {
    return Row(
      children: [
        StatCard(
          icon: Icons.star_rounded,
          iconColor: AppColors.primaryPink,
          value: '${state.totalXp}',
          label: 'Total XP',
        ),
        const SizedBox(width: 12),
        StatCard(
          icon: Icons.local_fire_department_rounded,
          iconColor: AppColors.accentGold,
          value: '${state.currentStreak}',
          label: 'Day Streak',
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

  Widget _buildAccountInfo(ProfileState state) {
    return AppCard(
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
    final themeMode = ref.watch(themeModeProvider);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: AppTextStyles.headingSmall(color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          // ─── Dark Mode Toggle ───
          _buildThemeTile(ref, themeMode),
        ],
      ),
    );
  }

  Widget _buildThemeTile(WidgetRef ref, ThemeMode currentMode) {
    return Row(
      children: [
        Icon(
          Icons.dark_mode_outlined,
          size: 22,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Dark Mode',
            style: AppTextStyles.bodyMedium(color: AppColors.textDark),
          ),
        ),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
              value: ThemeMode.system,
              label: Text('Auto', style: TextStyle(fontSize: 12)),
              icon: Icon(Icons.brightness_auto, size: 16),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              label: Text('Light', style: TextStyle(fontSize: 12)),
              icon: Icon(Icons.light_mode, size: 16),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text('Dark', style: TextStyle(fontSize: 12)),
              icon: Icon(Icons.dark_mode, size: 16),
            ),
          ],
          selected: {currentMode},
          onSelectionChanged: (selected) {
            ref.read(themeModeProvider.notifier).setMode(selected.first);
          },
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return AppButton(
      label: 'Sign Out',
      variant: AppButtonVariant.secondary,
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
                  style: AppTextStyles.bodyMedium(color: AppColors.textMuted),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Sign Out',
                  style: AppTextStyles.labelLarge(color: Colors.red),
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
