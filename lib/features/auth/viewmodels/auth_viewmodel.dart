import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/auth_provider.dart';

/// State for the authentication screens.
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool passwordResetSent;
  final bool migrationComplete;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.passwordResetSent = false,
    this.migrationComplete = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? passwordResetSent,
    bool? migrationComplete,
    bool clearError = false,
    bool clearPasswordReset = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      passwordResetSent:
          clearPasswordReset ? false : (passwordResetSent ?? this.passwordResetSent),
      migrationComplete: migrationComplete ?? this.migrationComplete,
    );
  }
}

/// ViewModel for authentication screens (login, sign-up, forgot password).
///
/// Handles email/password auth, Google sign-in, anonymous guest mode,
/// password reset, and guest-to-authenticated data migration. Never imports widgets.
class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmail(email, password);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyError(e),
      );
    }
  }

  Future<void> signUpWithEmail(
      String email, String password, String displayName) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Check if current user is anonymous before sign-up.
      final previousUser = ref.read(currentUserProvider);
      final wasAnonymous = previousUser?.isAnonymous == true;

      final authService = ref.read(authServiceProvider);

      // ignore: avoid_print
      print('[AuthViewModel] signUpWithEmail: calling Firebase createUser...');
      final credential =
          await authService.signUpWithEmail(email, password, displayName);
      // ignore: avoid_print
      print(
          '[AuthViewModel] Firebase createUser success. UID: ${credential.user?.uid}');

      // Create empty Firestore profile for fresh sign-up.
      if (!wasAnonymous && credential.user != null) {
        try {
          final fs = ref.read(firestoreServiceProvider);
          // ignore: avoid_print
          print('[AuthViewModel] Creating Firestore user profile...');
          await fs.createUserProfile(
            credential.user!.uid,
            displayName: displayName,
            email: email,
          );
          // ignore: avoid_print
          print('[AuthViewModel] Firestore profile created.');
        } catch (fsError) {
          // ignore: avoid_print
          print(
              '[AuthViewModel] Firestore profile creation failed (non-critical): $fsError');
        }
      }

      // Migrate guest data if previous user was anonymous.
      if (wasAnonymous && credential.user != null) {
        // ignore: avoid_print
        print('[AuthViewModel] Migrating guest data...');
        await _migrateGuestData(credential.user!.uid);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyError(e),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Check if current user is anonymous before sign-in.
      final previousUser = ref.read(currentUserProvider);
      final wasAnonymous = previousUser?.isAnonymous == true;

      final authService = ref.read(authServiceProvider);
      final credential = await authService.signInWithGoogle();

      // Migrate guest data if previous user was anonymous.
      if (wasAnonymous && credential.user != null) {
        await _migrateGuestData(credential.user!.uid);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyError(e),
      );
    }
  }

  Future<void> signInAsGuest() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInAnonymously();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyError(e),
      );
    }
  }

  Future<void> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.sendPasswordReset(email);
      state = state.copyWith(isLoading: false, passwordResetSent: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyError(e),
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Migrate guest data from SharedPreferences to Firestore on sign-up.
  ///
  /// Reads onboarding preferences from SharedPreferences, creates a
  /// Firestore user profile and preferences document, and clears the
  /// local guest data. Wrapped in try/catch — on failure, SharedPreferences
  /// is NOT cleared (local data preserved), and a warning message is shown.
  Future<void> _migrateGuestData(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Read guest onboarding data.
      final language = prefs.getString('onboarding_language');
      final cefr = prefs.getString('onboarding_cefr');
      final goal = prefs.getString('onboarding_goal');
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

      if (!onboardingCompleted) {
        // No guest data to migrate — create empty profile.
        final fs = ref.read(firestoreServiceProvider);
        await fs.createUserProfile(uid, displayName: 'User');
        state = state.copyWith(migrationComplete: true);
        return;
      }

      final fs = ref.read(firestoreServiceProvider);

      // Create user profile.
      await fs.createUserProfile(uid, displayName: 'User');

      // Save preferences.
      await fs.savePreferences(
        uid,
        language: language ?? 'English',
        cefrLevel: cefr ?? 'A1',
        goal: goal ?? 'Travel',
      );

      // Initialize progress.
      await fs.saveProgress(uid, totalXp: 0, scenariosCompleted: 0);

      // Clear migrated SharedPreferences keys.
      await prefs.remove('onboarding_language');
      await prefs.remove('onboarding_cefr');
      await prefs.remove('onboarding_goal');
      await prefs.remove('onboarding_completed');

      state = state.copyWith(migrationComplete: true);
    } catch (e) {
      // Migration failed — do NOT clear SharedPreferences (local data preserved).
      state = state.copyWith(
        errorMessage:
            'Account created but some data could not be synced. Your progress is safe.',
        migrationComplete: false,
      );
    }
  }

  /// Convert raw exceptions to user-friendly messages.
  ///
  /// Logs the full error to the console for debugging, then returns
  /// a human-readable message for the UI.
  String _friendlyError(Object e) {
    // Log the full error so it's visible in the debug console.
    // ignore: avoid_print
    print('[AuthViewModel] ERROR: $e');

    final msg = e.toString();

    // Firebase Auth error codes
    if (msg.contains('user-not-found')) return 'No account found with this email.';
    if (msg.contains('wrong-password')) return 'Incorrect password. Please try again.';
    if (msg.contains('email-already-in-use')) return 'An account already exists with this email.';
    if (msg.contains('weak-password')) return 'Password is too weak. Use at least 6 characters.';
    if (msg.contains('invalid-email')) return 'Please enter a valid email address.';
    if (msg.contains('user-disabled')) return 'This account has been disabled. Contact support.';
    if (msg.contains('operation-not-allowed')) return 'This sign-in method is not enabled. Contact support.';
    if (msg.contains('too-many-requests')) return 'Too many attempts. Please try again later.';
    if (msg.contains('network-request-failed')) return 'Network error. Check your connection.';
    if (msg.contains('invalid-credential')) return 'Invalid credentials. Please check and try again.';
    if (msg.contains('auth/invalid-credential')) return 'Invalid credentials. Please check and try again.';
    if (msg.contains('admin-restricted-operation')) return 'This operation is restricted. Contact support.';
    if (msg.contains('requires-recent-login')) return 'Please sign out and sign in again, then retry.';

    // Google sign-in errors
    if (msg.contains('cancelled') || msg.contains('sign_in_canceled')) return 'Sign-in was cancelled.';
    if (msg.contains('sign_in_failed')) return 'Google sign-in failed. Try again.';
    if (msg.contains('network_error')) return 'Network error during sign-in. Check your connection.';

    // Firestore errors
    if (msg.contains('permission-denied')) return 'Permission denied. Check Firestore security rules.';
    if (msg.contains('unavailable')) return 'Service temporarily unavailable. Try again.';
    if (msg.contains('not-found')) return 'Requested resource not found.';

    // Generic network catch-all
    if (msg.contains('network') || msg.contains('SocketException')) return 'Network error. Check your connection.';

    // Last resort: include the error code if present, else the full message
    final codeMatch = RegExp(r'\[.*?\]\s*(.*)').firstMatch(msg);
    final detail = codeMatch?.group(1) ?? msg;
    return 'Something went wrong: $detail';
  }
}

final authProvider =
    NotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);
