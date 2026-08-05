# Phase 06 — UI/UX Overhaul: Design Specification

**Designer:** Claude (acting as Senior UI/UX Designer)
**Date:** 2026-07-30
**App:** Linguo Wizard — Conversational Language Learning

---

## 1. Design Philosophy

### From Claymorphism → "Soft Glass" (2026 Modern)

The current "3D Claymorphism" theme served the MVP well — it's playful and approachable. But it lacks depth in hierarchy, has no dark mode, and the absence of a design system means every screen reinvents the same patterns.

**New Direction: "Soft Glass"** — A modern, premium visual language that blends:
- **Refined glassmorphism** — frosted glass cards with subtle backdrop blur, not heavy opacity
- **Soft gradient mesh backgrounds** — multi-stop gradients that feel alive, not flat pink-to-pink
- **Micro-interactions** — subtle scale/fade/shimmer on tap, scroll, and state changes
- **Fluid typography** — clear hierarchy with proper text scale, not ad-hoc font calls
- **Breathing whitespace** — generous padding, clear visual rhythm

**Why this fits Linguo Wizard:**
- Language learning apps need to feel **calm and focused**, not overwhelming
- The target audience (A1–C1 learners) spans all ages — the design must be **sophisticated yet warm**
- Glassmorphism is **platform-native feeling** (matches iOS/Android design language)
- The pink warmth is preserved but elevated — not abandoned

---

## 2. Color System

### Light Mode (Default)

| Token | Hex | Usage |
|-------|-----|-------|
| `surfacePrimary` | `#FFFFFF` | Cards, modals, bottom sheets |
| `surfaceSecondary` | `#F8F5F2` | Secondary surfaces, input backgrounds |
| `surfaceGlass` | `rgba(255,255,255,0.72)` | Glass cards with backdrop blur |
| `backgroundStart` | `#FFF5F7` | Gradient top — barely-there pink |
| `backgroundMid` | `#FDE8EE` | Gradient middle |
| `backgroundEnd` | `#F9D4DE` | Gradient bottom — soft rose |
| `accentPrimary` | `#E8728A` | Primary actions, active states (warm rose) |
| `accentPrimaryLight` | `#F5A3B5` | Hover states, light accents |
| `accentPrimaryDark` | `#C95670` | Pressed states |
| `accentSecondary` | `#F5B742` | XP, streaks, achievements (warm gold) |
| `accentTertiary` | `#7ECFC0` | Success states, completed badges (soft teal) |
| `accentDanger` | `#E86B6B` | Errors, destructive actions |
| `textPrimary` | `#2D1F2B` | Headings, primary text (near-black with warm undertone) |
| `textSecondary` | `#6B5A66` | Body text, descriptions |
| `textTertiary` | `#A89BA3` | Captions, placeholders, disabled |
| `textOnAccent` | `#FFFFFF` | Text on colored backgrounds |
| `borderSubtle` | `rgba(0,0,0,0.06)` | Card borders, dividers |
| `borderFocus` | `#E8728A` | Focused input borders |
| `shadowColor` | `rgba(200,80,120,0.08)` | Card shadows — barely visible pink tint |

### Dark Mode (New)

| Token | Hex | Usage |
|-------|-----|-------|
| `surfacePrimary` | `#1E1A20` | Cards, modals |
| `surfaceSecondary` | `#2A2530` | Secondary surfaces |
| `surfaceGlass` | `rgba(40,35,48,0.80)` | Glass cards with backdrop blur |
| `backgroundStart` | `#141018` | Gradient top |
| `backgroundMid` | `#1A1520` | Gradient middle |
| `backgroundEnd` | `#201A28` | Gradient bottom |
| `accentPrimary` | `#F5A3B5` | Primary actions (lighter for dark bg) |
| `accentPrimaryLight` | `#FBBCC9` | Hover states |
| `accentPrimaryDark` | `#E8728A` | Pressed states |
| `textPrimary` | `#F2ECF0` | Headings |
| `textSecondary` | `#B8A8B2` | Body text |
| `textTertiary` | `#7A6B75` | Captions |
| `borderSubtle` | `rgba(255,255,255,0.08)` | Card borders |
| `shadowColor` | `rgba(0,0,0,0.30)` | Card shadows |

---

## 3. Typography System

### Font Families

| Role | Font | Weight | Rationale |
|------|------|--------|-----------|
| Display / Hero | **Plus Jakarta Sans** | 700 (Bold) | Modern geometric sans, premium feel |
| Headings (H1–H3) | **Plus Jakarta Sans** | 600 (SemiBold) | Clear hierarchy, pairs well with body |
| Body | **Inter** | 400 (Regular), 500 (Medium) | Gold standard for UI readability |
| Labels / Captions | **Inter** | 500 (Medium), 600 (SemiBold) | Crisp at small sizes |
| Monospace (scores) | **JetBrains Mono** | 500 | For numbers, XP counters, timers |

**Why change from Fredoka/Quicksand:**
- Fredoka is too rounded/playful for a premium feel — it works for kids' apps but limits the audience
- Quicksand is legible but lacks the crispness of Inter at small sizes
- Plus Jakarta Sans + Inter is the 2025–2026 standard for modern product UIs (Linear, Vercel, Raycast all use similar pairings)

### Type Scale

| Token | Size | Line Height | Weight | Usage |
|-------|------|-------------|--------|-------|
| `displayLarge` | 32px | 40px | 700 | Hero numbers (XP, streak count) |
| `displayMedium` | 24px | 32px | 700 | Section headers on cards |
| `headingLarge` | 20px | 28px | 600 | Screen titles |
| `headingMedium` | 17px | 24px | 600 | Card titles, modal headers |
| `headingSmall` | 15px | 22px | 600 | Subsection headers |
| `bodyLarge` | 16px | 24px | 400 | Primary body text |
| `bodyMedium` | 14px | 20px | 400 | Secondary text, descriptions |
| `bodySmall` | 13px | 18px | 400 | Captions, helper text |
| `labelLarge` | 14px | 20px | 500 | Button text |
| `labelMedium` | 12px | 16px | 500 | Tab labels, chip text |
| `labelSmall` | 11px | 14px | 600 | Badges, overlines |

---

## 4. Spacing & Layout System

### Spacing Scale (4px base unit)

| Token | Value | Usage |
|-------|-------|-------|
| `space-1` | 4px | Tight gaps (icon to text) |
| `space-2` | 8px | Small gaps (chip padding) |
| `space-3` | 12px | Compact sections |
| `space-4` | 16px | Default padding, card inner |
| `space-5` | 20px | Medium gaps |
| `space-6` | 24px | Section spacing |
| `space-8` | 32px | Large gaps |
| `space-10` | 40px | Screen horizontal padding |
| `space-12` | 48px | Major section breaks |
| `space-16` | 64px | Hero spacing |

### Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radius-sm` | 8px | Chips, badges, small buttons |
| `radius-md` | 12px | Cards, inputs, medium elements |
| `radius-lg` | 16px | Modals, bottom sheets |
| `radius-xl` | 24px | Large cards, hero elements |
| `radius-full` | 9999px | Avatars, circular elements |

### Shadows (Elevation System)

| Level | Light Mode | Dark Mode | Usage |
|-------|-----------|-----------|-------|
| `elevation-1` | `0 1px 3px rgba(200,80,120,0.06)` | `0 1px 3px rgba(0,0,0,0.20)` | Resting cards |
| `elevation-2` | `0 4px 12px rgba(200,80,120,0.08)` | `0 4px 12px rgba(0,0,0,0.25)` | Hovered/focused cards |
| `elevation-3` | `0 8px 24px rgba(200,80,120,0.10)` | `0 8px 24px rgba(0,0,0,0.30)` | Modals, dropdowns |
| `elevation-4` | `0 16px 48px rgba(200,80,120,0.12)` | `0 16px 48px rgba(0,0,0,0.35)` | Floating elements |

---

## 5. Component Redesign

### 5.1 Navigation Bar (Bottom)

**Current:** Basic `BottomNavigationBar` with pink active color.
**New:** Custom glass-style bottom nav with:
- Frosted glass background (`BackdropFilter` + semi-transparent fill)
- Active indicator: pill-shaped highlight behind the icon (iOS-style)
- Smooth icon scale animation on tab switch (1.0 → 1.15 → 1.0)
- Labels only visible on active tab (cleaner look)
- Safe area padding handled properly

### 5.2 Cards (Scenario, Stat, Badge)

**Current:** White 70% opacity, `borderRadius: 16`, pink box shadow, manual gradient background.
**New:**
- `surfaceGlass` background with `BackdropFilter(blur: 20)`
- Subtle `border: 1px solid borderSubtle`
- `elevation-1` shadow, transitioning to `elevation-2` on hover/press
- `radius-md` (12px) — tighter, more modern than 16px
- Inner padding: `space-4` (16px) consistent
- Tap feedback: subtle scale-down to 0.98 with 150ms ease-out

### 5.3 Buttons

**Primary Button:**
- Background: `accentPrimary` gradient (subtle top-to-bottom, not flat)
- Text: `textOnAccent`, `labelLarge` (14px/500)
- Height: 52px, `radius-full` (pill shape)
- Shadow: `elevation-1` with accent tint
- Tap: scale 0.97 + darken background 8% (150ms)
- Loading state: centered `CircularProgressIndicator` (white, 20px)

**Secondary Button:**
- Background: transparent
- Border: 1.5px `borderSubtle`
- Text: `textPrimary`
- Same height/radius as primary
- Tap: background flashes `surfaceSecondary` briefly

**Ghost Button (Text Button):**
- No background, no border
- Text: `accentPrimary`, underlined on hover
- Used for: "Skip", "Cancel", secondary actions

### 5.4 Input Fields

**Current:** `_ClayField` — claymorphism styled, duplicated in login/signup.
**New:**
- `surfaceSecondary` background
- `border: 1.5px solid borderSubtle`, transitioning to `borderFocus` on focus
- `radius-md` (12px)
- Label text above field (not floating label), `labelMedium` style
- Error state: border turns `accentDanger`, helper text appears below
- Height: 48px, padding: `space-3` horizontal
- Prefix/suffix icons: 20px, `textTertiary` color

### 5.5 Chips (CEFR, Categories)

**Current:** Basic `ChoiceChip` with pink background.
**New:**
- Selected: `accentPrimary` background, `textOnAccent` text
- Unselected: `surfaceSecondary` background, `textSecondary` text
- `radius-sm` (8px), height: 36px
- Padding: `space-2` horizontal, `space-1` vertical
- Tap: scale 0.95 → 1.0 (100ms spring animation)
- Single-line, horizontal scroll with fade edges

### 5.6 Mic Button (Conversation)

**Current:** Animated mic button with idle/recording/processing/speaking states.
**New:**
- Idle: `surfacePrimary` circle, mic icon in `accentPrimary`, `elevation-1`
- Recording: pulsing ring animation (3 concentric rings, `accentPrimary` at decreasing opacity), background shifts to `accentPrimary`, icon white
- Processing: spinning loader ring around the button
- Speaking: equalizer bars animation inside the button
- Size: 72px diameter (slightly larger for better touch target)
- Haptic feedback on state transitions

### 5.7 Voice Message Bubbles

**Current:** Pink (user) / White (AI) bubbles with transcript.
**New:**
- User: `accentPrimary` gradient background, `textOnAccent`, `radius-lg` with bottom-right `radius-sm` (tail effect)
- AI: `surfacePrimary` with `borderSubtle`, `textPrimary`, `radius-lg` with bottom-left `radius-sm`
- Play/Pause button: circular, 36px, embedded in bubble
- Transcript: collapsible, `bodySmall` text, `textSecondary`
- Subtle entrance animation: slide up + fade in (300ms)
- Message spacing: `space-3` between bubbles

### 5.8 Score Circle (Feedback)

**Current:** Basic circular progress with score text.
**New:**
- Animated fill on screen entry (0 → final value, 800ms ease-out)
- Gradient stroke (accentPrimary → accentSecondary)
- Center: score number in `displayLarge`, label in `labelMedium`
- Subtle glow effect behind the circle
- Breakdown cards below: glass style, horizontal row

### 5.9 Daily Challenge Card (Home)

**Current:** Basic card with countdown.
**New:**
- Full-width glass card with gradient border (accentSecondary → accentPrimary)
- Countdown timer in `JetBrains Mono`, `displayMedium`
- "2x XP" badge: animated shimmer effect
- Tap: ripple effect + scale 0.98
- Subtle particle animation on the card (optional, performance-dependent)

### 5.10 Onboarding Steps

**Current:** Card-based selection with claymorphism.
**New:**
- Step indicator: horizontal dots (not text "Step 1 of 3"), active dot is `accentPrimary` pill
- Selection cards: glass style, checkmark animation on select (scale + color transition)
- "Continue" button: fixed at bottom, disabled until selection made
- Page transition: horizontal slide (left/right based on direction)
- Progress bar: thin (3px) at top, `accentPrimary` fill

---

## 6. Screen-by-Screen Redesign Notes

### Splash Screen
- Keep existing animation, update background to new gradient
- Logo: add subtle glow effect
- Loading indicator: new style (thin ring, not dots)

### Login / Signup / Forgot Password
- Extract `_ClayField` → shared `AppTextField` component
- Card: glass style, centered, max-width 400px
- Social login buttons: Google icon in circle, full-width secondary button style
- Divider: thin line with "or" text (current pattern, just styled consistently)

### Home Screen
- Greeting text: `headingLarge`, warm and personalized
- Stats row (streak, XP, level): glass cards in a horizontal scrollable row
- Daily Challenge: hero card at top (see 5.9)
- Scenario cards: 2-column grid, glass style (see 5.2)
- Guest banner: subtle info style (not warning), glass card with icon

### Scenario Selection
- Category tabs: new chip style (see 5.5), horizontal scroll with fade edges
- CEFR chips: same style, second row
- Search: glass-style input that expands from icon
- Grid: same 2-column, glass cards
- Empty states: illustration + text + action button

### Conversation Screen
- Background: new gradient (subtle, not flat pink)
- Top bar: glass style, scenario title + progress indicator
- Messages: new bubble style (see 5.7)
- Mic button: new design (see 5.6)
- End button: ghost style, top-right

### Feedback Screen
- Score circle: animated gradient (see 5.8)
- Breakdown: horizontal glass cards (fluency, grammar, vocabulary)
- Grammar corrections: expandable list, clean typography
- XP badge: gold accent with shimmer
- "Done" button: primary style, fixed at bottom

### Progress Screen
- Stats cards: glass style, 2-column grid
- Level progress bar: animated fill
- Badge grid: glass cards with unlock animation
- Mistake summary: clean data visualization (bar chart style)

### Leaderboard
- Podium: top 3 with glass cards, gold/silver/bronze accents
- List: numbered rows, glass style, current user highlighted
- Tab: "All Time" / "This Week" (glass segmented control)

### Profile
- Avatar: circular with gradient border
- Stats row: glass cards
- Settings list: clean rows with chevron icons
- Sign out: ghost/danger button

### Pre-Scenario Review
- Scenario info: glass card, large
- Tips: numbered list with icons
- "Start" button: primary, full-width, fixed at bottom

### Create Scenario
- Form: new input style (see 5.4)
- Preview: glass card with scenario content
- Category/CEFR selectors: new chip style

---

## 7. Animation & Micro-Interaction Catalog

| Interaction | Animation | Duration | Curve |
|-------------|-----------|----------|-------|
| Card tap | Scale 1.0 → 0.97 | 150ms | easeOut |
| Card release | Scale 0.97 → 1.0 | 200ms | easeOutBack |
| Button tap | Scale 1.0 → 0.95 | 100ms | easeOut |
| Screen transition | Slide + fade | 300ms | easeInOut |
| Tab switch icon | Scale 1.0 → 1.15 → 1.0 | 250ms | easeOutBack |
| Chip select | Scale 0.95 → 1.0 | 100ms | spring |
| Score circle fill | Stroke animation 0% → 100% | 800ms | easeOut |
| Mic pulse rings | Opacity fade + scale | 1200ms loop | linear |
| Badge unlock | Scale 0 → 1.2 → 1.0 + rotate | 500ms | spring |
| List item entrance | Fade in + slide up 20px | 200ms stagger | easeOut |
| Pull to refresh | Standard Material | — | — |
| Bottom nav indicator | Horizontal slide | 250ms | easeInOut |
| Gradient border shimmer | TranslateX -100% → 100% | 2000ms loop | linear |

---

## 8. Accessibility Considerations

- **Contrast:** All text meets WCAG AA (4.5:1 for body, 3:1 for large text)
- **Touch targets:** Minimum 44×44px for all interactive elements
- **Reduced motion:** Respect `MediaQuery.disableAnimations` — disable all micro-animations, keep structural transitions
- **Screen reader:** All interactive elements have `semanticsLabel` / `semanticsHint`
- **Font scaling:** Type scale respects `MediaQuery.textScaleFactor` (no hardcoded pixel sizes that break at 200%)
- **Color independence:** Never rely on color alone to convey state (use icons + text alongside color)

---

## 9. Implementation Strategy

### Phase 6 Execution Waves

**Wave 1: Design System Foundation** (no visible changes yet)
- Create `lib/core/theme/` with design tokens (colors, typography, spacing, shadows)
- Create `lib/core/theme/app_text_styles.dart` — centralized text styles
- Create `lib/core/theme/app_dimensions.dart` — spacing, radius, sizing constants
- Create `lib/core/theme/app_shadows.dart` — elevation system
- Refactor `AppColors` → new color tokens (backward-compatible aliases)
- Add dark mode support to `AppTheme`
- Add `flutter_animate` package for micro-interactions

**Wave 2: Shared Component Library** (extract + upgrade)
- Create `lib/core/widgets/` — shared component library
- Extract and upgrade: `AppButton`, `AppTextField`, `AppCard`, `AppChip`, `AppNavBar`
- Extract duplicated widgets: `CefrBadge`, `StatCard`, `InfoRow`
- Update `pubspec.yaml` with Plus Jakarta Sans, Inter, JetBrains Mono

**Wave 3: Screen Redesign** (feature by feature)
- Auth screens (Login, Signup, Forgot Password) — glass cards, new inputs
- Home screen — glass cards, stats row, daily challenge upgrade
- Scenario selection — chips, grid, search, empty states
- Conversation — bubbles, mic button, top bar
- Feedback — animated score, breakdown cards
- Navigation — glass bottom nav
- Remaining screens (Progress, Leaderboard, Profile, Onboarding, Pre-Scenario, Create Scenario)

**Wave 4: Dark Mode + Polish**
- Wire dark mode toggle (Profile screen)
- Theme persistence (SharedPreferences)
- Final QA pass across all screens
- Animation performance audit

---

*Designed by Claude as Senior UI/UX Designer — 2026-07-30*
