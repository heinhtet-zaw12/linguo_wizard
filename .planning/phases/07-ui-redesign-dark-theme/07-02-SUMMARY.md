---
phase: 07-ui-redesign-dark-theme
plan: 02
subsystem: ui-redesign-dark-theme
tags: [ui, theme, dark-mode, glassmorphism, flutter-animate]
dependency_graph:
  requires: [07-01]
  provides: [restyled-screens, dark-theme-navigation-flow]
  affects: [splash, onboarding, auth, home, scenario-selection, srs]
tech_stack:
  added: [flutter_animate]
  patterns: [GlassCard, GradientBackground, semantic-tokens, staggered-animations]
key_files:
  created:
    - lib/features/splash/splash_screen.dart (restyled)
    - lib/features/onboarding/screens/onboarding_screen.dart (restyled)
    - lib/features/onboarding/widgets/language_step.dart (restyled)
    - lib/features/onboarding/widgets/cefr_step.dart (restyled)
    - lib/features/onboarding/widgets/goal_step.dart (restyled)
    - lib/features/auth/screens/login_screen.dart (restyled)
    - lib/features/auth/screens/signup_screen.dart (restyled)
    - lib/features/auth/screens/forgot_password_screen.dart (restyled)
    - lib/features/home/screens/home_screen.dart (restyled)
    - lib/features/home/widgets/streak_ring.dart (restyled)
    - lib/features/home/widgets/goal_ring.dart (restyled)
    - lib/features/home/widgets/daily_challenge_card.dart (restyled)
    - lib/features/home/widgets/scenario_cards.dart (restyled)
    - lib/features/home/widgets/guest_banner.dart (restyled)
    - lib/features/scenario_selection/screens/scenario_selection_screen.dart (restyled)
    - lib/features/scenario_selection/widgets/scenario_card.dart (restyled)
    - lib/features/scenario_selection/screens/create_scenario_screen.dart (restyled)
    - lib/features/srs/screens/pre_scenario_review_screen.dart (restyled)
  modified: []
decisions:
  - "Used GlassCard (not raw Container) for all card containers per design system"
  - "Replaced AppChip with GlassChip throughout scenario selection screens"
  - "Added flutter_animate entrance animations to scenario grid items and auth screen cards"
  - "Used AppGradients.accent for progress dots and button fills instead of solid colors"
metrics:
  duration: 733s
  completed_date: "2026-08-06"
  tasks_completed: 2
  total_tasks: 2
  files_modified: 18
status: complete
---

# Phase 07 Plan 02: Screen Redesign (Entry Flow + Browsing Flow) Summary

Restyled all 18 screen and widget files across splash, onboarding, auth, home, and scenario features from legacy color tokens to the futuristic dark theme. Every card uses GlassCard, every screen uses MeshGradientBackground, and card lists use staggered flutter_animate entrance animations.

## Task Completion

| Task | Name | Commit | Key Changes |
|------|------|--------|-------------|
| 1 | Auth, Onboarding, and Splash Screen Redesign | 68f3da4 | 8 files: splash uses GradientBackground with scale-in logo; onboarding has GlassCard step containers and gradient progress dots; auth screens have GlassCard form containers with AppTextField glass fill |
| 2 | Home Dashboard and Scenario Selection Redesign | 0ee9902 | 10 files: home dashboard has staggered card entrance animations; streak/goal rings use GlassCard; daily challenge has cyan glow; scenario selection uses GlassChip filters and GlassCard grid |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] AppChip renamed to GlassChip**
- **Found during:** Task 2 verification
- **Issue:** The design system from Plan 01 renamed `AppChip` to `GlassChip` with a different API (`isSelected` -> `selected`). Scenario selection and create scenario screens referenced the old name.
- **Fix:** Updated all `AppChip` references to `GlassChip` and adapted parameter names. Added `show GlassChip` import qualifiers.
- **Files modified:** `scenario_selection_screen.dart`, `create_scenario_screen.dart`
- **Commit:** 0ee9902

**2. [Rule 1 - Bug] Duplicate import in login_screen.dart**
- **Found during:** Task 1 verification
- **Issue:** `gradient_background.dart` was imported twice.
- **Fix:** Removed duplicate import.
- **Files modified:** `login_screen.dart`
- **Commit:** 68f3da4

**3. [Rule 1 - Bug] Unused isExpanded parameter on AppButton**
- **Found during:** Task 1 verification
- **Issue:** `AppButton` does not have an `isExpanded` parameter. `onboarding_screen.dart` passed it.
- **Fix:** Removed the `isExpanded` parameter from the AppButton call.
- **Files modified:** `onboarding_screen.dart`
- **Commit:** 68f3da4

## Known Stubs

None - all 18 files are fully wired to the new design system with no placeholder data.

## Threat Flags

None - all changes are visual restyling with no new data flows or security surface.
