import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../badge/widgets/badge_popup.dart';
import '../models/score_data.dart';
import '../viewmodels/feedback_viewmodel.dart';
import '../../../core/theme/app_text_styles.dart';

/// Post-conversation feedback screen showing scores, grammar corrections, and XP.
class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  bool _showBadgePopup = false;
  int _currentBadgeIndex = 0;

  // Score counter animation
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;

  // Confetti
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOut),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForBadges();
      // Start score animation
      final scoreData = ref.read(currentScoreProvider);
      if (scoreData != null) {
        _scoreController.forward();
        if (scoreData.overallScore >= 80) {
          _confettiController.play();
        }
      }
    });
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _checkForBadges() {
    final badges = ref.read(newlyEarnedBadgesProvider);
    if (badges.isNotEmpty) {
      HapticFeedback.mediumImpact();
      setState(() {
        _showBadgePopup = true;
        _currentBadgeIndex = 0;
      });
    }
  }

  void _dismissBadgePopup() {
    final badges = ref.read(newlyEarnedBadgesProvider);
    setState(() {
      _currentBadgeIndex++;
      if (_currentBadgeIndex >= badges.length) {
        _showBadgePopup = false;
        ref.read(newlyEarnedBadgesProvider.notifier).state = const [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scoreData = ref.watch(currentScoreProvider);
    final badges = ref.watch(newlyEarnedBadgesProvider);

    if (scoreData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          GradientBackground(
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _ScoreCircle(score: scoreData.overallScore, animation: _scoreAnimation),
                  const SizedBox(height: 16),
                  _ScoreBreakdown(
                    fluency: scoreData.fluencyScore,
                    grammar: scoreData.grammarScore,
                    vocabulary: scoreData.vocabularyScore,
                  ),
                  const SizedBox(height: 16),
                  _XpBadge(xp: scoreData.xpEarned),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _GrammarCorrections(
                      corrections: scoreData.grammarCorrections,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: AppButton(
                      label: 'Done',
                      onPressed: () {
                        final user = ref.read(currentUserProvider);
                        if (user != null && !user.isAnonymous) {
                          final fs = ref.read(firestoreServiceProvider);
                          fs.getProgress(user.uid).then((progress) {
                            final existingXp = progress?['totalXp'] as int? ?? 0;
                            final existingCompleted = progress?['scenariosCompleted'] as int? ?? 0;
                            fs.saveProgress(
                              user.uid,
                              totalXp: existingXp + scoreData.xpEarned,
                              scenariosCompleted: existingCompleted,
                              lastScenarioAt: DateTime.now(),
                            );
                          });
                        }
                        context.go('/home');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              colors: const [
                AppColors.accentStart,
                AppColors.accentMid,
                AppColors.accentCyan,
                AppColors.warning,
                AppColors.success,
              ],
            ),
          ),

          // Badge Popup Overlay
          if (_showBadgePopup && badges.isNotEmpty && _currentBadgeIndex < badges.length)
            BadgePopup(
              badgeName: badges[_currentBadgeIndex].definition?.name ?? 'Badge',
              badgeDescription: badges[_currentBadgeIndex].definition?.description ?? '',
              onDismissed: _dismissBadgePopup,
            ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ───

class _ScoreCircle extends StatelessWidget {
  const _ScoreCircle({required this.score, required this.animation});

  final int score;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final displayScore = (score * animation.value).toInt();
            return Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.accent,
                boxShadow: AppShadows.glowBlue,
              ),
              child: Center(
                child: Text(
                  '$displayScore',
                  style: AppTextStyles.displayMedium(color: Colors.white),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Overall Score',
          style: AppTextStyles.labelLarge(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ScoreBreakdown extends StatelessWidget {
  const _ScoreBreakdown({
    required this.fluency,
    required this.grammar,
    required this.vocabulary,
  });

  final int fluency;
  final int grammar;
  final int vocabulary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontal6,
      child: Row(
        children: [
          _BreakdownCard(label: 'Fluency', score: fluency, index: 0),
          const SizedBox(width: 12),
          _BreakdownCard(label: 'Grammar', score: grammar, index: 1),
          const SizedBox(width: 12),
          _BreakdownCard(label: 'Vocabulary', score: vocabulary, index: 2),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.label, required this.score, required this.index});

  final String label;
  final int score;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              '$score',
              style: AppTextStyles.headingLarge(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: AppRadius.xxs,
              child: Container(
                height: 3,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppGradients.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 50))
        .slideY(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: index * 50));
  }
}

class _XpBadge extends StatelessWidget {
  const _XpBadge({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: AppRadius.pill,
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            '+$xp XP',
            style: AppTextStyles.headingSmall(color: AppColors.warning),
          ),
        ],
      ),
    )
        .animate()
        .scale(begin: const Offset(0, 0), duration: 300.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 300.ms);
  }
}

class _GrammarCorrections extends StatelessWidget {
  const _GrammarCorrections({required this.corrections});

  final List<GrammarCorrection> corrections;

  @override
  Widget build(BuildContext context) {
    if (corrections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.success,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'No grammar issues found',
              style: AppTextStyles.bodyLarge(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.horizontal6,
      itemCount: corrections.length,
      itemBuilder: (context, index) {
        final correction = corrections[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium(color: AppColors.textPrimary),
                      children: [
                        TextSpan(
                          text: correction.original,
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.danger,
                          ),
                        ),
                        const TextSpan(text: ' → '),
                        TextSpan(
                          text: correction.corrected,
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    correction.explanation,
                    style: AppTextStyles.labelSmall(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
      },
    );
  }
}
