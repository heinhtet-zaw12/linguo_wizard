import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/theme/app_text_styles.dart';

/// Celebratory badge award popup with confetti animation.
class BadgePopup extends StatefulWidget {
  const BadgePopup({
    super.key,
    required this.badgeName,
    required this.badgeDescription,
    this.onDismissed,
  });

  final String badgeName;
  final String badgeDescription;
  final VoidCallback? onDismissed;

  @override
  State<BadgePopup> createState() => _BadgePopupState();
}

class _BadgePopupState extends State<BadgePopup> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _confettiController.play();

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _dismiss() {
    widget.onDismissed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      child: Stack(
        children: [
          // Semi-transparent overlay
          Container(
            color: Colors.black.withValues(alpha: 0.6),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.accentStart,
                AppColors.accentMid,
                AppColors.accentCyan,
                AppColors.warning,
                AppColors.success,
              ],
              numberOfParticles: 30,
              gravity: 0.1,
              emissionFrequency: 0.05,
            ),
          ),

          // Badge card
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: GlassCard(
                padding: const EdgeInsets.all(32),
                glowColor: AppColors.accentCyanGlow.withValues(alpha: 0.3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Gradient circle with trophy icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppGradients.accent,
                        boxShadow: AppShadows.glowCyan,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // "Awesome!" label
                    Text(
                      'Awesome!',
                      style: AppTextStyles.labelLarge(color: AppColors.accentCyan),
                    ),
                    const SizedBox(height: 8),

                    // Badge name
                    Text(
                      widget.badgeName,
                      style: AppTextStyles.headingLarge(color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Badge description
                    Text(
                      widget.badgeDescription,
                      style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Tap to dismiss hint
                    Text(
                      'Tap anywhere to continue',
                      style: AppTextStyles.labelSmall(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.9, 0.9),
                  duration: 250.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 250.ms),
          ),
        ],
      ),
    );
  }
}
