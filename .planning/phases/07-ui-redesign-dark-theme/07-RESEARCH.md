# Phase 7: UI Redesign - Futuristic Dark Theme - Research

**Researched:** 2026-08-05
**Domain:** Flutter UI theming, glassmorphism, gradient mesh, micro-interactions
**Confidence:** HIGH

## Summary

Phase 7 is a pure design-layer refactor: 333 legacy color references across 30 files must be migrated, the dual light/dark theme system (AppColorProvider, ThemeModeProvider, LightColors/DarkColors) must be deleted and replaced with a single flat dark palette, 9 core widgets must be restyled to glassmorphism 2.0, and 13 screens must receive layout/animation updates. Zero business logic changes. The existing `flutter_animate` (4.5.0) and `confetti` (0.8.0) packages already in pubspec.yaml cover all animation needs -- no new dependencies required. The primary technical risk is the BackdropFilter performance cost of glassmorphism at scale across all screens simultaneously.

**Primary recommendation:** Execute strictly in the locked implementation order (legacy migration first, theme foundation second, widgets third, screens last) -- each step blocks the next and attempting screen updates before theme tokens are finalized creates cascading rework.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- D-01: Dark-only theme. Removes Phase 6 light/dark toggle, ThemeModeProvider, AppColorProvider. Single flat dark palette.
- D-02: Blue-violet electric palette with exact hex values specified in design spec.
- D-03: Glassmorphism 2.0 components. All cards/chips/nav bar use frosted glass (BackdropFilter blur: 20, glass opacity 0.08, border opacity 0.12).
- D-04: Keep current fonts (Plus Jakarta Sans, Inter, JetBrains Mono).
- D-05: Static mesh gradient first, animated deferred to Step 10 polish.
- D-06: Implementation order from spec section 8 (legacy migration -> theme foundation -> core widgets -> auth -> onboarding -> home -> scenario -> conversation -> feedback -> remaining -> polish).
- D-07: Zero business logic changes. Only theme files, widget files, screen UI files.
- D-08: AppRadius token shift (sm=12, md=16, lg=24, xl removed, full renamed to pill=9999).
- D-09: AppColorProvider + ThemeModeProvider deletion.
- D-10: Glow shadows new pattern (glowBlue, glowCyan).
- D-11: New AppGradients utility.
- D-12: Screen transition specs (push: slide right+fade 300ms easeOut, pop: slide right+fade 250ms, dialogs: scale 0.9+fade 250ms spring, card entrance: fadeIn+slideY 400ms staggered 50ms).
- D-13: AppButton 3 variants (Primary: gradient+glow 52px, Secondary: glass+accentCyan border, Ghost: text accentCyan, Press: scale 0.97 100ms spring 200ms).

### Claude's Discretion
- Exact file naming for renamed widgets (app_card.dart -> glass_card.dart vs keeping name)
- Whether to use flutter_animate or manual AnimationController for card entrance animations
- Whether MeshGradientBackground should be a separate widget or inline Stack pattern
- Performance tuning: glass blur sigma, animation durations
- Confetti implementation details for high scores

### Deferred Ideas (OUT OF SCOPE)
- Animated gradient mesh (Step 10 polish -- static mesh ships first)
- Myanmar (Burmese) language UI
- Dynamic transcript translation
- Any business logic or routing changes
</user_constraints>

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Dark theme tokens (colors, gradients, shadows) | Theme layer (core/theme/) | -- | Centralized token system all widgets consume |
| Glassmorphism components (GlassCard, GlassChip) | Widget layer (core/widgets/) | Theme layer | Widgets read tokens, apply BackdropFilter |
| Screen layouts (13 screens) | View layer (features/*/screens/) | Widget layer | Screens compose widgets, read theme tokens |
| Gradient mesh background | Widget layer (core/widgets/) | Theme layer | Standalone background widget, reads gradient tokens |
| Micro-interactions (spring, stagger) | Widget layer + View layer | -- | Widgets own press animations; screen-level stagger in screens |
| Light/dark toggle removal | Theme layer + Providers | View layer (main.dart, profile) | Delete ThemeModeProvider, AppColorProvider, update MaterialApp |
| Legacy color migration (333 refs) | View layer (30 files) | -- | Find-replace across all screen/widget files |

## Standard Stack

### Core (no new packages needed)
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| flutter_animate | 4.5.0 (in pubspec) | Staggered card entrance animations, slide+fade transitions | Already in project, battle-tested, declarative API |
| confetti | 0.8.0 (in pubspec) | High-score particle burst on feedback screen | Already in project, minimal config |
| google_fonts | 6.2.1 (in pubspec) | Plus Jakarta Sans, Inter, JetBrains Mono | Already in project |
| dart:ui | (SDK built-in) | ImageFilter.blur for BackdropFilter glassmorphism | No package needed for frosted glass |

### Supporting (already in project)
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| flutter_riverpod | 2.6.0 | State management (deletion of themeModeProvider) | Provider deletion, NOT new providers |
| shared_preferences | 2.3.0 | Remove dark mode persistence key | Delete _kThemeKey read/write |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| BackdropFilter (dart:ui) | ClipRRect + opacity only | Loses true frosted glass -- spec requires blur |
| flutter_animate for stagger | manual AnimationController | flutter_animate is already installed and simpler for declarative stagger |
| Static RadialGradient mesh | CustomPainter animated mesh | Spec explicitly defers animated to Step 10 |

**Installation:** None -- all required packages are already in pubspec.yaml.

## Package Legitimacy Audit

No new packages are being installed in this phase. All animation and visual packages (flutter_animate, confetti, google_fonts) are already verified in the existing pubspec.yaml.

## Architecture Patterns

### Pattern 1: Static Mesh Gradient Background (D-05 locked)
**What:** Stack of 3-4 Positioned containers with RadialGradient blobs at 5-8% opacity
**When to use:** Every screen that uses MeshGradientBackground
**Example:**
```dart
// Static mesh: Stack of Positioned RadialGradient containers
Stack(
  children: [
    Container(color: AppColors.surfaceBase), // deepest base
    Positioned(
      top: -100, left: -50,
      child: Container(
        width: 300, height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [AppColors.accentStart.withValues(alpha: 0.08), Colors.transparent],
          ),
        ),
      ),
    ),
    // 2-3 more blobs at different positions...
    child, // Screen content goes on top
  ],
)
```

### Pattern 2: GlassCard with BackdropFilter
**What:** ClipRRect + BackdropFilter(blur: 20) + Container with glass opacity
**When to use:** All cards, chips, nav bar, modals
**Example:**
```dart
ClipRRect(
  borderRadius: AppRadius.md,
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    child: Container(
      padding: AppSpacing.all4,
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass, // surface1 at 0.08 opacity
        borderRadius: AppRadius.md,
        border: Border.all(
          color: AppColors.borderSubtle, // borderGlow for active states
          width: 0.5,
        ),
        boxShadow: AppShadows.elevation1,
      ),
      child: child,
    ),
  ),
)
```

### Pattern 3: flutter_animate Staggered Card Entrance
**What:** Each card in a list gets fadeIn + slideY with incremental delay
**When to use:** Home dashboard cards, scenario grid, feedback breakdown
**Example:**
```dart
// In a ListView.builder or Column
card
  .animate()
  .fadeIn(duration: 400.ms, delay: (index * 50).ms)
  .slideY(begin: 0.1, duration: 400.ms, delay: (index * 50).ms, curve: Curves.easeOut);
```

### Pattern 4: Spring Scale Micro-Interaction (Button Press)
**What:** GestureDetector onPanDown -> scale 0.97, onPanUp -> spring back to 1.0
**When to use:** AppButton press, mic button, interactive cards
**Example:**
```dart
GestureDetector(
  onTapDown: (_) => setState(() => _scale = 0.97),
  onTapUp: (_) => setState(() => _scale = 1.0),
  onTapCancel: () => setState(() => _scale = 1.0),
  child: AnimatedScale(
    scale: _scale,
    duration: const Duration(milliseconds: 100),
    curve: Curves.easeOut,
    child: /* button content */,
  ),
)
```

### Anti-Patterns to Avoid
- **Using AppColorProvider.current after deletion:** All `AppColors.xxx` calls that delegate to `AppColorProvider.current` will break. Replace with direct static constants from the new flat palette.
- **BackdropFilter without ClipRRect:** Blur bleeds outside card boundaries without clip. Always wrap in ClipRRect first.
- **Hardcoded colors in screens:** After migration, screens should ONLY reference `AppColors.xxx` semantic tokens. Never use `Color(0xFF...)` directly in screen files.
- **Updating screens before theme foundation:** Screen color changes will be wrong if done before the new palette is in app_colors.dart. Follow the locked implementation order.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Frosted glass effect | Container with opacity only | BackdropFilter + ClipRRect (dart:ui) | True glassmorphism requires blur of content behind |
| Staggered list entrance | Manual Timer-based delays | flutter_animate `.animate().fadeIn(delay:)` | Already installed, handles disposal, performance-optimized |
| Gradient fills | LinearGradient inline everywhere | AppGradients utility class (D-11) | Single source of truth for gradient definitions |
| Spring animations | TweenAnimationBuilder | AnimatedScale + Curves.easeOutBack | Simpler, already used in project |
| Confetti burst | Custom particle system | confetti package (already in pubspec) | Tested, performant, minimal config |

## Common Pitfalls

### Pitfall 1: BackdropFilter Performance on Low-End Devices
**What goes wrong:** Multiple nested BackdropFilters cause frame drops on older Android devices
**Why it happens:** Each BackdropFilter triggers a saveLayer which is expensive on GPU
**How to avoid:** Keep blur sigma at 20 (spec value). Avoid nesting BackdropFilter widgets. Use RepaintBoundary around mesh gradient background. Profile on a low-end device before shipping.
**Warning signs:** Jank in scrolling lists of glass cards, especially on Android < API 28

### Pitfall 2: AppRadius.xl and AppRadius.full References in Core Widgets
**What goes wrong:** After renaming AppRadius tokens, 3 core widget files (app_button.dart, app_chip.dart, app_nav_bar.dart) will have broken references
**Why it happens:** These 3 files use AppRadius.xl (6 occurrences total) and AppRadius.full (used in chips/nav)
**How to avoid:** Update AppRadius token file first, then grep for `AppRadius.xl` and `AppRadius.full` across the 3 core widget files and replace with AppRadius.lg and AppRadius.pill respectively

### Pitfall 3: ThemeModeProvider Deletion Causes Compilation Errors
**What goes wrong:** Removing ThemeModeProvider breaks main.dart (ref.watch(themeModeProvider)), profile_screen.dart (theme toggle), and theme_provider.dart itself
**Why it happens:** 3 files reference ThemeModeProvider -- main.dart line 27, profile_screen.dart lines 225/279, theme_provider.dart definition
**How to avoid:** Delete theme_provider.dart entirely. In main.dart: remove themeModeProvider watch, remove AppTheme.updateColorProvider call, hardcode themeMode: ThemeMode.dark. In profile_screen.dart: remove the dark mode toggle UI section.

### Pitfall 4: AppColorProvider Deletion Leaves Dead Code
**What goes wrong:** After deleting AppColorProvider, the static getters in AppColors that delegate to `AppColorProvider.current.xxx` become broken
**Why it happens:** AppColors class (lines 156-178 in app_colors.dart) delegates every getter to AppColorProvider.current
**How to avoid:** Replace the entire app_colors.dart content with a single flat const palette class. No delegation needed for dark-only.

### Pitfall 5: Legacy Color References in Widget Import Chains
**What goes wrong:** Some widgets import app_colors.dart and use legacy const fields (primaryPink, bgTop, etc.) -- these are frozen at light-mode values and will look wrong on dark backgrounds
**Why it happens:** 333 references across 30 files use the old legacy const fields
**How to avoid:** The Step 0 legacy migration is mandatory. Grep each legacy token name, batch-replace with semantic equivalent per the mapping table in design spec section 0, verify flutter analyze after each batch.

### Pitfall 6: GradientBackground Replacement Breaks All Screens
**What goes wrong:** Renaming GradientBackground to MeshGradientBackground breaks every screen that imports it
**Why it happens:** All 13 screens use GradientBackground as their root scaffold decoration
**How to avoid:** Either keep the class name and change implementation internally, or do a project-wide find-replace for the import and usage in one pass.

## Code Examples

### Static Mesh Gradient Background
```dart
// MeshGradientBackground - replaces GradientBackground
// Static version (Step 2), animated deferred to Step 10
class MeshGradientBackground extends StatelessWidget {
  const MeshGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base layer
        Container(color: AppColors.surfaceBase),
        // Blob 1: accentStart, top-left
        Positioned(
          top: -80, left: -40,
          child: _blob(280, AppColors.accentStart, 0.07),
        ),
        // Blob 2: accentMid, center-right
        Positioned(
          top: 200, right: -60,
          child: _blob(320, AppColors.accentMid, 0.05),
        ),
        // Blob 3: accentCyan, bottom-center
        Positioned(
          bottom: -100, left: 80,
          child: _blob(260, AppColors.accentCyan, 0.06),
        ),
        // Screen content
        child,
      ],
    );
  }

  Widget _blob(double size, Color color, double opacity) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), Colors.transparent],
        ),
      ),
    );
  }
}
```

### GlassCard with Glow Support
```dart
// GlassCard - replaces AppCard
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key, required this.child,
    this.padding, this.borderRadius, this.glowColor,
    this.elevation = 1,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? glowColor;
  final int elevation;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.md;
    final shadows = [
      ...AppShadows.elevation1, // or elevation2/3 based on param
      if (glowColor != null)
        BoxShadow(color: glowColor!, blurRadius: 20, spreadRadius: -2),
    ];

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? AppSpacing.all4,
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: radius,
            border: Border.all(
              color: glowColor ?? AppColors.borderSubtle,
              width: 0.5,
            ),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }
}
```

### AppButton with Scale Press Animation
```dart
// AppButton - 3 variants with press animation
class AppButton extends StatefulWidget {
  const AppButton({
    super.key, required this.label, this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon, this.isLoading = false,
  });
  // ... fields ...
  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  double _scale = 1.0;

  void _onDown(_) => setState(() => _scale = 0.97);
  void _onUp(_) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onDown, onTapUp: _onUp, onTapCancel: _onUp,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: _buildButton(),
      ),
    );
  }
  // _buildPrimary: gradient fill (accentStart -> accentEnd), glow shadow, 52px height
  // _buildSecondary: glass fill, accentCyan border
  // _buildGhost: text only, accentCyan color
}
```

## Runtime State Inventory

This is NOT a rename/refactor/migration phase for data or services. It is a UI-only theme change.

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | None -- theme is visual only, no data schema changes | None |
| Live service config | None -- no service configurations reference colors | None |
| OS-registered state | None | None |
| Secrets/env vars | None | None |
| Build artifacts | None -- theme changes are source-level only | None |

**Nothing found in any category.** This is a pure design-layer refactor with zero runtime state impact.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (built-in) |
| Config file | none -- uses default test/ directory |
| Quick run command | `flutter test` |
| Full suite command | `flutter test` |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| D-01 | Dark-only theme (no light mode) | smoke | `flutter analyze` | N/A (static analysis) |
| D-02 | Color palette matches spec hex values | unit | `flutter test` | N/A (no theme tests exist) |
| D-03 | GlassCard uses BackdropFilter with blur 20 | visual | manual (screenshot) | N/A |
| D-07 | Zero business logic changes | regression | `flutter test` | 7 existing test files |

### Sampling Rate
- **Per task commit:** `flutter analyze` (catches compile errors from token migration)
- **Per wave merge:** `flutter test` (runs all 7 existing test files)
- **Phase gate:** Full `flutter test` green + manual visual verification on device

### Wave 0 Gaps
- [ ] No theme-specific unit tests exist -- consider adding token validation tests
- [ ] No widget tests for core widgets (AppCard, AppButton, AppChip) -- existing tests cover models/viewmodels only
- [ ] Existing 7 test files test models and viewmodels, NOT UI -- they should still pass after theme changes since D-07 guarantees zero business logic changes

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | No auth changes in this phase |
| V3 Session Management | no | No session changes |
| V4 Access Control | no | No access control changes |
| V5 Input Validation | no | No input handling changes |
| V6 Cryptography | no | No crypto changes |

### Known Threat Patterns
None specific to a UI theme redesign phase. The only security-relevant aspect is ensuring BackdropFilter does not inadvertently expose sensitive content through blur transparency -- but since the app displays conversation transcripts (not PII like credit cards), this is LOW risk.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | All builds | Yes | 3.10.8+ (per pubspec sdk constraint) | -- |
| Dart SDK | Compilation | Yes | ^3.10.8 (per pubspec) | -- |
| Android emulator/device | Visual verification | Must check | -- | Use web build for initial testing |
| iOS simulator/device | Visual verification | Must check | -- | Use web build for initial testing |

**Missing dependencies with no fallback:** None -- all packages are already in pubspec.yaml.

## Sources

### Primary (HIGH confidence)
- Design spec: `docs/superpowers/specs/2026-08-05-ui-redesign-design.md` (441 lines, full spec)
- Current theme files: `lib/core/theme/app_colors.dart`, `app_theme.dart`, `app_text_styles.dart`, `app_dimensions.dart`, `app_shadows.dart`
- Current widgets: `lib/core/widgets/app_card.dart`, `app_button.dart`, `app_chip.dart`, `app_nav_bar.dart`, `gradient_background.dart`
- Legacy migration data: grep of 333 references across 30 files (verified this session)

### Secondary (MEDIUM confidence)
- [ASSUMED] BackdropFilter performance characteristics based on Flutter rendering pipeline knowledge
- [ASSUMED] flutter_animate stagger API based on package documentation familiarity

### Tertiary (LOW confidence)
- None -- all findings verified against actual codebase

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | BackdropFilter with blur 20 will perform acceptably on mid-range devices | Common Pitfalls | LOW -- can tune sigma down if needed |
| A2 | flutter_animate `.animate().fadeIn().slideY()` API matches documented usage | Code Examples | LOW -- API is stable, already in project |
| A3 | Renaming GradientBackground to MeshGradientBackground requires project-wide import update | Pitfall 6 | MEDIUM -- could instead keep class name and change implementation |

## Open Questions

1. **GlassCard performance at scale** -- Will 5-6 glass cards on a single screen (home dashboard) cause frame drops?
   - What we know: BackdropFilter triggers saveLayer per instance
   - What's unclear: Actual performance on target devices (Flutter version, GPU)
   - Recommendation: Implement, profile on device, tune blur sigma if needed (spec says 20, could reduce to 12-16)

2. **GradientBackground rename strategy** -- Rename class or keep name?
   - What we know: All 13 screens import GradientBackground
   - What's unclear: Whether renaming creates more churn than keeping the name
   - Recommendation: Claude's discretion -- either approach works; renaming is cleaner but requires find-replace across all screens

## Metadata

**Confidence breakdown:**
- Standard Stack: HIGH -- all packages already in pubspec.yaml, no new dependencies
- Architecture: HIGH -- MVVM pattern well-established, theme layer clearly separated from business logic
- Pitfalls: HIGH -- verified against actual codebase grep results (333 refs, 30 files, 3 ThemeModeProvider refs, AppRadius.xl/full in 3 files)

**Research date:** 2026-08-05
**Valid until:** 2026-09-05 (stable -- Flutter theme APIs are mature, no rapid changes expected)
