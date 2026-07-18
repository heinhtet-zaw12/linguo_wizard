---
phase: 03-accounts-cloud-sync
plan: 02
subsystem: auth-home
tags: [firebase-auth, home-dashboard, navigation, mvvm]
dependency_graph:
  requires: [03-01]
  provides: [auth-screens, auth-viewmodel, home-screen, home-viewmodel, navigation-routes]
  affects: [03-03]
tech_stack:
  added: [firebase_auth, cloud_firestore, google_sign_in]
  patterns: [riverpod-notifier, async-notifier, consumer-widget, claymorphism-ui]
key_files:
  created:
    - lib/features/auth/viewmodels/auth_viewmodel.dart
    - lib/features/auth/screens/login_screen.dart
    - lib/features/auth/screens/signup_screen.dart
    - lib/features/auth/screens/forgot_password_screen.dart
    - lib/features/home/viewmodels/home_viewmodel.dart
    - lib/features/home/screens/home_screen.dart
    - lib/features/home/widgets/streak_ring.dart
    - lib/features/home/widgets/goal_ring.dart
    - lib/features/home/widgets/scenario_cards.dart
    - lib/features/home/widgets/guest_banner.dart
  modified:
    - lib/main.dart
    - lib/features/splash/splash_screen.dart
decisions:
  - "SplashScreen converted to ConsumerStatefulWidget to access Riverpod providers for auth state"
  - "Navigation logic moved from LinguoWizardApp.onSplashDone callback into SplashScreen internally"
  - "HomeViewModel uses AsyncNotifier pattern to load data from Firestore (authenticated) or SharedPreferences (guest)"
  - "Scenario recommendations filter by user's CEFR level, falling back to all scenarios if none match"
metrics:
  duration: "2026-07-18T16:42:50Z to 2026-07-18T16:56:49Z"
  completed: "2026-07-18T16:56:49Z"
  tasks: 3
  files: 12
status: complete
---

# Phase 03 Plan 02: Auth Screens & Home Dashboard Summary

Authentication screens (login, sign-up, forgot password) with AuthViewModel, and home dashboard with streak ring, goal ring, recommended scenarios, and guest banner. Updated route table and SplashScreen navigation logic.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Create AuthViewModel, LoginScreen, SignUpScreen, and ForgotPasswordScreen | `41242ce` | lib/features/auth/viewmodels/auth_viewmodel.dart, lib/features/auth/screens/login_screen.dart, lib/features/auth/screens/signup_screen.dart, lib/features/auth/screens/forgot_password_screen.dart |
| 2 | Create HomeScreen, HomeViewModel, and dashboard widgets | `1d05397` | lib/features/home/viewmodels/home_viewmodel.dart, lib/features/home/screens/home_screen.dart, lib/features/home/widgets/streak_ring.dart, lib/features/home/widgets/goal_ring.dart, lib/features/home/widgets/scenario_cards.dart, lib/features/home/widgets/guest_banner.dart |
| 3 | Update main.dart route table and SplashScreen navigation logic | `325618a` | lib/main.dart, lib/features/splash/splash_screen.dart |

## Verification Results

- `flutter analyze` on auth feature — 0 issues found
- `flutter analyze` on home feature — 0 issues found
- `flutter analyze` on main.dart and splash_screen.dart — 0 issues found
- `flutter analyze` on entire lib/ — 0 issues found
- AuthViewModel: 6 public methods (signInWithEmail, signUpWithEmail, signInWithGoogle, signInAsGuest, sendPasswordReset, clearError)
- HomeViewModel: loads data from Firestore (authenticated) or SharedPreferences (guest)
- Route table includes: /login, /signup, /forgot-password, /home, /scenarios, /conversation, /feedback, /onboarding
- SplashScreen navigation: unauthenticated → /login, guest/auth without onboarding → /onboarding, guest/auth with onboarding → /home

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

None — all widgets are fully wired with data providers.

## Threat Flags

| Flag | File | Description |
|------|------|-------------|
| T-03-05 | lib/features/auth/screens/*.dart | Client-side form validation only; Firebase Auth enforces real credential checks server-side |
| T-03-07 | lib/features/splash/splash_screen.dart | SplashScreen checks Firebase Auth state (not SharedPreferences) for routing decisions |

## Self-Check

- [x] lib/features/auth/viewmodels/auth_viewmodel.dart — FOUND
- [x] lib/features/auth/screens/login_screen.dart — FOUND
- [x] lib/features/auth/screens/signup_screen.dart — FOUND
- [x] lib/features/auth/screens/forgot_password_screen.dart — FOUND
- [x] lib/features/home/viewmodels/home_viewmodel.dart — FOUND
- [x] lib/features/home/screens/home_screen.dart — FOUND
- [x] lib/features/home/widgets/streak_ring.dart — FOUND
- [x] lib/features/home/widgets/goal_ring.dart — FOUND
- [x] lib/features/home/widgets/scenario_cards.dart — FOUND
- [x] lib/features/home/widgets/guest_banner.dart — FOUND
- [x] lib/main.dart (modified) — FOUND
- [x] lib/features/splash/splash_screen.dart (modified) — FOUND
- [x] Commit 41242ce — FOUND
- [x] Commit 1d05397 — FOUND
- [x] Commit 325618a — FOUND

**Self-Check: PASSED**
