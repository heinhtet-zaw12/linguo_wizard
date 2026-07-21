import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firestore_service.dart';
import '../services/gamification_service.dart';
import '../services/srs_service.dart';
import 'auth_provider.dart';

/// Injectable provider for [GamificationService].
///
/// Depends on [FirestoreService] for data persistence.
final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService(ref.read(firestoreServiceProvider));
});

/// Injectable provider for [SrsService].
///
/// Depends on [FirestoreService] for data persistence.
final srsServiceProvider = Provider<SrsService>((ref) {
  return SrsService(ref.read(firestoreServiceProvider));
});
