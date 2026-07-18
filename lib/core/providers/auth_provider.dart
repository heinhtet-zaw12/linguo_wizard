import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Injectable provider for [AuthService].
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Injectable provider for [FirestoreService].
final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

/// Stream of the current Firebase [User] (or null when signed out).
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Convenience provider that emits the current [User] or null.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Whether the current user is a guest (not signed in, or anonymous).
final isGuestProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user == null || user.isAnonymous;
});
