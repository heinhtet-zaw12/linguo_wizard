# Phase 06 — Context

## What Exists Today

### Theme System (`lib/core/theme/app_theme.dart`)
- `AppColors` — static color constants (pink gradient palette)
- `AppTheme` — single `light` ThemeData using `ColorScheme.fromSeed`
- No dark mode, no shared text styles, no design tokens

### Typography (ad-hoc, everywhere)
- `GoogleFonts.fredoka()` — headings (inline in every widget)
- `GoogleFonts.quicksand()` — body text (inline in every widget)
- No centralized TextTheme or TextStyle tokens

### Components (no shared library)
- `_ClayField` — duplicated in `login_screen.dart` and `signup_screen.dart`
- `_StatCard` — duplicated in `profile_screen.dart` and `progress_screen.dart`
- `_CefrBadge` — duplicated in `scenario_card.dart` and `scenario_preview_card.dart`
- `_InfoRow` — duplicated in `scenario_preview_card.dart` and `profile_screen.dart`
- Gradient background — manually constructed in every screen
- Button style — manually constructed in every screen

### Dependencies (UI-related)
- `google_fonts: ^6.2.1`
- `confetti: ^0.8.0`
- `go_router: ^17.3.0`
- No animation package, no icon package, no design system package

## What Changes in Phase 6

1. **Design tokens** — centralized colors, typography, spacing, shadows, radii
2. **Dark mode** — full light/dark theme with system preference detection
3. **Shared component library** — `AppButton`, `AppTextField`, `AppCard`, `AppChip`, `AppNavBar`
4. **New fonts** — Plus Jakarta Sans + Inter + JetBrains Mono replacing Fredoka + Quicksand
5. **All 14 screens** — redesigned with new visual language
6. **Micro-interactions** — via `flutter_animate` package
7. **Zero breaking changes** — all logic, state, navigation, services untouched

## Constraints
- All existing ViewModel logic remains unchanged
- All service layer code remains unchanged
- All model classes remain unchanged
- GoRouter configuration remains unchanged (only visual styling changes)
- Riverpod providers remain unchanged
- Firebase integration remains unchanged
- STT/TTS/AI conversation pipeline remains unchanged

## Risk Areas
- **Font migration** — changing fonts affects every screen; must ensure all text renders correctly
- **BackdropFilter performance** — glassmorphism with blur can be expensive on low-end devices; need to test on older phones
- **Animation performance** — micro-animations must respect reduced-motion settings
- **Dark mode coverage** — every widget must work in both modes; easy to miss edge cases
