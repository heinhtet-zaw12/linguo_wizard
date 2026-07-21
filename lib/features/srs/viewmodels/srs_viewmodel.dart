import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/srs_item.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';

/// State for the pre-scenario SRS review screen.
class SrsState {
  final List<SrsItem> dueItems;
  final bool isLoading;
  final bool reviewComplete;

  const SrsState({
    this.dueItems = const [],
    this.isLoading = true,
    this.reviewComplete = false,
  });

  SrsState copyWith({
    List<SrsItem>? dueItems,
    bool? isLoading,
    bool? reviewComplete,
  }) {
    return SrsState(
      dueItems: dueItems ?? this.dueItems,
      isLoading: isLoading ?? this.isLoading,
      reviewComplete: reviewComplete ?? this.reviewComplete,
    );
  }
}

/// ViewModel for the pre-scenario SRS review screen.
///
/// Loads due SRS items for the current user and manages review interactions.
class SrsViewModel extends AsyncNotifier<SrsState> {
  @override
  Future<SrsState> build() async {
    final user = ref.read(currentUserProvider);
    if (user == null || user.isAnonymous) {
      return const SrsState(isLoading: false, reviewComplete: true);
    }

    try {
      final srsService = ref.read(srsServiceProvider);
      final dueItems = await srsService.getDueItems(user.uid);
      return SrsState(dueItems: dueItems, isLoading: false);
    } catch (e) {
      return SrsState(isLoading: false);
    }
  }

  /// Mark an item as reviewed (quality 4 = "I know this").
  Future<void> reviewItem(SrsItem item) async {
    final user = ref.read(currentUserProvider);
    if (user == null || user.isAnonymous) return;

    final srsService = ref.read(srsServiceProvider);
    await srsService.reviewItem(user.uid, item, 4);

    final current = state.value;
    if (current == null) return;

    final remaining = current.dueItems.where((i) => i.id != item.id).toList();
    state = AsyncData(current.copyWith(dueItems: remaining));

    // If no more items, mark review as complete.
    if (remaining.isEmpty) {
      state = AsyncData(current.copyWith(
        dueItems: remaining,
        reviewComplete: true,
      ));
    }
  }

  /// Skip the entire review session.
  void skipReview() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(reviewComplete: true));
  }
}

final srsViewModelProvider =
    AsyncNotifierProvider<SrsViewModel, SrsState>(SrsViewModel.new);
