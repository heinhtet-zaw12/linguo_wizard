import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../models/score_data.dart';
import '../viewmodels/feedback_viewmodel.dart';

/// Post-conversation feedback screen showing scores, grammar corrections, and XP.
///
/// Receives ScoreData via [currentScoreProvider] and displays a comprehensive
/// breakdown of the conversation performance.
class FeedbackScreen extends ConsumerWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreData = ref.watch(currentScoreProvider);

    // If no score data, show loading or error state.
    if (scoreData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          child: Column(
            children: [
              // ─── Score Circle ───
              const SizedBox(height: 24),
              _ScoreCircle(score: scoreData.overallScore),

              const SizedBox(height: 16),

              // ─── Score Breakdown Row ───
              _ScoreBreakdown(
                fluency: scoreData.fluencyScore,
                grammar: scoreData.grammarScore,
                vocabulary: scoreData.vocabularyScore,
              ),

              const SizedBox(height: 16),

              // ─── XP Badge ───
              _XpBadge(xp: scoreData.xpEarned),

              const SizedBox(height: 16),

              // ─── Grammar Corrections List ───
              Expanded(
                child: _GrammarCorrections(
                  corrections: scoreData.grammarCorrections,
                ),
              ),

              // ─── Done Button ───
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/scenarios');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.shadowPink,
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ───

class _ScoreCircle extends StatelessWidget {
  const _ScoreCircle({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryPink,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowPink,
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$score',
              style: GoogleFonts.fredoka(
                fontSize: 40,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Overall Score',
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _BreakdownCard(label: 'Fluency', score: fluency),
          const SizedBox(width: 12),
          _BreakdownCard(label: 'Grammar', score: grammar),
          const SizedBox(width: 12),
          _BreakdownCard(label: 'Vocabulary', score: vocabulary),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
            Text(
              '$score',
              style: GoogleFonts.fredoka(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.accentGold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 12,
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

class _XpBadge extends StatelessWidget {
  const _XpBadge({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppColors.accentGold,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            '+$xp XP',
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.accentGold,
            ),
          ),
        ],
      ),
    );
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
            Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.accentGold,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'No grammar issues found',
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: corrections.length,
      itemBuilder: (context, index) {
        final correction = corrections[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
              // Original (struck through) → Corrected
              RichText(
                text: TextSpan(
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                  children: [
                    TextSpan(
                      text: correction.original,
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.accentCoral,
                      ),
                    ),
                    const TextSpan(text: ' → '),
                    TextSpan(
                      text: correction.corrected,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                correction.explanation,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
