import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/srs_item.dart';
import '../../../core/theme/app_theme.dart';
import '../viewmodels/srs_viewmodel.dart';

/// Pre-scenario review screen showing due SRS items before conversation starts.
///
/// Per D-14: Users see words/phrases to practice before starting a scenario.
/// Explicit, user-controlled approach with skip option.
class PreScenarioReviewScreen extends ConsumerStatefulWidget {
  const PreScenarioReviewScreen({super.key, required this.scenarioId});

  final String scenarioId;

  @override
  ConsumerState<PreScenarioReviewScreen> createState() =>
      _PreScenarioReviewScreenState();
}

class _PreScenarioReviewScreenState
    extends ConsumerState<PreScenarioReviewScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-redirect if no due items after loading.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoRedirect();
    });
  }

  void _checkAutoRedirect() {
    final state = ref.read(srsViewModelProvider);
    state.whenData((data) {
      if (data.dueItems.isEmpty && !data.isLoading) {
        // No items to review — auto-redirect after brief delay.
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.pushReplacement('/conversation/${widget.scenarioId}');
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(srsViewModelProvider);

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
              child: Text(
                'Failed to load review items',
                style: GoogleFonts.quicksand(color: AppColors.textMuted),
              ),
            ),
            data: (state) => _buildContent(context, state),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SrsState state) {
    if (state.reviewComplete) {
      // Navigate back or to conversation.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.pushReplacement('/conversation/${widget.scenarioId}');
        }
      });
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryPink),
      );
    }

    return Column(
      children: [
        // ─── Header ───
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Practice these words',
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${state.dueItems.length} items due for review',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),

        // ─── SRS Items List ───
        Expanded(
          child: state.dueItems.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.dueItems.length,
                  itemBuilder: (context, index) {
                    return _SrsItemCard(
                      item: state.dueItems[index],
                      onKnown: () => _reviewItem(state.dueItems[index]),
                    );
                  },
                ),
        ),

        // ─── Action Buttons ───
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Start Scenario button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(srsViewModelProvider.notifier).skipReview();
                    context.push('/conversation/${widget.scenarioId}');
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
                    'Start Scenario',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Skip link
              TextButton(
                onPressed: () {
                  ref.read(srsViewModelProvider.notifier).skipReview();
                  context.push('/conversation/${widget.scenarioId}');
                },
                child: Text(
                  'Skip Review',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 48,
            color: AppColors.accentGold,
          ),
          const SizedBox(height: 12),
          Text(
            "You're all caught up!",
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No items to review.',
            style: GoogleFonts.quicksand(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _reviewItem(SrsItem item) {
    ref.read(srsViewModelProvider.notifier).reviewItem(item);
  }
}

class _SrsItemCard extends StatelessWidget {
  const _SrsItemCard({required this.item, required this.onKnown});

  final SrsItem item;
  final VoidCallback onKnown;

  Color _categoryColor() {
    switch (item.category) {
      case 'grammar':
        return AppColors.accentCoral;
      case 'vocabulary':
        return AppColors.primaryPinkDark;
      case 'phrase':
        return AppColors.accentGold;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _categoryColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.category,
              style: GoogleFonts.quicksand(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _categoryColor(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Text(
              item.text,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          // "I know this" button
          IconButton(
            onPressed: onKnown,
            icon: const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.green,
              size: 24,
            ),
            tooltip: 'I know this',
          ),
        ],
      ),
    );
  }
}
