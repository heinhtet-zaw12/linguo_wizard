# Phase 06 — Research: Current UI Audit

## Inventory

### Screens (14 total)

| # | Screen | File | Current Style Notes |
|---|--------|------|-------------------|
| 1 | SplashScreen | `lib/features/splash/splash_screen.dart` | Gradient bg, logo, loading dots |
| 2 | LoginScreen | `lib/features/auth/screens/login_screen.dart` | Glass card, `_ClayField`, social buttons |
| 3 | SignUpScreen | `lib/features/auth/screens/signup_screen.dart` | Same as login, duplicated `_ClayField` |
| 4 | ForgotPasswordScreen | `lib/features/auth/screens/forgot_password_screen.dart` | Simple form, same card style |
| 5 | OnboardingScreen | `lib/features/onboarding/screens/onboarding_screen.dart` | Step-based, card selection |
| 6 | HomeScreen | `lib/features/home/screens/home_screen.dart` | Stats row, daily challenge, scenario grid |
| 7 | ScenarioSelectionScreen | `lib/features/scenario_selection/screens/scenario_selection_screen.dart` | Category tabs, CEFR chips, 2-col grid, search |
| 8 | CreateScenarioScreen | `lib/features/scenario_selection/screens/create_scenario_screen.dart` | Form, preview card |
| 9 | ConversationScreen | `lib/features/conversation/screens/conversation_screen.dart` | Voice bubbles, mic button, top bar |
| 10 | FeedbackScreen | `lib/features/feedback/screens/feedback_screen.dart` | Score circle, breakdown, grammar |
| 11 | PreScenarioReviewScreen | `lib/features/srs/screens/pre_scenario_review_screen.dart` | Scenario info, tips, start button |
| 12 | ProgressScreen | `lib/features/progress/screens/progress_screen.dart` | Stats, badges, mistakes |
| 13 | LeaderboardScreen | `lib/features/leaderboard/screens/leaderboard_screen.dart` | Podium, list |
| 14 | ProfileScreen | `lib/features/profile/screens/profile_screen.dart` | Avatar, stats, settings |

### Widgets (17 total)

| Widget | File | Extraction Opportunity |
|--------|------|----------------------|
| StreakRing | `home/widgets/streak_ring.dart` | Keep as-is, update colors |
| GoalRing | `home/widgets/goal_ring.dart` | Keep as-is, update colors |
| DailyChallengeCard | `home/widgets/daily_challenge_card.dart` | Upgrade to glass card |
| ScenarioCards | `home/widgets/scenario_cards.dart` | Upgrade to glass card |
| GuestBanner | `home/widgets/guest_banner.dart` | Upgrade to info-style glass |
| MicButton | `conversation/widgets/mic_button.dart` | Major redesign (pulse animations) |
| VoiceMessageBubble | `conversation/widgets/voice_message_bubble.dart` | Major redesign (glass bubbles) |
| BadgePopup | `badge/widgets/badge_popup.dart` | Update styling, keep confetti |
| LanguageStep | `onboarding/widgets/language_step.dart` | Update card selection style |
| CefrStep | `onboarding/widgets/cefr_step.dart` | Update card selection style |
| GoalStep | `onboarding/widgets/goal_step.dart` | Update card selection style |
| BadgeGrid | `progress/widgets/badge_grid.dart` | Update card style |
| LevelProgress | `progress/widgets/level_progress.dart` | Update bar style |
| MistakeSummary | `progress/widgets/mistake_summary.dart` | Update stat card style |
| ScenarioCard | `scenario_selection/widgets/scenario_card.dart` | Upgrade to glass card, extract CefrBadge |
| ScenarioPreviewCard | `scenario_selection/widgets/scenario_preview_card.dart` | Upgrade to glass card |
| ScaffoldWithNavBar | `navigation/scaffold_with_nav_bar.dart` | Major redesign (glass nav) |

### Duplicated Widgets (to extract)

| Widget | Current Locations | Target |
|--------|------------------|--------|
| `_ClayField` | login_screen.dart, signup_screen.dart | `lib/core/widgets/app_text_field.dart` |
| `_StatCard` | profile_screen.dart, progress_screen.dart | `lib/core/widgets/app_stat_card.dart` |
| `_CefrBadge` | scenario_card.dart, scenario_preview_card.dart | `lib/core/widgets/cefr_badge.dart` |
| `_InfoRow` | scenario_preview_card.dart, profile_screen.dart | `lib/core/widgets/info_row.dart` |
| Gradient background | Every screen (manual LinearGradient) | `lib/core/widgets/gradient_background.dart` |
| Primary button | Every screen (manual ElevatedButton) | `lib/core/widgets/app_button.dart` |

### Theme Files

| File | Current State |
|------|--------------|
| `lib/core/theme/app_theme.dart` | `AppColors` (static constants) + `AppTheme` (single light ThemeData) |

### Duplicated Patterns Across Screens

| Pattern | Occurrences | Current Implementation |
|---------|-------------|----------------------|
| Gradient background | 14 screens | Manual `LinearGradient` in `Container` decoration |
| Primary button | 14 screens | Manual `ElevatedButton` with `AppColors.primaryPink` |
| SafeArea wrapper | 14 screens | `SafeArea(child: ...)` |
| Card decoration | 10+ widgets | `BoxDecoration` with white bg, pink shadow, borderRadius 16-20 |
| Text styling | 68 files | Inline `GoogleFonts.fredoka()` / `GoogleFonts.quicksand()` calls |

## Current Dependency Analysis

### UI Dependencies (to keep)
- `google_fonts: ^6.2.1` — will change usage, not remove
- `confetti: ^0.8.0` — keep for badge animations
- `go_router: ^17.3.0` — keep, no changes
- `flutter_riverpod: ^2.6.0` — keep, no changes

### UI Dependencies (to add)
- `flutter_animate: ^4.5.0` — micro-interactions, screen transitions
- `google_fonts` usage update — Plus Jakarta Sans, Inter, JetBrains Mono

### UI Dependencies (to remove)
- None — all current dependencies are still needed

## Performance Considerations

| Risk | Impact | Mitigation |
|------|--------|------------|
| `BackdropFilter` (glass blur) on low-end devices | Frame drops on old phones | Use `ClipRect` to limit blur area; provide fallback (solid color) if `MediaQuery.disableAnimations` |
| `flutter_animate` on every list item | Jank on long lists | Use `Animate` only on visible items; keep list scrolling raw |
| Dark mode double rendering | Memory overhead | Use `Theme.of(context)` — Flutter handles this efficiently |
| Gradient backgrounds on every screen | GPU overhead | Use `Container` with `BoxDecoration` (rasterized by Flutter) |

## Screen Complexity Ranking (for execution order)

| Priority | Screen | Complexity | Reason |
|----------|--------|------------|--------|
| 1 | Login/Signup | Low | Simple form, 2 screens, good warmup |
| 2 | Onboarding | Low | Step-based, self-contained |
| 3 | Splash | Low | Single screen, animation only |
| 4 | Navigation shell | Medium | Affects all screens, must be right |
| 5 | Home | Medium | Multiple widgets, stats, cards |
| 6 | Scenario Selection | Medium | Grid, chips, search, pagination |
| 7 | Conversation | High | Voice bubbles, mic, animations |
| 8 | Feedback | Medium | Score circle animation, breakdown |
| 9 | Progress | Medium | Stats, badges, charts |
| 10 | Leaderboard | Low | Simple list/podium |
| 11 | Profile | Low | Avatar, settings list |
| 12 | Pre-Scenario Review | Low | Info card, tips |
| 13 | Create Scenario | Low | Form, preview |
| 14 | Badge Popup | Low | Overlay widget |

---

*Research completed 2026-07-30*
