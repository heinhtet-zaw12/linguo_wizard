# UI Redesign Design Spec — Futuristic Dark Theme

**Date:** 2026-08-05
**Status:** Approved
**Scope:** Full UI redesign — all screens, all widgets, all theme tokens
**Constraint:** Zero business logic changes. Only design-layer files

---

## 0. Migration Notes (read before implementing)

### Legacy Color Cleanup — 333 instances across 30 files

The current codebase uses 10 legacy color tokens that must be replaced with the new semantic system:

| Legacy Token | Replacement | Notes |
|---|---|---|
| `AppColors.primaryPink` | `accentStart` or `accentMid` | Primary brand color |
| `AppColors.primaryPinkDark` | `accentStart` | Darker variant |
| `AppColors.primaryPinkLight` | `accentEnd` | Lighter variant |
| `AppColors.textDark` | `textPrimary` | Main text on dark bg |
| `AppColors.textMuted` | `textSecondary` | Descriptions |
| `AppColors.bgTop` | `surface0` | Screen background top |
| `AppColors.bgBottom` | `surface1` | Screen background bottom |
| `AppColors.accentGold` | `warning` | Streaks, achievements |
| `AppColors.accentCoral` | `danger` | Errors |
| `AppColors.shadowPink` | `elevation1` color | Shadows |

**Affected files (30):** All screen files in `lib/features/*/screens/`, all widget files in `lib/features/*/widgets/`, plus `lib/features/splash/splash_screen.dart`.

**Strategy:** Do this as Step 0 before touching any widget. Grep for each legacy token, replace with semantic equivalent, verify `flutter analyze` passes after each batch.

### Radius Token Shift

Current `AppRadius` values are shifted down from the spec:

| Current | Spec | Implication |
|---|---|---|
| `sm = 8` | `sm = 12` | All `AppRadius.sm` usages increase |
| `md = 12` | `md = 16` | All `AppRadius.md` usages increase |
| `lg = 16` | `lg = 24` | All `AppRadius.lg` usages increase |
| `xl = 24` | *(removed)* | Replace `AppRadius.xl` with `AppRadius.lg` |
| `full = 9999` | `pill = 9999` | Rename only |

**Strategy:** Update `AppRadius` token file first, then do a project-wide find-replace for renamed tokens. Expect visual changes to every card, button, and chip.

### AppColorProvider Removal

Current pattern: `AppColorProvider` holds static `currentColor` that screens read via `AppColors.xxx`. The spec removes `LightColors`/`DarkColors` classes and replaces with a single flat palette.

**Strategy:** After updating `app_colors.dart`, delete `AppColorProvider` class entirely. Replace all `AppColors.xxx` references with direct static constants from the new palette. No provider needed for dark-only.

### Glow Shadows — New Pattern

Current `AppShadows` uses neutral `shadowColor` only. The spec adds colored glow tokens (`glowBlue`, `glowCyan`) which are a new pattern — colored box-shadows for CTAs and badges.

**Strategy:** Add `glowBlue` and `glowCyan` as new static getters in `AppShadows`. These are additive, not breaking.

---

## 1. Design Direction

**Mood:** Futuristic & bold
**Palette:** Blue-violet electric — deep navy/charcoal base, electric blue + violet gradients, cyan highlights
**Glassmorphism:** Frosted glass cards with backdrop blur (Glassmorphism 2.0)
**Animations:** Maximum micro-interactions — spring physics, animated gradient mesh, particle effects
**Background:** Animated gradient mesh (always visible, slowly shifting)
**Mode:** Dark-only (no light mode)

> **Decision: Dark-only removes light mode.** Phase 6 implemented a full light/dark toggle with `ThemeModeProvider`, `SharedPreferences` persistence, and `AppColorProvider` sync. This spec replaces all of that with a single dark palette. The Phase 6 toggle infrastructure will be deleted, not repurposed. This is intentional — the dark-only approach simplifies the token system and gives a more focused, premium feel.

---

## 2. Color Palette & Design Tokens

### 2.1 Base (Dark Surface System)

| Token | Hex | Use |
|-------|-----|-----|
| `surfaceBase` | `#0A0E1A` | True background (deepest) |
| `surface0` | `#0F1424` | Screen background |
| `surface1` | `#151B30` | Card backgrounds (frosted glass base) |
| `surface2` | `#1C2340` | Elevated surfaces, modals |
| `surface3` | `#242D50` | Hovered/active states |

### 2.2 Accent Gradient (Electric Blue → Violet)

| Token | Hex | Use |
|-------|-----|-----|
| `accentStart` | `#6366F1` | Indigo-500 (gradient start) |
| `accentMid` | `#8B5CF6` | Violet-500 (gradient mid) |
| `accentEnd` | `#A78BFA` | Violet-400 (gradient end) |
| `accentCyan` | `#22D3EE` | Highlights, badges, success indicators |
| `accentCyanGlow` | `#06B6D4` | Glowing borders, CTAs |

### 2.3 Semantic Colors

| Token | Hex | Use |
|-------|-----|-----|
| `textPrimary` | `#F1F5F9` | Main text |
| `textSecondary` | `#94A3B8` | Body text, descriptions |
| `textTertiary` | `#475569` | Hints, disabled |
| `textOnAccent` | `#FFFFFF` | Text on accent backgrounds |
| `success` | `#34D399` | Correct, completed, XP earned |
| `warning` | `#FBBF24` | Streaks, achievements, gold |
| `danger` | `#F87171` | Errors, corrections |
| `borderSubtle` | `#1E293B` | Card borders |
| `borderGlow` | `#6366F140` | Focus states, active borders |

### 2.4 Glass Tokens

| Token | Value | Use |
|-------|-------|-----|
| `glassOpacity` | `0.08` | Card glass fill |
| `glassBorderOpacity` | `0.12` | Card glass borders |
| `glassBlur` | `20.0` | BackdropFilter sigma |

### 2.5 Shadow System

| Level | Value | Use |
|-------|-------|-----|
| `elevation1` | `0 2px 8px rgba(0,0,0,0.3)` | Resting cards |
| `elevation2` | `0 4px 16px rgba(0,0,0,0.4)` | Focused cards |
| `elevation3` | `0 8px 32px rgba(0,0,0,0.5)` | Modals |
| `glowBlue` | `0 0 20px rgba(99,102,241,0.3)` | Accent glow on CTAs |
| `glowCyan` | `0 0 16px rgba(34,211,238,0.25)` | Cyan glow on badges |

### 2.6 Gradient Builder

A reusable `AppGradients` utility class:
- `accent` → `LinearGradient(colors: [accentStart, accentMid, accentEnd])`
- `accentCyan` → `LinearGradient(colors: [accentCyan, accentStart])`
- `surface` → `LinearGradient(colors: [surface0, surface1])`

---

## 3. Typography

**Font families (unchanged):**
- Headings: Plus Jakarta Sans (`GoogleFonts.plusJakartaSans`)
- Body: Inter (`GoogleFonts.inter`)
- Numbers: JetBrains Mono (`GoogleFonts.jetBrainsMono`)

### 3.1 Text Styles

| Style | Size | Weight | Height | Color Default | Use |
|-------|------|--------|--------|---------------|-----|
| `displayLarge` | 32 | 700 | 1.25 | `textPrimary` | Hero numbers, scores (Mono) |
| `displayMedium` | 24 | 700 | 1.33 | `textPrimary` | Screen titles |
| `headingLarge` | 20 | 600 | 1.40 | `textPrimary` | Section headers |
| `headingMedium` | 17 | 600 | 1.41 | `textPrimary` | Card titles |
| `headingSmall` | 15 | 600 | 1.47 | `textPrimary` | Sub-headers |
| `bodyLarge` | 16 | 400 | 1.50 | `textSecondary` | Body text |
| `bodyMedium` | 14 | 400 | 1.43 | `textSecondary` | Descriptions |
| `bodySmall` | 13 | 400 | 1.38 | `textTertiary` | Captions |
| `labelLarge` | 14 | 500 | 1.43 | `textPrimary` | Button text |
| `labelMedium` | 12 | 500 | 1.33 | `textSecondary` | Chips, tags |
| `labelSmall` | 11 | 600 | 1.27 | `textTertiary` | Badges |

### 3.2 Changes from Current
- Remove all legacy `AppColors.textDark`, `AppColors.textMuted`, `AppColors.primaryPink` references
- Every text color now maps to the new semantic system
- All colors designed for dark-on-light contrast on dark backgrounds

---

## 4. Component System

### 4.1 GlassCard (replaces AppCard)
- `BackdropFilter(blur: 20)` frosted glass
- Background: `surface1` with `glassOpacity` (0.08)
- Border: `borderSubtle` with `glassBorderOpacity` (0.12), 0.5px
- Optional `glowColor` param — adds colored box-shadow when set
- Border radius tokens: `sm` = 12px, `md` = 16px, `lg` = 24px, `pill` = 9999px

### 4.2 AppButton (3 variants)
- **Primary:** Gradient fill (accentStart → accentEnd), 16px border radius, glow shadow (`0 0 20px rgba(99,102,241,0.35)`), white text, 52px height
- **Secondary:** Glass-filled with `accentCyan` border, glass background
- **Ghost:** Text only, `accentCyan` color, no background
- Press animation: scale 0.97 over 100ms, spring back 200ms
- Loading: gradient spinner replaces text

### 4.3 GlassChip (replaces AppChip)
- Selected: solid gradient fill (accentStart → accentEnd), glow shadow, white text
- Unselected: glass fill, subtle border, `textSecondary` text
- Pill shape (border radius 9999), 36px height
- Selection transition: background color 200ms

### 4.4 GradientNavBar (replaces AppNavBar)
- Glass panel: `surface1` with glass fill + backdrop blur
- Top border: 0.5px `borderSubtle`
- Active tab: gradient indicator pill (accentStart → accentEnd), glow, white icon
- Inactive: `textTertiary` icon
- Entrance: slide-up + fade (300ms)

### 4.5 MeshGradientBackground (replaces GradientBackground)
- **Phase A (Step 2):** Static mesh — `Stack` of layered `Positioned` + `RadialGradient` containers. 3-4 color blobs (accentStart, accentMid, accentCyan at 5-8% opacity). No animation, no CustomPainter. Clean, fast, zero risk.
- **Phase B (Step 10, optional):** Animated mesh — `CustomPainter` + `AnimationController` for drifting blobs (30s cycle). `RepaintBoundary` for performance. Only if static version feels flat after full app is themed.

### 4.6 MicButton
- Size: 72px circle
- Idle: gradient fill (accentStart → accentEnd), white mic icon, blue glow shadow
- Recording: pulsing accentCyan concentric rings, red stop icon
- Processing: animated gradient spinner
- Speaking: muted glass, volume icon
- Press: scale spring (0.9 → 1.0)

### 4.7 VoiceMessageBubble
- User: gradient fill (accentStart → accentEnd), white mic icon, glass border
- AI: glass fill with subtle glow border, play/pause in accentCyan
- Waveform: gradient-colored bars (accentStart → accentEnd), animate during playback
- Transcript toggle: accentCyan text, underline
- Entrance: slide from sender side + fade (300ms)

### 4.8 StatCard
- Glass card with icon in small gradient-filled circle
- Value: JetBrains Mono 24px, `textPrimary`
- Label: Inter 12px, `textSecondary`
- Entrance: fade + slide up (400ms)

### 4.9 CefrBadge
- Glass pill with accentCyan border glow
- Text: JetBrains Mono 11px, `accentCyan`
- Selected: filled accentCyan, dark text

---

## 5. Screen Layouts (13 screens)

> **Note:** The codebase has 13 screen files, not 10. The three missing from the original spec are: `create_scenario_screen.dart`, `pre_scenario_review_screen.dart`, and `splash_screen.dart`. All are included below.

### 5.0 Splash Screen
- Animated mesh gradient fills entire screen (first impression)
- App logo centered with scale-in animation (400ms, spring)
- Loading indicator: gradient spinner below logo
- Auto-navigate after 2s or on first frame render

### 5.1 Onboarding
- Full-screen animated mesh gradient background
- 3-page PageView with parallax transition
- Each step: GlassCard floating over mesh
- Progress dots: gradient-filled active, glass inactive
- "Next" button: primary gradient + glow
- 200ms page transition with subtle scale

### 5.2 Auth (Login/Signup/Forgot Password)
- Centered layout, glass card container
- App logo at top
- Form fields: glass-filled with accentCyan focus border glow
- Primary button: gradient + glow
- Google sign-in: secondary glass button
- Guest: ghost button
- Error banners: danger-tinted glass
- Card entrance: fade + slide up

### 5.3 Home Dashboard
- Animated mesh gradient fills entire screen (always visible)
- Welcome header: displayMedium + greeting body
- Streak card: GlassCard, flame icon in gradient circle, streak count in Mono, gold accent
- Daily goal ring: GlassCard, circular progress (gradient stroke), XP count
- Daily Challenge hero: larger GlassCard, gradient border glow, "Today's Challenge" badge
- Recommended section: horizontal scrolling scenario cards
- Scenario cards: GlassCard, gradient accent stripe, title, CEFR badge, category
- Guest banner: GlassCard with accentCyan border
- All cards: staggered entrance (fade + slide, 50ms delay between)

### 5.4 Scenario Selection
- Search bar: glass-filled, rounded, magnifying glass
- Category tabs: horizontal GlassChip scroll
- CEFR filter chips: horizontal GlassChip row
- Scenario grid: 2-column SliverGrid
- Each card: GlassCard, gradient top stripe, icon, title, CEFR badge
- Completed: check badge + "Twist" button (accentCyan)
- Infinite scroll with glass loading spinner
- Staggered grid entrance animation

### 5.4a Create Scenario
- Full-screen form over mesh gradient
- Title field: glass-filled, accentCyan focus glow
- Description field: glass-filled multiline
- Difficulty selector: 3 GlassChips (Easy/Medium/Hard)
- Generate button: primary gradient + glow
- Preview card: GlassCard showing generated scenario
- Save button: primary gradient, disabled until preview loaded
- Cancel: ghost button

### 5.4b Pre-Scenario Review
- Scenario info card: GlassCard with title, description, CEFR badge, difficulty
- Tips section: glass card with bulleted hints
- "Start Conversation" button: primary gradient + glow, large
- Back: ghost button

### 5.5 Conversation Screen (Hero Screen)
- Background: animated mesh gradient (slightly more vibrant)
- Top bar: glass panel, frosted blur, scenario title + goal
- Message list: VoiceMessageBubbles
- Mic button area: bottom-fixed glass panel, gradient mic button
- Recording: animated concentric rings (accentCyan)
- Partial transcript: floating glass pill
- End conversation: primary gradient button
- Progress: thin gradient bar at top

### 5.6 Feedback Screen
- Score circle: 120px, gradient fill, score in Mono, glow shadow
- Score breakdown: 3 GlassCards (Fluency, Grammar, Vocabulary)
- XP badge: glass pill, star icon, "+XP" in warning/gold
- Grammar corrections: GlassCards (struck-through danger → success)
- High score (80+): confetti particle burst
- Done button: primary gradient

### 5.7 Profile Screen
- Avatar: gradient-bordered circle
- User info: glass card
- Stats row: 3 stat cards
- Settings: glass list items
- Sign out: ghost button in danger color

### 5.8 Leaderboard Screen
- Top 3: large GlassCards with gold/silver/bronze gradient accents
- Rest: GlassCard list with rank, name, XP
- Current user: accentCyan border glow

### 5.9 Progress/SRS Screen
- Progress chart: gradient bars
- SRS items: GlassCard list with review date, difficulty
- Mistake patterns: GlassCards with error categories

---

## 6. Animations & Micro-Interactions

### 6.1 Animated Gradient Mesh Background *(deferred to Step 10 — polish)*
- **Step 2 implementation:** Static gradient mesh using layered `RadialGradient` on a `Stack` — 3-4 color blobs at 5-8% opacity. No animation. Looks good, performs perfectly.
- **Step 10 upgrade:** Add `CustomPainter` + `AnimationController` (30s cycle) for slowly drifting blobs. Wrap in `RepaintBoundary` for performance. Only if Step 2 static version feels flat.

### 6.2 Screen Transitions
- Push: slide from right + fade (300ms, easeOut)
- Pop: slide to right + fade (250ms, easeIn)
- Dialogs: scale from 0.9 + fade (250ms, spring)

### 6.3 Card Entrance Animations
- Staggered `fadeIn` + `slideY(begin: 0.1)` with 50ms delay
- Uses `flutter_animate` (already in project)
- ~400ms per card

### 6.4 Button Micro-Interactions
- Press: `scale(0.97)` over 100ms
- Release: spring back (200ms)
- Loading: gradient spinner

### 6.5 Mic Button Animations
- Idle → Recording: scale spring (1.0 → 1.15), color transition, concentric rings
- Recording pulse: 3 expanding circles (accentCyan), 800ms cycle
- Recording → Processing: scale back, spinner
- Processing → Speaking: spinner dissolves, volume icon fades in

### 6.6 Voice Bubble Animations
- New message: slide from sender side + fade (300ms)
- Waveform bars: random height animation during playback (150ms)

### 6.7 Score/Feedback Animations
- Score circle: counter animation (0 → score, 800ms, easeOut)
- Breakdown cards: staggered fade + slide up
- XP badge: bounce spring (scale 0 → 1.1 → 1.0)
- High score: confetti using `confetti` package (already in project)

### 6.8 Navigation Animations
- NavBar: slide up + fade (300ms)
- Tab switch: indicator pill slides (200ms)
- Back: reverse of push

### 6.9 Chip/Filter Animations
- Selection: background color transition (200ms)
- Glow shadow: appear/disappear (300ms)

### 6.10 Pull-to-Refresh
- Custom refresh indicator with gradient spinner

---

## 7. Files to Modify

### 7.1 Theme Layer (core/theme/)
- `app_colors.dart` — Full rewrite: remove LightColors/DarkColors, single dark palette with new tokens
- `app_theme.dart` — Simplify to single dark ThemeData, remove light mode
- `app_text_styles.dart` — Update color defaults to new semantic tokens
- `app_dimensions.dart` — Update border radius tokens (12/16/24/9999)
- `app_shadows.dart` — New shadow system with glow shadows
- NEW: `app_gradients.dart` — Reusable gradient builders

### 7.2 Widget Layer (core/widgets/)
- `app_button.dart` — Gradient primary, glass secondary, ghost
- `app_card.dart` → Rename to `glass_card.dart` — Frosted glass with glow
- `app_chip.dart` — Glass chips with gradient selected state
- `app_nav_bar.dart` — Gradient indicator, glass panel
- `app_text_field.dart` — Glass fill, accentCyan focus glow
- `gradient_background.dart` → Rename to `mesh_gradient_background.dart` — Animated mesh
- `stat_card.dart` — Glass card with gradient icon circle
- `cefr_badge.dart` — Cyan glow badge
- `info_row.dart` — Update to glass styling
- NEW: `app_gradients.dart` — Gradient utility widgets

### 7.3 Feature Screens (features/*/screens/)
All 13 screen files + widgets need color/layout updates:
- `splash_screen.dart` *(was missing from original spec)*
- `onboarding_screen.dart` + widgets: `language_step.dart`, `cefr_step.dart`, `goal_step.dart`
- `login_screen.dart`, `signup_screen.dart`, `forgot_password_screen.dart`
- `home_screen.dart` + widgets: `streak_ring.dart`, `goal_ring.dart`, `daily_challenge_card.dart`, `scenario_cards.dart`, `guest_banner.dart`
- `scenario_selection_screen.dart` + `scenario_card.dart`, `scenario_preview_card.dart`
- `create_scenario_screen.dart` *(was missing from original spec)*
- `pre_scenario_review_screen.dart` *(was missing from original spec)*
- `conversation_screen.dart` + widgets: `mic_button.dart`, `voice_message_bubble.dart`
- `feedback_screen.dart`
- `profile_screen.dart`
- `leaderboard_screen.dart`
- `progress_screen.dart` + widgets: `level_progress.dart`, `mistake_summary.dart`, `badge_grid.dart`
- `badge_popup.dart`

### 7.4 Key Constraints
- **Zero changes to:** viewmodels, models, providers (except AppColorProvider deletion), services, business logic, routing logic
- **Only changes:** theme files, widget files, screen UI files
- **Remove:** all legacy color references (`AppColors.primaryPink`, `AppColors.textDark`, `AppColors.textMuted`, `AppColors.bgTop`, `AppColors.bgBottom`, `AppColors.accentGold`, `AppColors.accentCoral`, `AppColors.shadowPink`, `AppColors.primaryPinkDark`, `AppColors.primaryPinkLight`)
- **Delete:** `AppColorProvider` class (no longer needed — dark-only, no dynamic switching)
- **Delete:** `ThemeModeProvider`, `SharedPreferences` dark mode persistence (Phase 6 infrastructure, abandoned)
- **Rename:** `AppRadius.xl` → `AppRadius.lg`, `AppRadius.full` → `AppRadius.pill`

---

## 8. Implementation Order

0. **Legacy color migration** — Replace all 333 legacy color references across 30 files with new semantic tokens. Grep each legacy token, replace, verify `flutter analyze` after each batch. This is the largest single step and blocks everything else.
1. **Theme foundation** — app_colors.dart (new dark palette, delete LightColors/DarkColors/AppColorProvider), app_gradients.dart (new), app_theme.dart (single dark ThemeData), app_text_styles.dart (new color defaults), app_dimensions.dart (radius shift: sm=12, md=16, lg=24, pill=9999), app_shadows.dart (add glowBlue, glowCyan)
2. **Core widgets** — GlassCard (replaces AppCard), AppButton (3 variants), GlassChip (replaces AppChip), GradientNavBar (replaces AppNavBar), MeshGradientBackground — **static mesh only** (replaces GradientBackground), AppTextField, StatCard, CefrBadge
3. **Auth screens** — Login, Signup, Forgot Password (simplest screens, good for validating theme)
4. **Onboarding** — 3-step flow + splash screen
5. **Home dashboard** — Most complex screen, all home widgets
6. **Scenario selection + Create/Pre-Review** — Grid, chips, search, cards, create scenario form, pre-scenario review
7. **Conversation** — Mic button, voice bubbles, top bar
8. **Feedback** — Score circle, breakdown, corrections
9. **Remaining screens** — Profile, Leaderboard, Progress, Badge popup
10. **Polish** — Animated mesh gradient (if static feels flat), animation tuning, edge cases, dark-mode consistency audit
