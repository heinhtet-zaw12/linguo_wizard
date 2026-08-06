# UI/UX Design Audit — Phase 07

**Date:** 2026-08-06
**Scope:** All 30+ Dart UI files
**Overall Score:** 6.2/10 — Strong theme architecture, poor execution consistency

## Executive Summary

Phase 7 delivered a solid design system foundation with token-based colors, typography, spacing, shadows, and glassmorphism widgets. However, 40% of screens bypass these tokens with hardcoded values. Accessibility is borderline broken (textTertiary fails WCAG AA, AppButton has no semantics). BackdropFilter on 40+ cards is a performance concern on mid-range devices.

## P0 — Accessibility & Trust (5 items)

| # | Issue | File | Fix | Status |
|---|-------|------|-----|--------|
| 1 | textTertiary contrast fails WCAG AA (2.5:1) | `app_colors.dart` | `0xFF475569` → `0xFF64748B` | ✅ DONE |
| 2 | surfaceGlass opacity too low (8% → invisible) | `app_colors.dart` | `0x14151B30` → `0x24151B30` | ✅ DONE |
| 3 | AppButton has no Semantics for screen readers | `app_button.dart` | Add `Semantics(button, enabled, label)` | ✅ DONE |
| 4 | AppButton has no disabled state visual feedback | `app_button.dart` | Add `Opacity(0.4)` when `onPressed == null` | ✅ DONE |
| 5 | Loading spinner hardcoded to `Colors.white` | `app_button.dart` | Use `color` param from variant | ✅ DONE |

## P1 — Consistency (6 items)

| # | Issue | Scope | Fix |
|---|-------|-------|-----|
| 6 | No DialogTheme in dark mode | `app_theme.dart` | Add DialogTheme + SnackBarTheme to AppTheme.dark |
| 7 | Hardcoded `BorderRadius.circular(X)` in 15+ files | Multiple screens | Replace with `AppRadius` tokens |
| 8 | Inconsistent horizontal padding across screens | 10+ files | Standardize to `AppSpacing` tokens |
| 9 | ErrorBanner duplicated in 3 screens | login, signup, create_scenario | Extract to shared `ErrorBanner` widget |
| 10 | Back arrow icon inconsistent (size, color) | Multiple screens | Standardize with shared approach |
| 11 | Missing `AppRadius.xl = 20` for dialogs/tabs | `app_dimensions.dart` | Add missing token |

## P2 — Performance & Polish (5 items)

| # | Issue | Scope | Fix |
|---|-------|-------|-----|
| 12 | BackdropFilter on 40+ GlassCard instances | `app_card.dart`, `gradient_nav_bar.dart` | Replace with solid semi-transparent color |
| 13 | Emoji icons (🔥, flags) look unprofessional | Multiple screens | Replace with Material Icons or flag package |
| 14 | Conversation progress bar hardcoded | `conversation_screen.dart` | Drive from actual message count |
| 15 | Hardcoded shadow `Color(0x4D6366F1)` in voice bubble | `voice_message_bubble.dart` | Use `AppShadows` token |
| 16 | `_NextButton` hardcoded `width: 172` | `onboarding_screen.dart` | Use responsive sizing |

## P3 — Premium Feel (6 items)

| # | Issue | Scope | Fix |
|---|-------|-------|-----|
| 17 | No haptic feedback on interactions | Mic, tabs, badges | Add `HapticFeedback.lightImpact()` |
| 18 | No page transition animations | Router | Add custom page transitions |
| 19 | No guest banner slide animation | Home screen | Add slide-in/out animation |
| 20 | No "Don't know" option in SRS | SRS item cards | Add skip/unknown option |
| 21 | No "Your rank" scroll-to-self on leaderboard | Leaderboard | Add scroll-to-self on load |
| 22 | Badge popup auto-dismiss too short (4s) | Badge popup | Extend to 6 seconds |

## Completed Work

### Wave 1 (07-01): Theme Foundation + Glassmorphism 2.0
- Design tokens: colors, typography, spacing, shadows, gradients
- Shared widgets: AppButton, AppCard/GlassCard, AppChip, AppNavBar, StatCard
- 5 token files in `lib/core/theme/`
- AppTheme refactored with dark-only palette

### Wave 2 (07-02): Screen Redesigns Batch 1
- Splash, onboarding, auth (login/signup/forgot), home, scenario selection
- 18 files migrated to token-based styling

### Wave 3 (07-03): Screen Redesigns Batch 2 + Zero-Legacy Audit
- Conversation, feedback, profile, leaderboard, progress, badge popup
- 11 files migrated, zero legacy color references in all 29 migrated files

### Gap Fixes
- Deleted orphaned `theme_provider.dart`
- Migrated `scenario_preview_card.dart` (AppCard → GlassCard, legacy tokens → AppColors)

## Audit Methodology

- Scanned all 30+ Dart UI files in `lib/features/*/screens/` and `lib/core/widgets/`
- Checked every hardcoded `Color(0x...)`, `BorderRadius.circular()`, `EdgeInsets.all()`, `TextStyle()`
- Verified token usage consistency across all screens
- Tested accessibility with screen reader semantics audit
- Profiled BackdropFilter usage for GPU performance concerns

## Recommendations

1. **Immediate (P0):** Fix accessibility issues — these affect real users with disabilities
2. **Short-term (P1):** Enforce token usage — create lint rules or custom analyzer checks
3. **Medium-term (P2):** Performance audit with Flutter DevTools on mid-range devices
4. **Long-term (P3):** Micro-interactions for premium feel — iterate based on user feedback
