---
phase: 03-accounts-cloud-sync
plan: 01
subsystem: core
tags: [firebase, auth, firestore, providers]
dependency_graph:
  requires: [02-02]
  provides: [auth-service, firestore-service, auth-state-providers]
  affects: [03-02, 03-03]
tech_stack:
  added: [firebase_core, firebase_auth, cloud_firestore, google_sign_in]
  patterns: [firebase-init-first, service-layer, riverpod-stream-provider]
key_files:
  created:
    - lib/core/config/firebase_options.dart
    - lib/core/services/auth_service.dart
    - lib/core/services/firestore_service.dart
    - lib/core/providers/auth_provider.dart
  modified:
    - pubspec.yaml
    - lib/main.dart
decisions:
  - "Firebase init runs before AppConfig.loadEnv() to ensure Firebase services are available for any downstream code"
  - "FirestoreService uses map fields (profile, preferences, progress) on the user document rather than subcollections for simplicity"
  - "AuthService lets errors propagate to caller rather than catching — ViewModel layer handles UI display"
metrics:
  duration: "2026-07-18T16:34:01Z"
  completed: "2026-07-18T16:36:30Z"
  tasks: 3
  files: 5
status: complete
---

# Phase 03 Plan 01: Firebase Foundation Summary

Firebase core initialization, AuthService (email/Google/anonymous auth), FirestoreService (user CRUD), and Riverpod auth state providers.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Add Firebase dependencies and initialize Firebase | `15825c3` | pubspec.yaml, lib/core/config/firebase_options.dart, lib/main.dart |
| 2 | Create AuthService wrapping Firebase Auth | `358918b` | lib/core/services/auth_service.dart |
| 3 | Create FirestoreService and auth state providers | `acfb785` | lib/core/services/firestore_service.dart, lib/core/providers/auth_provider.dart |

## Verification Results

- `flutter pub get` — succeeded (16 dependencies changed)
- `flutter analyze` on all 5 files — 0 issues found
- AuthService: 8 public methods/getters (signUpWithEmail, signInWithEmail, signInWithGoogle, signInAnonymously, signOut, sendPasswordReset, currentUser, authStateChanges)
- FirestoreService: 9 public methods (createUserProfile, updateUserProfile, getUserProfile, savePreferences, getPreferences, saveProgress, getProgress, saveScenarioResult, getScenarios)
- Auth providers: authServiceProvider, firestoreServiceProvider, authStateProvider (StreamProvider<User?>), currentUserProvider, isGuestProvider

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

- `firebase_options.dart` contains placeholder values (empty strings for API keys). This is intentional — the file requires a Firebase project to be created and `flutterfire configure` to be run before real values can be populated. Documented in the plan's `user_setup` section.

## Threat Flags

| Flag | File | Description |
|------|------|-------------|
| T-03-02 | lib/core/services/firestore_service.dart | Firestore writes — security rules must enforce owner-only access (uid matches doc path) |

## Self-Check

- [x] lib/core/config/firebase_options.dart — FOUND
- [x] lib/core/services/auth_service.dart — FOUND
- [x] lib/core/services/firestore_service.dart — FOUND
- [x] lib/core/providers/auth_provider.dart — FOUND
- [x] lib/main.dart (modified) — FOUND
- [x] pubspec.yaml (modified) — FOUND
- [x] Commit 15825c3 — FOUND
- [x] Commit 358918b — FOUND
- [x] Commit acfb785 — FOUND

**Self-Check: PASSED**
