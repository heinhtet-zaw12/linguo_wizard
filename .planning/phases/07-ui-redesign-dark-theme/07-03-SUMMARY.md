---
phase: 07-ui-redesign-dark-theme
plan: 03
subsystem: ui-redesign-dark-theme
tags: [ui, theme, dark-mode, glassmorphism, flutter-animate, confetti, animations]
dependency_graph:
  requires: [07-02]
  provides: [restyled-screens, dark-theme-conversation, dark-theme-feedback, dark-theme-profile, dark-theme-leaderboard, dark-theme-progress]
  affects: [conversation, feedback, profile, leaderboard, progress, badge]
tech_stack:
  added: [confetti]
  patterns: [GlassCard, GradientBackground, semantic-tokens, staggered-animations, pulse-rings, animated-score-circle]
key_files:
  created: []
  modified:
    - lib/features/conversation/screens/conversation_screen.dart
    - lib/features/conversation/widgets/mic_button.dart
    - lib/features/conversation/widgets/voice_message_bubble.dart
    - lib/features/feedback/screens/feedback_screen.dart
    - lib/features/profile/screens/profile_screen.dart
    - lib/features/leaderboard/screens/leaderboard_screen.dart
    - lib/features/progress/screens/progress_screen.dart
    - lib/features/progress/widgets/level_progress.dart
    - lib/features/progress/widgets/mistake_summary.dart
    - lib/features/progress/widgets/badge_grid.dart
    - lib/features/badge/widgets/badge_popup.dart
decisions:
  - "Removed dark mode toggle UI from profile screen (dark-only per D-01)"
  - "GlassCard used for all card containers across all screens"
  - "AnimatedBuilder used for mic button pulse rings (3 concentric, staggered)"
  - "Confetti package reused from existing dependency for feedback and badge popup"
  - "Voice message entrance animations use flutter_animate slideX from sender side"
metrics:
  duration: 380s
  completed_date: "2026-08-06"
  tasks_completed: 2
  total_tasks: 2
  files_modified: 11
status: complete
---

# Phase 07 Plan 03: Screen Redesign (Conversation, Feedback, Profile, Leaderboard, Progress) Summary

Completed the futuristic dark theme migration across all remaining screens: conversation (hero screen), feedback, profile, leaderboard, progress, and badge popup. Applied glassmorphism 2.0 components, staggered animations, and the new animation system (mic button states, score circle counter, confetti).

## Task Completion

| Task | Name | Commit | Key Changes |
|------|------|--------|-------------|
| 1 | Conversation Screen Redesign — Mic Button and Voice Bubbles | a73390a | 3 files: GlassCard top bar with gradient progress bar, 4-state mic button (gradient idle, pulsing cyan recording rings, spinner processing, glass speaking) with scale spring, gradient user bubbles and glass AI bubbles with slide-from-sender entrance |
| 2 | Feedback, Profile, Leaderboard, Progress, and Badge Screen Redesign | 31cc5cd | 8 files: animated score circle (800ms counter, confetti on 80+), staggered breakdown cards, gradient-bordered avatar with no dark mode toggle, GlassCard leaderboard rows with gold/silver/bronze accents, glass progress/badge widgets, scale-in badge popup |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] GlassCard margin parameter does not exist**
- **Found during:** Task 2 (feedback_screen.dart grammar corrections)
- **Issue:** GlassCard widget does not accept a `margin` parameter
- **Fix:** Wrapped GlassCard in Padding widget for bottom margin
- **Files modified:** feedback_screen.dart
- **Commit:** 31cc5cd

**2. [Rule 2 - Missing critical] Profile screen missing app_shadows import**
- **Found during:** Task 2 (profile_screen.dart gradient avatar)
- **Issue:** Profile screen used `AppShadows.glowBlue` without importing app_shadows.dart
- **Fix:** Added `import '../../../core/theme/app_shadows.dart';`
- **Files modified:** profile_screen.dart
- **Commit:** 31cc5cd

## Known Stubs

None - all 11 files are fully wired to the new design system with no placeholder data.

## Threat Flags

None - all changes are visual restyling and animation, no data flows across trust boundaries.

## Pre-existing Errors (Out of Scope)

The following errors exist in files NOT modified by this plan and are pre-existing:
- `lib/features/navigation/scaffold_with_nav_bar.dart` — AppNavBar/AppNavDestination undefined, const initialization error
- `lib/features/scenario_selection/widgets/scenario_preview_card.dart` — still references legacy tokens (primaryPinkDark, primaryPinkLight, textDark, textMuted) and undefined AppCard method
- `lib/core/providers/theme_provider.dart` — `AppTheme.updateColorProvider` method not defined
- `test/viewmodels/scenario_selection_test.dart` — getter/parameter mismatches
- `test/widget_test.dart` — undefined named parameter

These errors are NOT caused by this plan's changes.
