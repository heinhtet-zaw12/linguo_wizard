import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Stateless service wrapping Firebase Authentication.
///
/// Provides email/password, Google, and anonymous sign-in methods.
/// Errors propagate to the caller (ViewModel layer) for UI display.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign up with email and password, then set display name.
  Future<UserCredential> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);
    return credential;
  }

  /// Sign in with email and password.
  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with Google. Opens the Google sign-in dialog.
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw StateError('Google sign-in was cancelled by the user.');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  /// Sign in anonymously (guest mode).
  Future<UserCredential> signInAnonymously() {
    return _auth.signInAnonymously();
  }

  /// Sign out from all providers (Firebase + Google).
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      GoogleSignIn().signOut(),
    ]);
  }

  /// Send a password reset email.
  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  /// The currently signed-in user, or null if none.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes (sign-in / sign-out events).
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
