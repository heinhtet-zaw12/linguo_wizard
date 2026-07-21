import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../viewmodels/profile_viewmodel.dart';

/// Profile tab screen displaying user info and account actions.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(profileViewModelProvider);

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
                    'Failed to load profile',
                    style: GoogleFonts.quicksand(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => ref.invalidate(profileViewModelProvider),
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
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
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
              style: GoogleFonts.fredoka(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
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

            // ─── Settings Placeholder ───
            _buildSettingsSection(),
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
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          if (state.email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              state.email,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
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
        style: GoogleFonts.fredoka(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryPinkDark,
        ),
      ),
    );
  }

  Widget _buildStatsRow(ProfileState state) {
    return Row(
      children: [
        _StatCard(
          icon: Icons.star_rounded,
          iconColor: AppColors.primaryPink,
          value: '${state.totalXp}',
          label: 'Total XP',
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: Icons.local_fire_department_rounded,
          iconColor: AppColors.accentGold,
          value: '${state.currentStreak}',
          label: 'Day Streak',
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: Icons.check_circle_outline_rounded,
          iconColor: Colors.green,
          value: '${state.scenariosCompleted}',
          label: 'Scenarios',
        ),
      ],
    );
  }

  Widget _buildAccountInfo(ProfileState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPink.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Level', value: state.levelName),
          const Divider(height: 20),
          _InfoRow(label: 'CEFR Level', value: state.cefrLevel),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPink.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Account settings coming soon',
            style: GoogleFonts.quicksand(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(
                'Sign Out',
                style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
              ),
              content: Text(
                'Are you sure you want to sign out?',
                style: GoogleFonts.quicksand(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.quicksand(color: AppColors.textMuted),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    'Sign Out',
                    style: GoogleFonts.quicksand(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
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
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: Text(
          'Sign Out',
          style: GoogleFonts.quicksand(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowPink.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
