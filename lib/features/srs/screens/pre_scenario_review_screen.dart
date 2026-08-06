import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/srs_item.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../viewmodels/srs_viewmodel.dart';
import '../../../core/theme/app_text_styles.dart';

/// Pre-scenario review screen showing due SRS items before conversation starts.
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoRedirect();
    });
  }

  void _checkAutoRedirect() {
    final state = ref.read(srsViewModelProvider);
    state.whenData((data) {
      if (data.dueItems.isEmpty && !data.isLoading) {
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
      body: GradientBackground(
        child: SafeArea(
          child: asyncState.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.accentCyan),
            ),
            error: (e, _) => Center(
              child: Text(
                'Failed to load review items',
                style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.pushReplacement('/conversation/${widget.scenarioId}');
        }
      });
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentCyan),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Practice these words',
                style: AppTextStyles.headingLarge(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                '${state.dueItems.length} items due for review',
                style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
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
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              AppButton(
                label: 'Start Scenario',
                onPressed: () {
                  ref.read(srsViewModelProvider.notifier).skipReview();
                  context.push('/conversation/${widget.scenarioId}');
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ref.read(srsViewModelProvider.notifier).skipReview();
                  context.push('/conversation/${widget.scenarioId}');
                },
                child: Text(
                  'Skip Review',
                  style: AppTextStyles.labelLarge(color: AppColors.textTertiary),
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
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 48,
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          Text(
            "You're all caught up!",
            style: AppTextStyles.bodyLarge(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'No items to review.',
            style: AppTextStyles.labelMedium(color: AppColors.textSecondary),
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
        return AppColors.danger;
      case 'vocabulary':
        return AppColors.accentCyan;
      case 'phrase':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _categoryColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.category,
              style: AppTextStyles.labelSmall(color: _categoryColor()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.text,
              style: AppTextStyles.labelLarge(color: AppColors.textPrimary),
            ),
          ),
          IconButton(
            onPressed: onKnown,
            icon: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.success,
              size: 24,
            ),
            tooltip: 'I know this',
          ),
        ],
      ),
    );
  }
}
