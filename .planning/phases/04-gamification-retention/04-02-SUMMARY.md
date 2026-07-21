---
phase: 04-gamification-retention
plan: 02
subsystem: database
tags: [firestore, gamification, streaks, xp, badges, srs, sm-2]

# Dependency graph
requires:
  - phase: 03-accounts-cloud-sync
    provides: FirestoreService, auth state, user document structure
  - phase: 04-01
    provides: GoRouter navigation, bottom nav shell
provides:
  - Badge definitions and eligibility checking
  - Level progression system (5 tiers, 500 XP each)
  - Streak tracking with daily reset logic
  - SRS engine with SM-2 algorithm for spaced repetition
  - Mistake record model for learning analytics
  - GamificationService coordinating streak/XP/level/badge logic
  - SrsService for SRS item lifecycle management
  - FirestoreService extended with full gamification CRUD
affects: [04-03, 04-04, 04-05]

# Tech tracking
tech-stack:
  added: []
  patterns: [fire-and-forget firestore writes, sm-2 spaced repetition, config-driven badge system]

key-files:
  created:
    - lib/core/config/badge_config.dart
    - lib/core/config/level_config.dart
    - lib/core/models/streak_data.dart
    - lib/core/models/badge.dart
    - lib/core/models/srs_item.dart
    - lib/core/models/mistake_record.dart
    - lib/core/services/gamification_service.dart
    - lib/core/services/srs_service.dart
  modified:
    - lib/core/config/app_config.dart
    - lib/core/services/firestore_service.dart

key-decisions:
  - "Config-driven badge system: new badges can be added without code changes"
  - "SM-2 algorithm implemented in SrsItem.review() for interval calculation"
  - "FirestoreService methods use merge: true for progress document updates"
  - "MistakeRecord designed for 7-day rolling window with cleanup method"

patterns-established:
  - "Badge definition pattern: BadgeDefinition class with BadgeCondition for extensibility"
  - "Level progression: linear 500 XP per tier with getLevelInfo helper"
  - "SRS item lifecycle: review() updates SM-2 parameters, isDue getter checks readiness"
  - "Firestore subcollection pattern: users/{uid}/subcollection for badges, srs_items, mistakes"

requirements-completed: [FDBK-03]

coverage:
  - id: D1
    description: "8 gamification config and model files with SM-2 algorithm and badge definitions"
    requirement: "FDBK-03"
    verification:
      - kind: unit
        ref: "flutter analyze lib/core/config/ lib/core/models/"
        status: pass
    human_judgment: false
  - id: D2
    description: "GamificationService and SrsService with streak, XP, level, badge, and SRS management"
    requirement: "FDBK-03"
    verification:
      - kind: unit
        ref: "flutter analyze lib/core/services/gamification_service.dart lib/core/services/srs_service.dart"
        status: pass
    human_judgment: false
  - id: D3
    description: "FirestoreService extended with gamification CRUD for streaks, XP, badges, SRS, and mistakes"
    requirement: "FDBK-03"
    verification:
      - kind: unit
        ref: "flutter analyze lib/core/services/firestore_service.dart"
        status: pass
    human_judgment: false

# Metrics
duration: 4m
completed: 2026-07-21
status: complete
---

# Phase 04 Plan 02: Gamification Data Layer Summary

**Gamification data layer with SM-2 SRS engine, badge definitions, streak tracking, level progression, and Firestore CRUD for all gamification data**

## Performance

- **Duration:** 4 min
- **Started:** 2026-07-21T04:51:50Z
- **Completed:** 2026-07-21T04:56:35Z
- **Tasks:** 3
- **Files modified:** 10

## Accomplishments
- Created 8 new files: 2 config files (badges, levels), 4 data models (streak, badge, SRS item, mistake record), 2 services (gamification, SRS)
- Implemented SM-2 spaced repetition algorithm with ease factor adjustment and interval progression
- Extended FirestoreService with 14 new methods for gamification CRUD operations
- Updated AppConfig.xpPerScenario from 10 to 50 per D-07 decision

## Task Commits

Each task was committed atomically:

1. **Task 1: Create config files and data models** - `af2e226` (feat)
2. **Task 2: Create GamificationService and SrsService** - `df564d5` (feat)
3. **Task 3: Update AppConfig and extend FirestoreService** - `768ddbf` (chore)

## Files Created/Modified
- `lib/core/config/badge_config.dart` - Badge definitions with 8 badges (milestone + skill categories)
- `lib/core/config/level_config.dart` - Level progression (Beginner through Master, 500 XP per tier)
- `lib/core/models/streak_data.dart` - Streak tracking with daily reset logic
- `lib/core/models/badge.dart` - Earned badge instance model
- `lib/core/models/srs_item.dart` - SRS item with SM-2 review algorithm
- `lib/core/models/mistake_record.dart` - Grammar/vocabulary mistake tracking
- `lib/core/services/gamification_service.dart` - Coordinates streak, XP, level, badge logic
- `lib/core/services/srs_service.dart` - SRS item lifecycle management
- `lib/core/config/app_config.dart` - Updated xpPerScenario to 50
- `lib/core/services/firestore_service.dart` - Extended with 14 gamification CRUD methods

## Decisions Made
- Config-driven badge system: new badges added via badgeDefinitions list without code changes
- SM-2 algorithm implemented in SrsItem.review() with quality threshold (>=3 advances, <3 resets)
- FirestoreService methods use merge: true for progress document updates to avoid overwriting
- MistakeRecord designed for 7-day rolling window with cleanupOldMistakes method
- GamificationService.checkBadges supports optional scenarioDuration for fast_learner badge

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] FirestoreService methods added in Task 2 to resolve dependency**
- **Found during:** Task 2 (Create GamificationService and SrsService)
- **Issue:** Task 2 services referenced FirestoreService methods that were planned for Task 3
- **Fix:** Added FirestoreService gamification CRUD methods (14 methods) during Task 2 to resolve compilation errors
- **Files modified:** lib/core/services/firestore_service.dart
- **Verification:** flutter analyze passes with 0 errors on all service files
- **Committed in:** df564d5 (Task 2 commit)

**2. [Rule 1 - Bug] Fixed dangling library doc comment warnings**
- **Found during:** Task 1 (Create config files and data models)
- **Issue:** Flutter analyze flagged info-level warnings about dangling library doc comments
- **Fix:** Added `library;` declaration after doc comments in all 5 new files
- **Files modified:** lib/core/config/badge_config.dart, lib/core/config/level_config.dart, lib/core/models/streak_data.dart, lib/core/models/srs_item.dart, lib/core/models/mistake_record.dart
- **Verification:** flutter analyze shows 0 issues on all files
- **Committed in:** af2e226 (Task 1 commit)

---

**Total deviations:** 2 auto-fixed (1 blocking, 1 bug)
**Impact on plan:** Both auto-fixes necessary for code correctness and clean analysis. No scope creep.

## Issues Encountered
- Task 2 and Task 3 had a dependency ordering issue: Task 2 services called FirestoreService methods defined in Task 3. Resolved by moving FirestoreService additions to Task 2 commit.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Gamification data layer complete and ready for UI consumption in Plan 03
- All models, configs, and services pass flutter analyze with 0 errors
- FirestoreService ready to persist streak, XP, badges, SRS, and mistake data per user
- ConversationViewModel can now call GamificationService.awardXp() after scenario completion

## Self-Check: PASSED

- All 11 files verified to exist on disk
- All 4 commits verified in git history
- AppConfig.xpPerScenario confirmed as 50

---
*Phase: 04-gamification-retention*
*Completed: 2026-07-21*
