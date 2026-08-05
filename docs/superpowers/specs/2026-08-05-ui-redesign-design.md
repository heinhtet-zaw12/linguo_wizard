# UI Redesign Design Spec — Futuristic Dark Theme

**Date:** 2026-08-05
**Status:** Approved
**Scope:** Full UI redesign — all screens, all widgets, all theme tokens
**Constraint:** Zero business logic changes. Only design-layer files.

---

## 1. Design Direction

**Mood:** Futuristic & bold
**Palette:** Blue-violet electric — deep navy/charcoal base, electric blue + violet gradients, cyan highlights
**Glassmorphism:** Frosted glass cards with backdrop blur (Glassmorphism 2.0)
**Animations:** Maximum micro-interactions — spring physics, animated gradient mesh, particle effects
**Background:** Animated gradient mesh (always visible, slowly shifting)
**Mode:** Dark-only (no light mode)

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
- Animated mesh gradient using `CustomPainter` with `AnimationController`
- 30-second full cycle
- 3-4 color blobs (accentStart, accentMid, accentCyan at 5-8% opacity) that slowly drift
- Creates living, breathing backdrop
- `RepaintBoundary` for performance

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

## 5. Screen Layouts

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

### 6.1 Animated Gradient Mesh Background
- `CustomPainter` + `AnimationController` (30s cycle)
- 3-4 color blobs at 5-8% opacity, slowly drifting
- `RepaintBoundary` for performance

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
All 10 screens need color/layout updates:
- `onboarding_screen.dart` + widgets: `language_step.dart`, `cefr_step.dart`, `goal_step.dart`
- `login_screen.dart`, `signup_screen.dart`, `forgot_password_screen.dart`
- `home_screen.dart` + widgets: `streak_ring.dart`, `goal_ring.dart`, `daily_challenge_card.dart`, `scenario_cards.dart`, `guest_banner.dart`
- `scenario_selection_screen.dart` + `scenario_card.dart`
- `conversation_screen.dart` + widgets: `mic_button.dart`, `voice_message_bubble.dart`
- `feedback_screen.dart`
- `profile_screen.dart`
- `leaderboard_screen.dart`
- `progress_screen.dart` + widgets
- `badge_popup.dart`

### 7.4 Key Constraints
- **Zero changes to:** viewmodels, models, providers, services, business logic, routing logic
- **Only changes:** theme files, widget files, screen UI files
- **Remove:** all legacy color references (`AppColors.primaryPink`, `AppColors.textDark`, `AppColors.textMuted`, `AppColors.bgTop`, `AppColors.bgBottom`, `AppColors.accentGold`, `AppColors.accentCoral`, `AppColors.shadowPink`, `AppColors.primaryPinkDark`, `AppColors.primaryPinkLight`)

---

## 8. Implementation Order

1. **Theme foundation** — app_colors.dart, app_gradients.dart, app_theme.dart, app_text_styles.dart, app_dimensions.dart, app_shadows.dart
2. **Core widgets** — GlassCard, AppButton, GlassChip, GradientNavBar, MeshGradientBackground, AppTextField, StatCard, CefrBadge
3. **Auth screens** — Login, Signup, Forgot Password (simplest screens, good for validating theme)
4. **Onboarding** — 3-step flow
5. **Home dashboard** — Most complex screen, all home widgets
6. **Scenario selection** — Grid, chips, search, cards
7. **Conversation** — Mic button, voice bubbles, top bar
8. **Feedback** — Score circle, breakdown, corrections
9. **Remaining screens** — Profile, Leaderboard, Progress, Badge popup
10. **Polish** — Animation tuning, edge cases, dark mode consistency audit
