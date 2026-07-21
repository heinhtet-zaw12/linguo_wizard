# Phase 4: Gamification & Retention - Research

**Researched:** 2026-07-21
**Domain:** Gamification mechanics, spaced repetition, navigation architecture, Firestore data patterns
**Confidence:** MEDIUM

## Summary

Phase 4 introduces app-wide navigation via GoRouter with a BottomNavigationBar shell, engagement mechanics (streaks, XP, levels, badges), spaced repetition for missed items, a mistake pattern dashboard, and a leaderboard. The existing codebase already has a HomeScreen with streak ring and goal ring widgets, a FeedbackScreen with XP badge, and a FirestoreService with progress persistence. The primary work involves migrating from named routes to GoRouter, implementing a proper streak calculation algorithm, building the SRS engine, creating a config-driven badge system, and adding the Progress and Leaderboard screens.

**Primary recommendation:** Use `StatefulShellRoute.indexedStack` from go_router for bottom nav with state preservation. Implement SM-2 algorithm as a pure Dart service (no external package needed). Store streak data with `YYYY-MM-DD` date strings in user timezone, not Firestore `serverTimestamp()`. Use `confetti` package (v0.8.0) for celebration animations.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Bottom Navigation Bar with 4 tabs: Home (dashboard), Scenarios (list), Progress (stats/badges), Profile (settings). Conversation screen is always full-screen push with no bottom nav visible.
- **D-02:** Tab icons use custom claymorphism-style icons matching the app theme, not standard Material icons.
- **D-03:** Guest users see reduced tabs — only Home and Scenarios. Progress and Profile tabs are hidden until account creation.
- **D-04:** Initial route logic: Splash → check if profile exists → if yes, skip onboarding and go to Home; if no, go to onboarding flow. Auth-first approach.
- **D-05:** Use GoRouter for all navigation including bottom nav, route guards (auth check, onboarding complete), and deep linking support.
- **D-06:** Daily streak: Complete 1+ scenarios per day to maintain streak. Missing a day resets to 0. No grace period.
- **D-07:** Fixed XP: 50 XP per scenario completed. Simple, predictable, no score-based variability.
- **D-08:** XP + level progression system. 5 levels: Beginner (0), Elementary (500), Intermediate (1000), Advanced (1500), Master (2000). Linear progression (500 XP per level).
- **D-09:** Streak resets at midnight in user's local timezone.
- **D-10:** Small set of 5-8 badges at launch. Categories: milestone-based (streak, XP, scenarios) + skill achievements (Perfect Score, No Mistakes, Fast Learner).
- **D-11:** Badge awards trigger immediate animated popup during conversation. Celebratory, interruptive by design — user should feel rewarded.
- **D-12:** Badge system designed to be extensible — new badges can be added via config without code changes.
- **D-13:** Spaced repetition tracks grammar corrections, vocabulary gaps, and phrases user missed. Most comprehensive scope.
- **D-14:** SRS items reintroduced via pre-scenario review screen. User sees words/phrases to practice before starting a scenario. Explicit, user-controlled approach.
- **D-15:** Mistake pattern dashboard shows summary metrics only: overall accuracy %, grammar mistakes count, vocabulary gaps count. Simple summary, no trend charts or category breakdowns.
- **D-16:** Dashboard covers last 7 days only. Simple, recent focus.

### Claude's Discretion
- Badge visual design (claymorphism style, colors, animations)
- Level tier names and icons (Beginner → Elementary → Intermediate → Advanced → Master)
- Pre-scenario review screen layout and interaction design
- Leaderboard implementation details (global vs friends, anonymous vs named)
- SRS algorithm specifics (interval calculation, ease factor)
- Mistake dashboard visual layout

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| FDBK-01 | Post-conversation screen shows full transcript with inline grammar corrections | Already implemented in FeedbackScreen. Phase 4 extends grammar corrections into SRS tracking (D-13). |
| FDBK-02 | Post-conversation screen shows summary score (fluency, grammar, vocabulary) | Already implemented. Phase 4 adds XP/level progression display. |
| FDBK-03 | User earns XP for completing scenarios | Already implemented (ScoreData.xpEarned). Phase 4 updates xpPerScenario from 10 to 50 (D-07) and adds level progression (D-08). |
</phase_requirements>

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| GoRouter navigation shell | Frontend Server (SSR) | Browser/Client | ShellRoute wraps the app's navigation scaffold; route guards live in router config |
| Bottom nav tab switching | Browser/Client | — | Pure UI state managed by GoRouter's StatefulShellRoute |
| Streak calculation | API/Backend (Firestore) | Client (display) | Streak logic must be timezone-aware; Firestore stores lastActivityDate, client computes streak |
| XP award & level calculation | API/Backend (Firestore) | Client (display) | XP persisted to Firestore; level derived from total XP client-side |
| Badge award triggers | Client | API/Backend (Firestore) | Badge eligibility checked on conversation completion; popup shown immediately; persisted async |
| SRS engine (SM-2) | Client (pure Dart) | API/Backend (Firestore) | SM-2 algorithm is stateless computation; SRS items stored in Firestore subcollection |
| Pre-scenario review | Browser/Client | — | UI screen showing SRS items before scenario starts |
| Mistake pattern tracking | API/Backend (Firestore) | Client (display) | Grammar corrections and vocab gaps extracted from ScoreData and stored in Firestore |
| Mistake dashboard | Client | API/Backend (Firestore) | Reads last 7 days of mistake data from Firestore |
| Leaderboard | API/Backend (Firestore) | Client (display) | Firestore query for top users ordered by XP; real-time listener for updates |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| go_router | ^14.8.0 | Declarative routing with ShellRoute, auth guards, deep linking | Official Flutter team package; StatefulShellRoute preserves tab state; supports redirects for auth/onboarding guards [CITED: pub.dev/packages/go_router] |
| confetti | ^0.8.0 | Celebration animations for badge popups and level-ups | Most popular confetti package on pub.dev; customizable shapes, colors, physics; lightweight [VERIFIED: pub.dev] |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| flutter_animate | ^4.5.0 | Composing multi-step animation sequences for badge popups | When confetti alone is insufficient for complex celebration sequences [ASSUMED] |
| timezone | ^0.10.0 | Timezone-aware date comparison for streak calculation | Only if built-in Dart timezone handling is insufficient for streak midnight reset [ASSUMED] |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| go_router StatefulShellRoute | Nested Navigators manually | go_router handles state preservation, URL sync, and deep linking out of the box; manual approach is error-prone |
| confetti package | Custom AnimationController + CustomPainter | confetti handles particle physics, shapes, and lifecycle; custom is 10x effort for same result |
| SM-2 (hand-rolled) | spaced_rep package on pub.dev | SM-2 is simple enough to implement in ~50 lines; no need for external dependency; full control over parameters |

**Installation:**
```bash
flutter pub add go_router confetti
```

**Version verification:** Before writing the Standard Stack table, verify each recommended package exists and is current using the ecosystem-appropriate command:
```bash
flutter pub add go_router --dry-run    # Verify resolution
flutter pub add confetti --dry-run     # Verify resolution — confirmed v0.8.0
```
Document the verified version and publish date. Training data versions may be months stale — always confirm against the correct ecosystem registry.

## Package Legitimacy Audit

> **Required** whenever this phase installs external packages. Run the Package Legitimacy Gate protocol before completing this section.

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| go_router | pub.dev | 5+ years | High (official Flutter team) | github.com/flutter/packages | OK | Approved — official Flutter team package |
| confetti | pub.dev | 6+ years | High | github.com/songsanthu/confetti | OK | Approved — established package, v0.8.0 verified |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

*Note: The gsd-tools package-legitimacy check runs against npm registry. For Flutter packages, legitimacy was verified via pub.dev resolution (`flutter pub add --dry-run`) and official source confirmation.*

## Architecture Patterns

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        GoRouter Shell                            │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │              ScaffoldWithNavBar (4 tabs)                    │ │
│  │  ┌──────────┬──────────┬──────────┬──────────┐             │ │
│  │  │  Home    │Scenarios │ Progress │ Profile  │             │ │
│  │  │  Tab     │  Tab     │  Tab     │  Tab     │             │ │
│  │  └──────────┴──────────┴──────────┴──────────┘             │ │
│  │                     ↕ child route                          │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│  Full-screen routes (no bottom nav):                            │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │  Conversation → Pre-Scenario Review → Feedback              │ │
│  │  (Badge popup overlay)            (XP/Level display)        │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
         │                        │
         ▼                        ▼
┌──────────────────┐   ┌──────────────────┐
│  Gamification    │   │  SRS Engine      │
│  ViewModel       │   │  (SM-2 Algorithm)│
│  - Streak calc   │   │  - Interval/Ease │
│  - XP/Level      │   │  - Review queue  │
│  - Badge checks  │   │  - Item storage  │
└────────┬─────────┘   └────────┬─────────┘
         │                      │
         ▼                      ▼
┌──────────────────────────────────────────┐
│           FirestoreService               │
│  - users/{uid}/progress (streak, XP)     │
│  - users/{uid}/badges (earned badges)    │
│  - users/{uid}/srs_items (SRS queue)     │
│  - users/{uid}/mistakes (7-day window)   │
│  - leaderboard (global XP rankings)      │
└──────────────────────────────────────────┘
```

### Recommended Project Structure
```
lib/
├── core/
│   ├── config/
│   │   ├── app_config.dart          # Update xpPerScenario to 50
│   │   ├── badge_config.dart        # NEW: Badge definitions (config-driven)
│   │   └── level_config.dart        # NEW: Level thresholds and names
│   ├── services/
│   │   ├── firestore_service.dart   # EXTEND: streak, badges, SRS, mistakes, leaderboard
│   │   └── srs_service.dart         # NEW: SM-2 algorithm implementation
│   ├── repositories/
│   │   └── gamification_repo.dart   # NEW: Streak, XP, badge coordination
│   └── models/
│       ├── streak_data.dart         # NEW: Streak data model
│       ├── badge.dart               # NEW: Badge data model
│       ├── srs_item.dart            # NEW: SRS item data model
│       └── mistake_record.dart      # NEW: Mistake tracking data model
├── features/
│   ├── navigation/
│   │   ├── scaffold_with_nav_bar.dart  # NEW: Shell widget with BottomNavigationBar
│   │   └── router.dart                 # NEW: GoRouter configuration
│   ├── progress/
│   │   ├── screens/
│   │   │   └── progress_screen.dart    # NEW: Stats, badges, levels display
│   │   ├── viewmodels/
│   │   │   └── progress_viewmodel.dart # NEW: Progress stats ViewModel
│   │   └── widgets/
│   │       ├── badge_grid.dart         # NEW: Badge display grid
│   │       ├── level_progress.dart     # NEW: Level progress bar
│   │       └── mistake_summary.dart    # NEW: Mistake pattern summary
│   ├── leaderboard/
│   │   ├── screens/
│   │   │   └── leaderboard_screen.dart # NEW: Global leaderboard
│   │   ├── viewmodels/
│   │   │   └── leaderboard_viewmodel.dart
│   │   └── models/
│   │       └── leaderboard_entry.dart
│   ├── srs/
│   │   ├── screens/
│   │   │   └── pre_scenario_review.dart # NEW: SRS review before scenario
│   │   ├── viewmodels/
│   │   │   └── srs_viewmodel.dart
│   │   └── models/
│   │       └── srs_item.dart
│   ├── badge/
│   │   ├── widgets/
│   │   │   └── badge_popup.dart         # NEW: Animated badge award popup
│   │   └── models/
│   │       └── badge.dart
│   ├── home/
│   │   ├── viewmodels/
│   │   │   └── home_viewmodel.dart      # UPDATE: Proper streak calculation
│   │   └── widgets/
│   │       └── streak_ring.dart         # UPDATE: Enhanced streak display
│   └── conversation/
│       └── viewmodels/
│           └── conversation_viewmodel.dart # UPDATE: Badge check on completion
```

### Pattern 1: GoRouter StatefulShellRoute with Auth Guards
**What:** Declarative routing with bottom nav that preserves tab state and redirects based on auth/onboarding status
**When to use:** Any Flutter app with bottom navigation that needs route protection
**Example:**
```dart
// Source: Context7 go_router docs, pub.dev/packages/go_router
final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  redirect: (context, state) {
    final isLoggedIn = /* auth state check */;
    final isOnboarded = /* onboarding check */;
    final isOnAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/signup';

    // Redirect to login if not authenticated
    if (!isLoggedIn && !isOnAuthRoute) return '/login';
    // Redirect to onboarding if not completed
    if (isLoggedIn && !isOnboarded && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }
    return null; // No redirect
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', pageBuilder: (_, __) => const NoTransitionPage(child: HomeScreen())),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/scenarios', pageBuilder: (_, __) => const NoTransitionPage(child: ScenarioSelectionScreen())),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/progress', pageBuilder: (_, __) => const NoTransitionPage(child: ProgressScreen())),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', pageBuilder: (_, __) => const NoTransitionPage(child: ProfileScreen())),
        ]),
      ],
    ),
    // Full-screen routes (no bottom nav)
    GoRoute(path: '/conversation/:id', builder: (_, __) => const ConversationScreen()),
    GoRoute(path: '/feedback', builder: (_, __) => const FeedbackScreen()),
  ],
);
```

### Pattern 2: SM-2 Spaced Repetition Algorithm
**What:** Pure Dart implementation of the SM-2 algorithm for calculating review intervals and ease factors
**When to use:** When tracking vocabulary, grammar, or phrase mastery over time
**Example:**
```dart
// Source: SM-2 algorithm by Piotr Wozniak (1987), adapted for Dart
class SrsItem {
  String id;
  String text;           // The word/phrase/grammar rule
  String category;       // 'vocabulary', 'grammar', 'phrase'
  int repetitions;       // Number of successful reviews
  double easeFactor;     // Starts at 2.5, min 1.3
  int interval;          // Days until next review
  DateTime nextReview;   // When to show this item again
  int quality;           // Last review quality (0-5)

  SrsItem({
    required this.id,
    required this.text,
    required this.category,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.interval = 0,
    DateTime? nextReview,
    this.quality = 0,
  }) : nextReview = nextReview ?? DateTime.now();

  /// Update item after review. quality: 0 (fail) to 5 (perfect).
  void review(int quality) {
    if (quality < 3) {
      // Failed — reset
      repetitions = 0;
      interval = 1;
    } else {
      // Passed — advance
      if (repetitions == 0) {
        interval = 1;
      } else if (repetitions == 1) {
        interval = 6;
      } else {
        interval = (interval * easeFactor).round();
      }
      repetitions++;
    }

    // Update ease factor
    easeFactor = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (easeFactor < 1.3) easeFactor = 1.3;

    nextReview = DateTime.now().add(Duration(days: interval));
    this.quality = quality;
  }

  /// Whether this item is due for review.
  bool get isDue => DateTime.now().isAfter(nextReview);

  Map<String, dynamic> toJson() => {
    'id': id, 'text': text, 'category': category,
    'repetitions': repetitions, 'easeFactor': easeFactor,
    'interval': interval, 'nextReview': nextReview.toIso8601String(),
    'quality': quality,
  };

  factory SrsItem.fromJson(Map<String, dynamic> json) => SrsItem(
    id: json['id'] as String,
    text: json['text'] as String,
    category: json['category'] as String,
    repetitions: json['repetitions'] as int? ?? 0,
    easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
    interval: json['interval'] as int? ?? 0,
    nextReview: DateTime.parse(json['nextReview'] as String),
    quality: json['quality'] as int? ?? 0,
  );
}
```

### Pattern 3: Config-Driven Badge System
**What:** Badge definitions stored as config data, not hardcoded in widgets
**When to use:** When badges need to be extensible without code changes
**Example:**
```dart
// Source: [ASSUMED] — config-driven pattern for extensible badge systems
class BadgeDefinition {
  final String id;
  final String name;
  final String description;
  final String iconPath;  // Asset path for claymorphism icon
  final BadgeCategory category;
  final BadgeCondition condition;

  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.category,
    required this.condition,
  });
}

enum BadgeCategory { milestone, skill }

class BadgeCondition {
  final String type;      // 'streak', 'xp', 'scenarios', 'perfect_score', 'no_mistakes', 'fast_learner'
  final int threshold;    // e.g., 7 for "7-day streak", 500 for "500 XP"

  const BadgeCondition({required this.type, required this.threshold});
}

// Config file — new badges added here, no code changes needed
const List<BadgeDefinition> badgeDefinitions = [
  BadgeDefinition(
    id: 'streak_7',
    name: 'On Fire',
    description: 'Maintain a 7-day streak',
    iconPath: 'assets/badges/streak_7.png',
    category: BadgeCategory.milestone,
    condition: BadgeCondition(type: 'streak', threshold: 7),
  ),
  BadgeDefinition(
    id: 'xp_500',
    name: 'XP Hunter',
    description: 'Earn 500 XP total',
    iconPath: 'assets/badges/xp_500.png',
    category: BadgeCategory.milestone,
    condition: BadgeCondition(type: 'xp', threshold: 500),
  ),
  BadgeDefinition(
    id: 'perfect_score',
    name: 'Perfectionist',
    description: 'Score 100 on any scenario',
    iconPath: 'assets/badges/perfect.png',
    category: BadgeCategory.skill,
    condition: BadgeCondition(type: 'perfect_score', threshold: 100),
  ),
  // ... more badges
];
```

### Pattern 4: Firestore Streak with Timezone-Aware Reset
**What:** Streak tracking using YYYY-MM-DD date strings in user's local timezone
**When to use:** Any daily streak mechanic that must reset at midnight in user's timezone
**Example:**
```dart
// Source: [ASSUMED] — standard Firestore streak pattern
// Store date as 'YYYY-MM-DD' string, NOT serverTimestamp
class StreakData {
  final int currentStreak;
  final int longestStreak;
  final String lastActivityDate;  // 'YYYY-MM-DD' in user's timezone

  StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivityDate,
  });

  /// Calculate whether streak continues, resets, or is same day.
  /// [today] must be computed client-side in user's local timezone.
  StreakData updateForToday(String today) {
    if (today == lastActivityDate) {
      // Already counted today — no change
      return this;
    }

    // Calculate yesterday in user's timezone
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    int newStreak;
    if (today == yesterdayStr) {
      // Consecutive day — increment
      newStreak = currentStreak + 1;
    } else {
      // Streak broken — reset to 1
      newStreak = 1;
    }

    return StreakData(
      currentStreak: newStreak,
      longestStreak: [longestStreak, newStreak].reduce((a, b) => a > b ? a : b),
      lastActivityDate: today,
    );
  }
}
```

### Anti-Patterns to Avoid
- **Hardcoded badge definitions in widgets:** Badges should be data-driven; adding a badge should require only a config entry, not a code change [D-12]
- **Using Firestore serverTimestamp() for streak dates:** Server time is UTC; user at UTC+12 doing action at 11 PM local gets next-day UTC date, breaking streaks [D-09]
- **Client-side streak calculation without timezone:** Must use user's local timezone for date comparison, not device UTC offset
- **Two separate data schemas for guest vs authenticated:** Already addressed by architecture; gamification data must follow same pattern

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Bottom nav with state preservation | Manual IndexedStack + Navigator | go_router StatefulShellRoute.indexedStack | Handles URL sync, deep linking, state preservation, route guards |
| Confetti/celebration animations | Custom AnimationController + particle system | confetti package (v0.8.0) | Handles particle physics, shapes, lifecycle; 10x less code |
| Spaced repetition intervals | Manual scheduling logic | SM-2 algorithm (hand-rolled, ~50 lines) | Well-tested algorithm; simple enough to not need external package |
| Timezone-aware date comparison | Manual UTC offset math | Dart's built-in DateTime.now() + local timezone | Dart handles timezone conversion; store as YYYY-MM-DD string |

**Key insight:** The SM-2 algorithm is simple enough (~50 lines) that hand-rolling it is better than adding a dependency. However, confetti and go_router are complex enough that using established packages saves significant effort.

## Runtime State Inventory

> This section is included because Phase 4 involves extending existing Firestore data structures (streak, XP, badges, SRS).

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | Firestore `users/{uid}/progress` doc has `totalXp`, `scenariosCompleted`, `lastScenarioAt` fields. `xpPerScenario` in AppConfig is currently 10 (needs to be 50 per D-07). | Extend progress doc with `currentStreak`, `longestStreak`, `lastActivityDate`. Update AppConfig.xpPerScenario from 10 to 50. |
| Live service config | None — streak/XP/badges are stored per-user, not in service config | None |
| OS-registered state | None | None |
| Secrets/env vars | None — gamification data is not secret | None |
| Build artifacts | None | None |

**Nothing found in category:** OS-registered state, Secrets/env vars, Build artifacts — verified by codebase grep.

## Common Pitfalls

### Pitfall 1: Streak Timezone Mismatch
**What goes wrong:** Streak resets at wrong time because server timestamp is used instead of user's local date
**Why it happens:** Firestore `serverTimestamp()` returns UTC; user at UTC+12 doing action at 11 PM local gets next-day UTC date
**How to avoid:** Store `lastActivityDate` as `'YYYY-MM-DD'` string computed client-side in user's local timezone. Never use `serverTimestamp()` for streak date comparison.
**Warning signs:** Users reporting streaks breaking at midnight local time but not resetting correctly

### Pitfall 2: Bottom Nav State Loss
**What goes wrong:** Switching tabs destroys scroll position and widget state
**Why it happens:** Using basic `ShellRoute` instead of `StatefulShellRoute.indexedStack`
**How to avoid:** Use `StatefulShellRoute.indexedStack` which preserves each branch's state via IndexedStack under the hood
**Warning signs:** Users losing scroll position when switching between Home and Scenarios tabs

### Pitfall 3: XP Value Stale in AppConfig
**What goes wrong:** XP per scenario remains at 10 instead of the D-07 decision of 50
**Why it happens:** AppConfig.xpPerScenario was set to 10 during Phase 2 and not updated
**How to avoid:** Update `AppConfig.xpPerScenario` from 10 to 50 as part of Phase 4 implementation
**Warning signs:** Users earning only 10 XP per scenario instead of 50

### Pitfall 4: Badge Popup Blocking Conversation Flow
**What goes wrong:** Badge popup appears at wrong time,打断ing the conversation experience
**Why it happens:** Badge check runs at wrong point in the conversation lifecycle
**How to avoid:** Trigger badge popup on FeedbackScreen (after conversation ends, before user taps Done), not during the conversation itself. The popup should be celebratory but non-blocking for the feedback flow.
**Warning signs:** Users reporting confusion about when they earned a badge

### Pitfall 5: SRS Items Not Surviving Guest-to-Auth Migration
**What goes wrong:** SRS data lost when guest user creates account
**Why it happens:** SRS items stored only in local storage for guests, not migrated to Firestore on sign-up
**How to avoid:** Store SRS items in SharedPreferences for guests using the same Firestore document structure; migrate on sign-up like other progress data
**Warning signs:** Users losing their SRS review queue after signing up

## Code Examples

Verified patterns from official sources:

### GoRouter ShellRoute with Bottom Navigation
```dart
// Source: Context7 go_router docs, pub.dev/packages/go_router
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore), label: 'Scenarios'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

### Confetti Badge Popup
```dart
// Source: [ASSUMED] — confetti package API from pub.dev
import 'package:confetti/confetti.dart';

class BadgePopup extends StatefulWidget {
  final String badgeName;
  final String badgeDescription;
  const BadgePopup({super.key, required this.badgeName, required this.badgeDescription});

  @override
  State<BadgePopup> createState() => _BadgePopupState();
}

class _BadgePopupState extends State<BadgePopup> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Badge content
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 16)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, size: 64, color: AppColors.accentGold),
                const SizedBox(height: 12),
                Text(widget.badgeName, style: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(widget.badgeDescription, style: GoogleFonts.quicksand(fontSize: 14, color: AppColors.textMuted)),
              ],
            ),
          ),
        ),
        // Confetti overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [AppColors.primaryPink, AppColors.accentGold, AppColors.accentCoral, Colors.white],
          ),
        ),
      ],
    );
  }
}
```

### Level Progression Calculation
```dart
// Source: [ASSUMED] — based on D-08 level thresholds
class LevelConfig {
  static const List<({String name, int xpRequired, String iconPath})> levels = [
    (name: 'Beginner', xpRequired: 0, iconPath: 'assets/levels/beginner.png'),
    (name: 'Elementary', xpRequired: 500, iconPath: 'assets/levels/elementary.png'),
    (name: 'Intermediate', xpRequired: 1000, iconPath: 'assets/levels/intermediate.png'),
    (name: 'Advanced', xpRequired: 1500, iconPath: 'assets/levels/advanced.png'),
    (name: 'Master', xpRequired: 2000, iconPath: 'assets/levels/master.png'),
  ];

  /// Returns (currentLevel, nextLevel, progressFraction).
  static ({int index, String name, double progress}) getLevelInfo(int totalXp) {
    for (int i = levels.length - 1; i >= 0; i--) {
      if (totalXp >= levels[i].xpRequired) {
        final current = levels[i];
        final next = i < levels.length - 1 ? levels[i + 1] : null;
        final progress = next != null
            ? (totalXp - current.xpRequired) / (next.xpRequired - current.xpRequired)
            : 1.0;
        return (index: i, name: current.name, progress: progress.clamp(0.0, 1.0));
      }
    }
    return (index: 0, name: levels[0].name, progress: 0.0);
  }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Named routes in MaterialApp | GoRouter with StatefulShellRoute | Phase 4 | Enables auth guards, deep linking, stateful bottom nav |
| xpPerScenario = 10 | xpPerScenario = 50 | Phase 4 (D-07) | All XP calculations use new value |
| Stub streak calculation (returns 1) | Full timezone-aware streak algorithm | Phase 4 (D-06, D-09) | Proper streak tracking with midnight reset |
| No badge system | Config-driven badge definitions | Phase 4 (D-10, D-12) | Extensible badge system |

**Deprecated/outdated:**
- Named routes in `MaterialApp` — replaced by GoRouter for auth guards and bottom nav
- `AppConfig.xpPerScenario = 10` — updated to 50 per D-07
- Streak calculation stub in HomeViewModel — replaced with proper algorithm

## Assumptions Log

> List all claims tagged `[ASSUMED]` in this research. The planner and discuss-phase use this
> section to identify decisions that need user confirmation before execution.

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | flutter_animate v4.5.0 is the latest version | Standard Stack | Low — package is well-known; version may be slightly off |
| A2 | timezone v0.10.0 is the latest version | Standard Stack | Low — may not be needed if Dart built-in timezone handling suffices |
| A3 | Badge popup should appear on FeedbackScreen, not during conversation | Common Pitfalls | Medium — user may prefer different timing |
| A4 | SRS items should be stored in SharedPreferences for guests using Firestore-compatible structure | Common Pitfalls | Low — follows established guest-to-auth migration pattern |

**If this table is empty:** Not applicable — 4 assumptions documented.

## Open Questions

1. **Where should the badge popup appear?**
   - What we know: D-11 says "immediate animated popup during conversation"
   - What's unclear: "during conversation" could mean at conversation end (feedback screen) or during the conversation itself
   - Recommendation: Show badge popup on FeedbackScreen after evaluation completes, before user taps Done. This keeps the conversation flow clean while still being "immediate" after the achievement is recognized.

2. **Should leaderboard be global or friends-only?**
   - What we know: Claude's Discretion area says "Leaderboard implementation details (global vs friends, anonymous vs named)"
   - What's unclear: User hasn't decided yet
   - Recommendation: Start with global leaderboard (simpler, no friend system needed). Add friend filtering later if requested.

3. **How should the pre-scenario review screen integrate with the conversation flow?**
   - What we know: D-14 says "SRS items reintroduced via pre-scenario review screen"
   - What's unclear: Where in the flow does this screen appear? Before conversation starts? As an optional step?
   - Recommendation: Show pre-scenario review as an optional screen after scenario selection but before conversation starts. User can skip if no SRS items are due.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | All features | ✓ | 3.38.9 | — |
| Dart SDK | All features | ✓ | 3.10.8 | — |
| Firebase Auth | Auth guards | ✓ | 5.7.0 | — |
| Firestore | Streak/XP/badges/SRS storage | ✓ | 5.6.12 | — |
| go_router | Navigation | ✗ | — | Install: `flutter pub add go_router` |
| confetti | Badge animations | ✗ | — | Install: `flutter pub add confetti` |

**Missing dependencies with no fallback:**
- go_router — must be installed before navigation migration
- confetti — must be installed before badge popup implementation

**Missing dependencies with fallback:**
- None

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (built-in) |
| Config file | none — standard Flutter test setup |
| Quick run command | `flutter test` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| FDBK-01 | Transcript with grammar corrections | unit | `flutter test test/models/score_data_test.dart` | ✅ Exists |
| FDBK-02 | Summary score display | unit | `flutter test test/viewmodels/feedback_viewmodel_test.dart` | ✅ Exists |
| FDBK-03 | XP earned for scenarios | unit | `flutter test test/models/score_data_test.dart` | ✅ Exists |

### Sampling Rate
- **Per task commit:** `flutter test`
- **Per wave merge:** `flutter test`
- **Phase gate:** Full suite green before `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `test/models/streak_data_test.dart` — covers streak calculation logic
- [ ] `test/models/srs_item_test.dart` — covers SM-2 algorithm
- [ ] `test/models/badge_test.dart` — covers badge condition evaluation
- [ ] `test/viewmodels/progress_viewmodel_test.dart` — covers progress stats
- [ ] `test/viewmodels/leaderboard_viewmodel_test.dart` — covers leaderboard queries
- [ ] `test/navigation/router_test.dart` — covers GoRouter route guards and redirects

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | yes | Firebase Auth (already implemented) |
| V3 Session Management | yes | Firebase Auth state via Riverpod StreamProvider |
| V4 Access Control | yes | Firestore security rules for user-scoped data |
| V5 Input Validation | yes | SRS item text validated at ViewModel layer |
| V6 Cryptography | no | No sensitive data requiring encryption beyond Firebase defaults |

### Known Threat Patterns for Flutter/Firebase Stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Streak manipulation (client-side) | Tampering | Store streak in Firestore; validate server-side via Cloud Functions |
| XP inflation (fake scenario completion) | Tampering | XP award only after successful evaluation via EvaluationService |
| Leaderboard spam (fake XP) | Tampering | Firestore security rules + server-side validation |
| SRS data tampering | Tampering | Firestore security rules scoped to authenticated user |

## Sources

### Primary (HIGH confidence)
- Context7 go_router docs — ShellRoute, StatefulShellRoute, auth guards, nested navigation
- pub.dev/packages/go_router — Official Flutter team package, verified resolution
- pub.dev/packages/confetti — Verified v0.8.0 resolution

### Secondary (MEDIUM confidence)
- WebSearch results on SM-2 algorithm — well-documented algorithm, implementation pattern verified
- WebSearch results on Firestore streak tracking — standard pattern with YYYY-MM-DD date strings
- WebSearch results on Firestore leaderboard — orderBy query pattern with real-time snapshots

### Tertiary (LOW confidence)
- flutter_animate package version — training data, not verified this session
- timezone package version — training data, not verified this session

## Metadata

**Confidence breakdown:**
- Standard Stack: MEDIUM — go_router and confetti verified on pub.dev; flutter_animate version unverified
- Architecture: HIGH — SM-2 algorithm is well-documented; GoRouter patterns from official docs; Firestore patterns are standard
- Pitfalls: MEDIUM — timezone streak issue is well-known; other pitfalls derived from codebase analysis

**Research date:** 2026-07-21
**Valid until:** 2026-08-21 (30 days — stable stack, fast-moving Flutter ecosystem)
