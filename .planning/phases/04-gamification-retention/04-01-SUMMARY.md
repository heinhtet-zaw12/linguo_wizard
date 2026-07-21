---
phase: 04-gamification-retention
plan: 01
subsystem: ui
tags: [go_router, navigation, bottom-nav, auth-guards, stateful-shell]

# Dependency graph
requires:
  - phase: 03-firebase
    provides: Firebase Auth state, SharedPreferences onboarding flag, auth provider
provides:
  - GoRouter configuration with auth/onboarding guards
  - ScaffoldWithNavBar with conditional tab visibility (2 for guests, 4 for auth)
  - StatefulShellRoute.indexedStack for tab state preservation
  - All screens migrated from Navigator named routes to GoRouter
affects: [04-02, 04-03, 04-04, 04-05]

# Tech tracking
tech-stack:
  added: [go_router ^17.3.0, confetti ^0.8.0]
  patterns: [GoRouter redirect guards, StatefulShellRoute indexedStack, ConsumerWidget tab visibility]

key-files:
  created:
    - lib/features/navigation/router.dart
    - lib/features/navigation/scaffold_with_nav_bar.dart
  modified:
    - lib/main.dart
    - lib/features/splash/splash_screen.dart
    - lib/features/home/screens/home_screen.dart
    - lib/features/home/widgets/scenario_cards.dart
    - lib/features/home/widgets/guest_banner.dart
    - lib/features/scenario_selection/screens/scenario_selection_screen.dart
    - lib/features/auth/screens/login_screen.dart
    - lib/features/auth/screens/signup_screen.dart
    - lib/features/auth/screens/forgot_password_screen.dart
    - lib/features/onboarding/screens/onboarding_screen.dart
    - lib/features/conversation/screens/conversation_screen.dart
    - lib/features/feedback/screens/feedback_screen.dart
    - pubspec.yaml

key-decisions:
  - "go_router resolved to ^17.3.0 (latest stable) instead of planned ^14.8.0"
  - "Splash screen simplified to navigate to /home, letting GoRouter redirect handle routing"
  - "Onboarding completion redirected to /home instead of /scenarios"
  - "Guest tab visibility via ConsumerWidget watching isGuestProvider (2 tabs for guests, 4 for auth)"

patterns-established:
  - "GoRouter redirect: async redirect checks Firebase Auth + SharedPreferences onboarding flag"
  - "ScaffoldWithNavBar: ConsumerWidget conditionally builds NavigationBar destinations based on guest state"
  - "All post-auth navigation uses context.go() to trigger GoRouter redirect re-evaluation"

requirements-completed: [FDBK-01, FDBK-02, FDBK-03]

coverage:
  - id: D1
    description: "GoRouter configured with StatefulShellRoute.indexedStack, auth/onboarding guards, and 4-tab bottom nav shell"
    requirement: FDBK-01
    verification:
      - kind: automated_ui
        ref: "flutter analyze lib/features/navigation/router.dart lib/features/navigation/scaffold_with_nav_bar.dart"
        status: pass
    human_judgment: false
  - id: D2
    description: "ScaffoldWithNavBar renders 2 tabs for guests, 4 tabs for authenticated users"
    requirement: FDBK-02
    verification:
      - kind: automated_ui
        ref: "flutter analyze lib/features/navigation/scaffold_with_nav_bar.dart"
        status: pass
    human_judgment: false
  - id: D3
    description: "All existing screens migrated from Navigator named routes to GoRouter context methods"
    requirement: FDBK-03
    verification:
      - kind: automated_ui
        ref: "flutter analyze lib/"
        status: pass
    human_judgment: false
  - id: D4
    description: "App fully migrated from MaterialApp to MaterialApp.router with routerConfig"
    verification:
      - kind: automated_ui
        ref: "flutter analyze lib/main.dart"
        status: pass
    human_judgment: false

# Metrics
duration: 6min
completed: 2026-07-21
status: complete
---

# Phase 4 Plan 01: GoRouter Migration Summary

**GoRouter with StatefulShellRoute.indexedStack for 4-tab bottom nav, auth/onboarding route guards, and full Navigator migration**

## Performance

- **Duration:** 6 min
- **Started:** 2026-07-21T04:39:50Z
- **Completed:** 2026-07-21T04:45:42Z
- **Tasks:** 3
- **Files modified:** 14

## Accomplishments
- GoRouter configured with StatefulShellRoute.indexedStack for stateful tab switching
- Auth guards redirect unauthenticated users to /login, unonboarded users to /onboarding
- ScaffoldWithNavBar conditionally shows 2 tabs for guests, 4 for authenticated users
- All 12 screens migrated from Navigator named routes to GoRouter context methods
- MaterialApp replaced with MaterialApp.router for declarative routing

## Task Commits

Each task was committed atomically:

1. **Task 1: Install go_router and confetti packages** - `6d5978f` (chore)
2. **Task 2: Create GoRouter config and ScaffoldWithNavBar** - `bb3a073` (feat)
3. **Task 3: Migrate main.dart to GoRouter and update SplashScreen** - `15f786f` (feat)

## Files Created/Modified
- `lib/features/navigation/router.dart` - GoRouter config with redirect, StatefulShellRoute, auth/onboarding routes
- `lib/features/navigation/scaffold_with_nav_bar.dart` - Shell widget with conditional tab destinations
- `lib/main.dart` - MaterialApp.router with routerConfig: appRouter
- `lib/features/splash/splash_screen.dart` - Uses context.go() instead of Navigator
- `lib/features/home/screens/home_screen.dart` - Uses context.go() for scenarios navigation
- `lib/features/home/widgets/scenario_cards.dart` - Uses context.push() for conversation
- `lib/features/home/widgets/guest_banner.dart` - Uses context.go() for signup
- `lib/features/scenario_selection/screens/scenario_selection_screen.dart` - Uses context.push() for conversation
- `lib/features/auth/screens/login_screen.dart` - Uses context.go()/context.push() for auth flows
- `lib/features/auth/screens/signup_screen.dart` - Uses context.go() for post-auth navigation
- `lib/features/auth/screens/forgot_password_screen.dart` - Uses context.pop() for back navigation
- `lib/features/onboarding/screens/onboarding_screen.dart` - Uses context.go() after onboarding
- `lib/features/conversation/screens/conversation_screen.dart` - Uses context.go() for feedback, context.pop() for back
- `lib/features/feedback/screens/feedback_screen.dart` - Uses context.go() for scenarios
- `pubspec.yaml` - go_router ^17.3.0 and confetti ^0.8.0 added

## Decisions Made
- go_router resolved to ^17.3.0 (latest stable) instead of planned ^14.8.0 -- API is compatible, StatefulShellRoute works identically
- Splash screen simplified to navigate to /home, letting GoRouter redirect handle auth/onboarding routing
- Onboarding completion redirects to /home (tab shell) instead of /scenarios (direct tab)
- Guest tab visibility uses ConsumerWidget watching isGuestProvider -- tabs are conditionally built in the destinations list

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Migrated additional Navigator calls in home widgets**
- **Found during:** Task 3 (Migrate main.dart to GoRouter)
- **Issue:** scenario_cards.dart and guest_banner.dart still had Navigator.pushNamed calls not in the plan's file list
- **Fix:** Added go_router import and replaced Navigator calls with context.push()/context.go()
- **Files modified:** lib/features/home/widgets/scenario_cards.dart, lib/features/home/widgets/guest_banner.dart
- **Verification:** flutter analyze lib/ passes with 0 errors, grep confirms no remaining Navigator named route calls
- **Committed in:** 15f786f (Task 3 commit)

---

**Total deviations:** 1 auto-fixed (1 missing critical)
**Impact on plan:** Minimal -- two additional widget files needed GoRouter migration for correctness. No scope creep.

## Issues Encountered
None -- plan executed smoothly.

## User Setup Required
None - no external service configuration required.

## Known Stubs
None -- all routes are wired to real screens or intentional placeholders (Progress, Profile).

## Threat Flags
None -- GoRouter redirect guards are client-side only (documented in threat model as T-04-01). Server-side Firestore security rules provide the actual protection.

## Next Phase Readiness
- Navigation foundation complete for all subsequent Phase 4 plans
- Progress and Profile tabs have placeholder screens ready for Plan 03 and beyond
- GoRouter redirect handles auth/onboarding guards -- no manual routing logic needed in screens
- confetti package installed and ready for badge popup animations (Plan 03)

## Self-Check: PASSED

- router.dart: FOUND
- scaffold_with_nav_bar.dart: FOUND
- SUMMARY.md: FOUND
- Commit 6d5978f (Task 1): FOUND
- Commit bb3a073 (Task 2): FOUND
- Commit 15f786f (Task 3): FOUND

---
*Phase: 04-gamification-retention*
*Completed: 2026-07-21*
