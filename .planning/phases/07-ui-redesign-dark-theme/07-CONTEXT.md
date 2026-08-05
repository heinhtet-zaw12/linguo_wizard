# Phase 7: UI Redesign — Futuristic Dark Theme - Context

**Gathered:** 2026-08-05
**Status:** Ready for planning
**Source:** PRD Express Path (docs/superpowers/specs/2026-08-05-ui-redesign-design.md)

<domain>
## Phase Boundary

Full UI redesign of the Flutter app from pastel claymorphism to a futuristic dark-only theme with blue-violet electric palette, frosted glass cards (Glassmorphism 2.0), animated gradient mesh backgrounds, and maximum micro-interactions. Zero business logic changes — design layer files only (theme tokens, widgets, screens).

**13 screens** affected: splash, onboarding, auth (login/signup/forgot), home dashboard, scenario selection, create scenario, pre-scenario review, conversation, feedback, profile, leaderboard, progress, badge popup.

**30+ files** with legacy color references (333 instances) that must be migrated.
</domain>

<decisions>
## Implementation Decisions

### D-01: Dark-only theme (locked)
Removes Phase 6 light/dark toggle, ThemeModeProvider, AppColorProvider. Single flat dark palette. Phase 6 toggle infrastructure deleted, not repurposed.

### D-02: Blue-violet electric palette (locked)
- surfaceBase: #0A0E1A, surface0: #0F1424, surface1: #151B30, surface2: #1C2340, surface3: #242D50
- accentStart: #6366F1, accentMid: #8B5CF6, accentEnd: #A78BFA, accentCyan: #22D3EE
- textPrimary: #F1F5F9, textSecondary: #94A3B8, textTertiary: #475569
- success: #34D399, warning: #FBBF24, danger: #F87171

### D-03: Glassmorphism 2.0 components (locked)
All cards, chips, nav bar use frosted glass (BackdropFilter blur: 20, glass opacity 0.08, border opacity 0.12). GlassCard replaces AppCard, GlassChip replaces AppChip.

### D-04: Keep current fonts (locked)
Plus Jakarta Sans (headings), Inter (body), JetBrains Mono (numbers/scores). No font changes.

### D-05: Static mesh gradient first, animated deferred (locked)
Step 2 ships static layered RadialGradient mesh (3-4 blobs at 5-8% opacity). Animated mesh with CustomPainter deferred to Step 10 polish phase — only if static feels flat.

### D-06: Implementation order from spec §8 (locked)
0. Legacy color migration (333 instances, 30 files) — blocks everything
1. Theme foundation (app_colors, app_gradients, app_theme, app_text_styles, app_dimensions, app_shadows)
2. Core widgets (GlassCard, AppButton, GlassChip, GradientNavBar, MeshGradientBackground, etc.)
3. Auth screens (login, signup, forgot password)
4. Onboarding + splash
5. Home dashboard (most complex)
6. Scenario selection + create/pre-review
7. Conversation (mic, voice bubbles)
8. Feedback (score circle, corrections)
9. Remaining screens (profile, leaderboard, progress, badge)
10. Polish (animated mesh, animation tuning, dark-mode consistency audit)

### D-07: Zero business logic changes (locked)
No changes to viewmodels, models, providers (except AppColorProvider deletion), services, routing logic. Only theme files, widget files, screen UI files.

### D-08: AppRadius token shift (locked)
sm=12 (was 8), md=16 (was 12), lg=24 (was 16), xl removed (use lg), full renamed to pill=9999.

### D-09: AppColorProvider + ThemeModeProvider deletion (locked)
Delete AppColorProvider class entirely. Delete ThemeModeProvider + SharedPreferences dark mode persistence from Phase 6.

### D-10: Glow shadows new pattern (locked)
Add glowBlue (0 0 20px rgba(99,102,241,0.3)) and glowCyan (0 0 16px rgba(34,211,238,0.25)) to AppShadows. Used on CTAs, badges, active states.

### D-11: New AppGradients utility (locked)
Create app_gradients.dart with accent, accentCyan, surface gradient builders.

### D-12: Screen transition specs (locked)
Push: slide from right + fade (300ms, easeOut). Pop: slide to right + fade (250ms). Dialogs: scale from 0.9 + fade (250ms, spring). Card entrance: fadeIn + slideY 400ms staggered 50ms.

### D-13: AppButton 3 variants (locked)
Primary: gradient fill + glow, 52px height. Secondary: glass fill + accentCyan border. Ghost: text only, accentCyan color. Press: scale 0.97 over 100ms, spring back 200ms.

### Claude's Discretion
- Exact file naming for renamed widgets (app_card.dart → glass_card.dart vs keeping name)
- Whether to use flutter_animate or manual AnimationController for card entrance animations
- Whether MeshGradientBackground should be a separate widget or inline Stack pattern
- Performance tuning: glass blur sigma, animation durations
- Confetti implementation details for high scores

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Design Spec
- `docs/superpowers/specs/2026-08-05-ui-redesign-design.md` — Full design spec (441 lines): color palette, typography, 9 component redesigns, 13 screen layouts, animation system, implementation order

### Current Theme System
- `lib/core/theme/app_colors.dart` — Current color system (will be fully rewritten)
- `lib/core/theme/app_theme.dart` — Current theme config (will be simplified to dark-only)
- `lib/core/theme/app_text_styles.dart` — Current text styles (color defaults will update)
- `lib/core/theme/app_dimensions.dart` — Current radius tokens (will shift values)
- `lib/core/theme/app_shadows.dart` — Current shadow system (will add glow tokens)

### Current Widgets
- `lib/core/widgets/app_card.dart` — Current glass card (will become GlassCard)
- `lib/core/widgets/app_button.dart` — Current button (will get 3 variants)
- `lib/core/widgets/app_chip.dart` — Current chip (will become GlassChip)
- `lib/core/widgets/app_nav_bar.dart` — Current nav bar (will get gradient indicator)
- `lib/core/widgets/gradient_background.dart` — Current gradient (will become static mesh)
- `lib/core/widgets/stat_card.dart` — Current stat card (will get glass styling)
- `lib/core/widgets/cefr_badge.dart` — Current CEFR badge (will get cyan glow)

### Legacy Color Migration Map
- 333 legacy color references across 30 files — see spec §0 migration notes for full token mapping table

</canonical_refs>

<specifics>
## Specific Ideas

- Animated mesh gradient: 3-4 color blobs (accentStart, accentMid, accentCyan) at 5-8% opacity, layered RadialGradient on Stack
- Voice message bubbles: user gradient fill, AI glass fill, waveform bars in gradient colors
- Score circle: 120px gradient fill with counter animation (0→score, 800ms)
- High score confetti: use existing confetti package in pubspec.yaml
- Daily Challenge: larger GlassCard with gradient border glow, "Today's Challenge" badge
- Guest banner: GlassCard with accentCyan border
- All cards: staggered entrance animation (fade + slide, 50ms delay between)
- Mic button: 72px circle, gradient fill, recording state = pulsing accentCyan concentric rings

</specifics>

<deferred>
## Deferred Ideas

- Animated gradient mesh (Step 10 polish — static mesh ships first)
- Myanmar (Burmese) language UI — localization support
- Dynamic transcript translation
- Any business logic or routing changes

</deferred>

---

*Phase: 07-ui-redesign-dark-theme*
*Context gathered: 2026-08-05 via PRD Express Path*
