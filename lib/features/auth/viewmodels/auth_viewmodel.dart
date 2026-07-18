import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';

/// State for the authentication screens.
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool passwordResetSent;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.passwordResetSent = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? passwordResetSent,
    bool clearError = false,
    bool clearPasswordReset = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      passwordResetSent:
          clearPasswordReset ? false : (passwordResetSent ?? this.passwordResetSent),
    );
  }
}

/// ViewModel for authentication screens (login, sign-up, forgot password).
///
/// Handles email/password auth, Google sign-in, anonymous guest mode,
/// and password reset. Never imports widgets.
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
      final authService = ref.read(authServiceProvider);
      await authService.signUpWithEmail(email, password, displayName);
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
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();
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

  /// Convert raw exceptions to user-friendly messages.
  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('user-not-found')) return 'No account found with this email.';
    if (msg.contains('wrong-password')) return 'Incorrect password. Please try again.';
    if (msg.contains('email-already-in-use')) return 'An account already exists with this email.';
    if (msg.contains('weak-password')) return 'Password is too weak. Use at least 6 characters.';
    if (msg.contains('invalid-email')) return 'Please enter a valid email address.';
    if (msg.contains('cancelled')) return 'Sign-in was cancelled.';
    if (msg.contains('network')) return 'Network error. Check your connection.';
    return 'Something went wrong. Please try again.';
  }
}

final authProvider =
    NotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);
