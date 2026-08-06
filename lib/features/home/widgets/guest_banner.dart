import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';

/// Banner shown to guest users encouraging them to sign up.
class GuestBanner extends StatefulWidget {
  const GuestBanner({super.key});

  @override
  State<GuestBanner> createState() => _GuestBannerState();
}

class _GuestBannerState extends State<GuestBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return GlassCard(
      glowColor: AppColors.accentCyan.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentCyan.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.person_add_outlined,
              size: 20,
              color: AppColors.accentCyan,
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign up to save your progress!',
                  style: AppTextStyles.labelLarge(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Create an account to track streaks and sync across devices.',
                  style: AppTextStyles.labelSmall(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Buttons
          Column(
            children: [
              GestureDetector(
                onTap: () => context.go('/signup'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppGradients.accent,
                    borderRadius: AppRadius.md,
                  ),
                  child: Text(
                    'Sign Up',
                    style: AppTextStyles.labelSmall(color: AppColors.textOnAccent),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => setState(() => _dismissed = true),
                child: Text(
                  'Maybe Later',
                  style: AppTextStyles.labelLarge(color: AppColors.textTertiary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
