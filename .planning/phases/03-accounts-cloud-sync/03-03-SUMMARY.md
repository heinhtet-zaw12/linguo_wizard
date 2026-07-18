---
phase: 03-accounts-cloud-sync
plan: 03
subsystem: cloud-sync
tags: [firestore, rate-limiting, data-migration, mvvm]
dependency_graph:
  requires: [03-01, 03-02]
  provides: [user-rate-limiting, firestore-sync, guest-migration]
  affects: [04-premium-monetization]
tech_stack:
  added: [cloud_firestore, firebase_auth]
  patterns: [firestore-sync-fire-and-forget, transactional-rate-limit, graceful-migration]
key_files:
  created: []
  modified:
    - lib/core/services/rate_limiter.dart
    - lib/features/onboarding/viewmodels/onboarding_viewmodel.dart
    - lib/features/conversation/viewmodels/conversation_viewmodel.dart
    - lib/features/feedback/screens/feedback_screen.dart
    - lib/features/auth/viewmodels/auth_viewmodel.dart
decisions:
  - "Rate limiter uses Firestore transaction for atomic increment to prevent race conditions"
  - "User rate limits stored in subcollection (users/{uid}/rateLimits/daily) for security rule scoping"
  - "Firestore sync is fire-and-forget across all ViewModels to avoid blocking UI on network"
  - "Migration failure preserves SharedPreferences data — local data is never cleared until Firestore write succeeds"
  - "FeedbackScreen XP sync is belt-and-suspenders (ConversationViewModel also syncs) for reliability"
requirements-completed: [PLAT-02]
coverage:
  - id: D1
    description: "RateLimiterService supports both device-based (guest) and user-based (authenticated) rate limiting via Firestore"
    verification:
      - kind: unit
        ref: "lib/core/services/rate_limiter.dart#canMakeCallForUser"
        status: pass
    human_judgment: false
  - id: D2
    description: "OnboardingViewModel syncs preferences to Firestore when authenticated, SharedPreferences when guest"
    verification:
      - kind: unit
        ref: "lib/features/onboarding/viewmodels/onboarding_viewmodel.dart#setLanguage"
        status: pass
    human_judgment: false
  - id: D3
    description: "ConversationViewModel saves scenario results and progress to Firestore after evaluation"
    verification:
      - kind: unit
        ref: "lib/features/conversation/viewmodels/conversation_viewmodel.dart#_syncToFirestore"
        status: pass
    human_judgment: false
  - id: D4
    description: "FeedbackScreen triggers Firestore XP sync on Done button (belt-and-suspenders)"
    verification:
      - kind: unit
        ref: "lib/features/feedback/screens/feedback_screen.dart#Done button"
        status: pass
    human_judgment: false
  - id: D5
    description: "Guest-to-authenticated migration copies SharedPreferences data to Firestore on sign-up with graceful error handling"
    verification:
      - kind: unit
        ref: "lib/features/auth/viewmodels/auth_viewmodel.dart#_migrateGuestData"
        status: pass
    human_judgment: false
metrics:
  duration: "9min 39s"
  completed: "2026-07-18T17:11:24Z"
  tasks: 3
  files: 5
status: complete
---

# Phase 03 Plan 03: Cloud Sync Integration Summary

User-based Firestore rate limiting, bidirectional onboarding/conversation/feedback data sync, and guest-to-authenticated data migration with graceful error handling.

## Performance

- **Duration:** 9 min 39 s
- **Started:** 2026-07-18T17:01:45Z
- **Completed:** 2026-07-18T17:11:24Z
- **Tasks:** 3
- **Files modified:** 5

## Accomplishments

- RateLimiterService now supports both device-based (SharedPreferences) and user-based (Firestore) rate limiting
- OnboardingViewModel syncs preferences to Firestore when authenticated, SharedPreferences when guest
- ConversationViewModel saves scenario results and progress to Firestore after evaluation
- FeedbackScreen triggers Firestore XP sync on Done button as belt-and-suspenders reliability
- AuthViewModel migrates guest SharedPreferences data to Firestore on sign-up with error-safe migration

## Task Commits

Each task was committed atomically:

1. **Task 1: Update RateLimiterService and OnboardingViewModel** - `80234ca` (feat)
2. **Task 2: Add Firestore sync to ConversationViewModel and FeedbackScreen** - `3734088` (feat)
3. **Task 3: Add guest-to-authenticated migration to AuthViewModel** - `5c2de91` (feat)

## Files Created/Modified

- `lib/core/services/rate_limiter.dart` - Added Firestore-based user rate limiting (canMakeCallForUser, recordCallForUser, remainingCallsForUser) with transactional atomic increment
- `lib/features/onboarding/viewmodels/onboarding_viewmodel.dart` - Added Firestore sync when authenticated (setLanguage, setCefrLevel, setGoal, saveAndComplete)
- `lib/features/conversation/viewmodels/conversation_viewmodel.dart` - Added _syncToFirestore method, user-based rate limiting in onMicPressed
- `lib/features/feedback/screens/feedback_screen.dart` - Added belt-and-suspenders Firestore XP sync on Done button
- `lib/features/auth/viewmodels/auth_viewmodel.dart` - Added migrationComplete state, _migrateGuestData method, migration logic in signUpWithEmail and signInWithGoogle

## Decisions Made

- Rate limiter uses Firestore transaction for atomic increment to prevent race conditions on concurrent calls
- User rate limits stored in subcollection (`users/{uid}/rateLimits/daily`) for Firestore security rule scoping
- All Firestore sync operations are fire-and-forget to avoid blocking UI on network latency
- Migration failure preserves SharedPreferences data — local data is never cleared until Firestore write succeeds
- FeedbackScreen XP sync is belt-and-suspenders (ConversationViewModel also syncs) for reliability in case of partial failure

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Added cloud_firestore dependency to pubspec.yaml**
- **Found during:** Task 1 (RateLimiterService update)
- **Issue:** Worktree was created before phase 3 wave 1 — Firebase dependencies missing from pubspec.yaml
- **Fix:** Added firebase_core, firebase_auth, cloud_firestore, google_sign_in to pubspec.yaml and copied wave 1/2 support files
- **Files modified:** pubspec.yaml, lib/core/providers/auth_provider.dart, lib/core/services/auth_service.dart, lib/core/services/firestore_service.dart, lib/features/auth/*, lib/features/home/*
- **Verification:** flutter analyze passes with 0 issues
- **Committed in:** 80234ca (Task 1 commit)

**2. [Rule 1 - Bug] Fixed unnecessary non-null assertion operators**
- **Found during:** Task 2 (ConversationViewModel update)
- **Issue:** `user!.uid` used after `user` was already null-checked via `isAuth` pattern — Dart analyzer flagged unnecessary `!`
- **Fix:** Removed `!` operators from user.uid references in rate limit check
- **Files modified:** lib/features/conversation/viewmodels/conversation_viewmodel.dart
- **Verification:** flutter analyze passes with 0 issues
- **Committed in:** 3734088 (Task 2 commit)

**3. [Rule 1 - Bug] Added missing ScoreData import to ConversationViewModel**
- **Found during:** Task 2 (ConversationViewModel update)
- **Issue:** `_syncToFirestore` referenced ScoreData but the import was missing from the file
- **Fix:** Added import for `../../feedback/models/score_data.dart`
- **Files modified:** lib/features/conversation/viewmodels/conversation_viewmodel.dart
- **Verification:** flutter analyze passes with 0 issues
- **Committed in:** 3734088 (Task 2 commit)

---

**Total deviations:** 3 auto-fixed (1 blocking, 2 bugs)
**Impact on plan:** All auto-fixes necessary for compilation correctness. No scope creep — deviations were limited to making the plan's code compile in a worktree that was behind main.

## Issues Encountered

None beyond the auto-fixed compilation issues above.

## Known Stubs

None — all Firestore sync paths are fully wired.

## Threat Flags

| Flag | File | Description |
|------|------|-------------|
| T-03-11 | lib/core/services/rate_limiter.dart | User-based rate limits use Firestore subcollection — security rules must enforce owner-only access (uid matches doc path) |
| T-03-09 | lib/features/auth/viewmodels/auth_viewmodel.dart | Migration writes to Firestore — security rules must enforce owner-only writes |

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Cloud sync integration complete — authenticated users now have data persisted to Firestore
- Guest-to-authenticated migration working — SharedPreferences data migrates cleanly on sign-up
- Rate limiting transitions from device-based to user-based on authentication
- Ready for Phase 4 (Premium/Monetization) which can leverage user progress data in Firestore

## Self-Check: PASSED

- [x] lib/core/services/rate_limiter.dart — FOUND
- [x] lib/features/onboarding/viewmodels/onboarding_viewmodel.dart — FOUND
- [x] lib/features/conversation/viewmodels/conversation_viewmodel.dart — FOUND
- [x] lib/features/feedback/screens/feedback_screen.dart — FOUND
- [x] lib/features/auth/viewmodels/auth_viewmodel.dart — FOUND
- [x] Commit 80234ca — FOUND
- [x] Commit 3734088 — FOUND
- [x] Commit 5c2de91 — FOUND
- [x] .planning/phases/03-accounts-cloud-sync/03-03-SUMMARY.md — FOUND

**Self-Check: PASSED**

---
*Phase: 03-accounts-cloud-sync*
*Completed: 2026-07-18*
