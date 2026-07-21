---
phase: 04-gamification-retention
plan: 03
subsystem: ui
tags: [gamification, progress, leaderboard, srs, badge-popup, viewmodel-integration]

# Dependency graph
requires:
  - phase: 04-01
    provides: GoRouter navigation, bottom nav shell, ScaffoldWithNavBar
  - phase: 04-02
    provides: GamificationService, SrsService, FirestoreService CRUD, Badge/Streak/SRS/Mistake models
provides:
  - Progress screen with level, XP, streak, badges, and mistake summary
  - Leaderboard screen with ranked users by XP
  - Pre-scenario SRS review screen with skip option
  - Badge popup with confetti animation on FeedbackScreen
  - HomeViewModel real streak data from Firestore
  - ConversationViewModel gamification trigger on completion
  - GoRouter routes for all new screens
affects: [04-04, 04-05]

# Tech tracking
tech-stack:
  added: []
  patterns: [AsyncNotifier for data loading, Stack overlay for badge popup, Future.wait for concurrent Firestore queries]

key-files:
  created:
    - lib/features/progress/viewmodels/progress_viewmodel.dart
    - lib/features/progress/screens/progress_screen.dart
    - lib/features/progress/widgets/level_progress.dart
    - lib/features/progress/widgets/badge_grid.dart
    - lib/features/progress/widgets/mistake_summary.dart
    - lib/features/leaderboard/viewmodels/leaderboard_viewmodel.dart
    - lib/features/leaderboard/screens/leaderboard_screen.dart
    - lib/features/srs/viewmodels/srs_viewmodel.dart
    - lib/features/srs/screens/pre_scenario_review_screen.dart
    - lib/features/badge/widgets/badge_popup.dart
    - lib/core/providers/service_providers.dart
  modified:
    - lib/features/home/viewmodels/home_viewmodel.dart
    - lib/features/conversation/viewmodels/conversation_viewmodel.dart
    - lib/features/conversation/providers/conversation_provider.dart
    - lib/features/feedback/screens/feedback_screen.dart
    - lib/features/feedback/viewmodels/feedback_viewmodel.dart
    - lib/features/navigation/router.dart

key-decisions:
  - "Service providers (GamificationService, SrsService) defined in core/providers/service_providers.dart for cross-feature injection"
  - "Badge popup implemented as Stack overlay on FeedbackScreen with sequential display for multiple badges"
  - "ConversationViewModel stores newly earned badges in both ConversationState and newlyEarnedBadgesProvider"
  - "PreScenarioReviewScreen uses ConsumerStatefulWidget for auto-redirect timer management"

patterns-established:
  - "ProgressViewModel: AsyncNotifier loading from Firestore with concurrent Future.wait queries"
  - "BadgePopup: StatefulWidget with ConfettiController lifecycle, auto-dismiss after 4 seconds"
  - "SrsViewModel: AsyncNotifier with review/skip flow, auto-completes when all items reviewed"
  - "LeaderboardViewModel: Direct Firestore query with orderBy, no intermediate service layer"

requirements-completed: [FDBK-01, FDBK-02, FDBK-03]

coverage:
  - id: D1
    description: "Progress screen with level progress bar, stats row, badge grid, and mistake summary"
    requirement: FDBK-01
    verification:
      - kind: automated_ui
        ref: "flutter analyze lib/features/progress/"
        status: pass
    human_judgment: false
  - id: D2
    description: "Leaderboard screen with ranked users, gold/silver/bronze styling, current user highlight"
    requirement: FDBK-02
    verification:
      - kind: automated_ui
        ref: "flutter analyze lib/features/leaderboard/"
        status: pass
    human_judgment: false
  - id: D3
    description: "PreScenarioReview screen showing due SRS items with review/skip options"
    requirement: FDBK-03
    verification:
      - kind: automated_ui
        ref: "flutter analyze lib/features/srs/"
        status: pass
    human_judgment: false
  - id: D4
    description: "BadgePopup with confetti animation, auto-dismiss, and sequential display"
    requirement: FDBK-03
    verification:
      - kind: automated_ui
        ref: "flutter analyze lib/features/badge/"
        status: pass
    human_judgment: false
  - id: D5
    description: "ConversationViewModel triggers streak, XP, badge, SRS, and mistake updates on completion"
    requirement: FDBK-03
    verification:
      - kind: automated_ui
        ref: "flutter analyze lib/features/conversation/viewmodels/conversation_viewmodel.dart"
        status: pass
    human_judgment: false
  - id: D6
    description: "HomeViewModel loads real streak data from Firestore instead of stub"
    requirement: FDBK-01
    verification:
      - kind: automated_ui
        ref: "flutter analyze lib/features/home/viewmodels/home_viewmodel.dart"
        status: pass
    human_judgment: false

# Metrics
duration: 10m
completed: 2026-07-21
status: complete
---

# Phase 04 Plan 03: Gamification UI Integration Summary

**Progress, Leaderboard, Pre-Scenario Review, Badge Popup screens with full ViewModel integration for gamification features**

## Performance

- **Duration:** 10 min
- **Started:** 2026-07-21T05:00:38Z
- **Completed:** 2026-07-21T05:11:00Z
- **Tasks:** 2
- **Files modified:** 17

## Accomplishments
- Created 11 new files: 5 progress widgets/screens, 2 leaderboard files, 2 SRS files, 1 badge widget, 1 service providers file
- Updated 6 existing files: HomeViewModel, ConversationViewModel, ConversationState, FeedbackScreen, FeedbackViewModel, Router
- Progress screen displays real gamification data: level, XP, streak, badges, mistake summary
- Leaderboard shows ranked users by XP with gold/silver/bronze styling
- Pre-scenario review shows due SRS items with review/skip options
- BadgePopup with confetti animation appears on FeedbackScreen after evaluation
- HomeViewModel loads real streak data from Firestore (replaces stub)
- ConversationViewModel triggers streak, XP, badge, SRS, and mistake updates on completion
- Full project passes flutter analyze with 0 errors

## Task Commits

Each task was committed atomically:

1. **Task 1: Create Progress and Leaderboard UI screens** - `0a97916` (feat)
2. **Task 2: Create Pre-Scenario Review, Badge Popup, and wire into ViewModels** - `96cfc82` (feat)
3. **Fix: Pass newly earned badges to FeedbackScreen** - `6392b76` (fix)

## Files Created/Modified
- `lib/features/progress/viewmodels/progress_viewmodel.dart` - ProgressViewModel with level, XP, streak, badges, mistake stats
- `lib/features/progress/screens/progress_screen.dart` - Progress tab with level progress, stats, badge grid, mistake summary
- `lib/features/progress/widgets/level_progress.dart` - Animated progress bar with level name and XP info
- `lib/features/progress/widgets/badge_grid.dart` - 3-column grid showing earned/unearned badges
- `lib/features/progress/widgets/mistake_summary.dart` - Accuracy %, grammar count, vocabulary count
- `lib/features/leaderboard/viewmodels/leaderboard_viewmodel.dart` - Firestore query for top users by XP
- `lib/features/leaderboard/screens/leaderboard_screen.dart` - Ranked list with gold/silver/bronze styling
- `lib/features/srs/viewmodels/srs_viewmodel.dart` - SrsViewModel with review/skip flow
- `lib/features/srs/screens/pre_scenario_review_screen.dart` - Pre-scenario SRS items with auto-redirect
- `lib/features/badge/widgets/badge_popup.dart` - Confetti popup with auto-dismiss after 4 seconds
- `lib/core/providers/service_providers.dart` - GamificationService and SrsService providers
- `lib/features/home/viewmodels/home_viewmodel.dart` - Real streak data from Firestore
- `lib/features/conversation/viewmodels/conversation_viewmodel.dart` - Gamification trigger on completion
- `lib/features/conversation/providers/conversation_provider.dart` - newlyEarnedBadges field in ConversationState
- `lib/features/feedback/screens/feedback_screen.dart` - BadgePopup overlay integration
- `lib/features/feedback/viewmodels/feedback_viewmodel.dart` - newlyEarnedBadgesProvider
- `lib/features/navigation/router.dart` - /progress, /leaderboard, /pre-scenario-review routes

## Decisions Made
- Service providers (GamificationService, SrsService) defined in core/providers/service_providers.dart for cross-feature injection
- Badge popup implemented as Stack overlay on FeedbackScreen with sequential display for multiple badges
- ConversationViewModel stores newly earned badges in both ConversationState and newlyEarnedBadgesProvider for FeedbackScreen access
- PreScenarioReviewScreen uses ConsumerStatefulWidget for auto-redirect timer management

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Created service_providers.dart for GamificationService and SrsService providers**
- **Found during:** Task 1 (Create Progress and Leaderboard UI screens)
- **Issue:** Multiple ViewModels needed to inject GamificationService and SrsService via Riverpod, but no providers existed for these services
- **Fix:** Created lib/core/providers/service_providers.dart with gamificationServiceProvider and srsServiceProvider
- **Files modified:** lib/core/providers/service_providers.dart (new file)
- **Verification:** flutter analyze passes with 0 errors
- **Committed in:** 0a97916 (Task 1 commit)

**2. [Rule 1 - Bug] Fixed ambiguous Badge import between material and core model**
- **Found during:** Task 1 (Create Progress and Leaderboard UI screens)
- **Issue:** badge_grid.dart imported both flutter/material.dart and core/models/badge.dart, causing ambiguous Badge class reference
- **Fix:** Added `hide Badge` to material.dart import in badge_grid.dart
- **Files modified:** lib/features/progress/widgets/badge_grid.dart
- **Verification:** flutter analyze passes with 0 errors
- **Committed in:** 0a97916 (Task 1 commit)

**3. [Rule 1 - Bug] Fixed type casting for Future.wait mixed-type results**
- **Found during:** Task 1 (Create Progress and Leaderboard UI screens)
- **Issue:** Future.wait returns List<Object?> when futures have different return types, causing undefined_getter errors on StreakData fields
- **Fix:** Added explicit `Future.wait<Object?>` type parameter and cast streak result as `StreakData?`
- **Files modified:** lib/features/progress/viewmodels/progress_viewmodel.dart
- **Verification:** flutter analyze passes with 0 errors
- **Committed in:** 0a97916 (Task 1 commit)

---

**Total deviations:** 3 auto-fixed (1 missing critical, 2 bugs)
**Impact on plan:** All auto-fixes necessary for code correctness. No scope creep.

## Issues Encountered
- Task 1 had import conflicts (material Badge vs core Badge) and type casting issues with Future.wait mixed types. All resolved with targeted fixes.

## User Setup Required
None - no external service configuration required.

## Known Stubs
None - all screens display real data from Firestore services. Guest users see "Sign in to view progress" on Progress screen.

## Threat Flags
None - all new surface area (Firestore reads/writes) follows existing patterns and is covered by the plan's threat model (T-04-07, T-04-08).

## Self-Check: PASSED

- All 15 required files verified to exist on disk
- All 2 task commits verified in git history (0a97916, 96cfc82)
- Full project flutter analyze passes with 0 errors
- Progress screen displays real gamification data
- Leaderboard shows ranked users by XP
- PreScenarioReview shows due SRS items with skip option
- BadgePopup shows with confetti animation
- HomeViewModel loads real streak data (not stub)
- ConversationViewModel triggers all gamification updates on completion
- FeedbackScreen displays badge popup when badges are earned
- All routes accessible via GoRouter

---
*Phase: 04-gamification-retention*
*Completed: 2026-07-21*
