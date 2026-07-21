# Phase 4: Gamification & Retention - Context

**Gathered:** 2026-07-21
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase adds engagement mechanics (streaks, XP, levels, badges), learning intelligence (spaced repetition for missed items, mistake tracking), and social features (leaderboard). It also introduces app-wide navigation via Bottom Navigation Bar with GoRouter. Does NOT include premium gating, pronunciation scoring, or monetization — those belong in Phase 5.

</domain>

<decisions>
## Implementation Decisions

### Navigation & GoRouter
- **D-01:** Bottom Navigation Bar with 4 tabs: Home (dashboard), Scenarios (list), Progress (stats/badges), Profile (settings). Conversation screen is always full-screen push with no bottom nav visible.
- **D-02:** Tab icons use custom claymorphism-style icons matching the app theme, not standard Material icons.
- **D-03:** Guest users see reduced tabs — only Home and Scenarios. Progress and Profile tabs are hidden until account creation.
- **D-04:** Initial route logic: Splash → check if profile exists → if yes, skip onboarding and go to Home; if no, go to onboarding flow. Auth-first approach.
- **D-05:** Use GoRouter for all navigation including bottom nav, route guards (auth check, onboarding complete), and deep linking support.

### Streak & XP Mechanics
- **D-06:** Daily streak: Complete 1+ scenarios per day to maintain streak. Missing a day resets to 0. No grace period.
- **D-07:** Fixed XP: 50 XP per scenario completed. Simple, predictable, no score-based variability.
- **D-08:** XP + level progression system. 5 levels: Beginner (0), Elementary (500), Intermediate (1000), Advanced (1500), Master (2000). Linear progression (500 XP per level).
- **D-09:** Streak resets at midnight in user's local timezone.

### Badge System
- **D-10:** Small set of 5-8 badges at launch. Categories: milestone-based (streak, XP, scenarios) + skill achievements (Perfect Score, No Mistakes, Fast Learner).
- **D-11:** Badge awards trigger immediate animated popup during conversation. Celebratory, interruptive by design — user should feel rewarded.
- **D-12:** Badge system designed to be extensible — new badges can be added via config without code changes.

### SRS & Mistake Dashboard
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

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project Architecture
- `CLAUDE.md` — Project brief, MVVM architecture, design style (3D Claymorphism), build phases
- `.planning/REQUIREMENTS.md` — All requirements with traceability
- `.planning/STATE.md` — Current project state

### Codebase Maps
- `.planning/codebase/ARCHITECTURE.md` — System overview, component responsibilities, MVVM flow
- `.planning/codebase/STRUCTURE.md` — Directory layout, naming conventions, where to add new code
- `.planning/codebase/CONVENTIONS.md` — Coding conventions and patterns
- `.planning/codebase/STACK.md` — Technology stack details

### Prior Phase Context
- `.planning/phases/02-complete-mvp-features/02-CONTEXT.md` — Onboarding, feedback, local storage decisions

No external specs — requirements fully captured in decisions above.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `LinguoWizardApp` (lib/main.dart): Root widget with theme and routing — needs GoRouter migration
- `ScenarioSelectionScreen` (lib/features/scenario_selection/screens/): CEFR filter logic reusable
- `ConversationViewModel` (lib/features/conversation/viewmodels/): Voice loop state machine — streak/XP triggers on completion
- `FeedbackScreen` (lib/features/feedback/screens/): Score data model extends to XP calculation
- `FirestoreService` (lib/core/services/): Cloud sync for streaks, XP, badges, SRS data

### Established Patterns
- MVVM with Riverpod: Views are pure UI, ViewModels own logic, Services wrap external packages
- Feature-first folder structure: Each feature owns views/, viewmodels/, models/
- StateNotifier for ViewModel state: All ViewModels follow this pattern
- Fire-and-forget Firestore sync: Used across ViewModels for non-blocking UI

### Integration Points
- Route table in lib/main.dart: Migrate to GoRouter with bottom nav shell
- ConversationViewModel: Fires streak/XP/badge checks on conversation completion
- FeedbackScreen: Displays XP earned, triggers badge popup
- FirestoreService: Stores streaks, XP, badges, SRS data per user

</code_context>

<specifics>
## Specific Ideas

- Bottom nav uses custom claymorphism icons to match the app's 3D aesthetic
- Badge popup should be animated and celebratory — user should feel rewarded
- Pre-scenario review screen shows SRS items as a "Practice these words" card before starting
- Level progression should feel rewarding with clear visual feedback on level-up
- Streak flame icon should be prominent on Home dashboard

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 04-gamification-retention*
*Context gathered: 2026-07-21*
