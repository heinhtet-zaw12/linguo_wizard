---
phase: "05"
plan: "03"
subsystem: "scenario-selection"
tags: ["twist", "replay", "ai-variation", "gemini", "firestore", "engagement"]
requires: ["05-01-PLAN.md", "05-02-PLAN.md"]
provides: ["Today's Twist badge", "AI-generated twist variations", "progressive-twist-depth"]
affects: ["scenario-selection-screen", "scenario-card", "conversation-pipeline", "firestore-user-data"]
tech-stack:
  added: ["TwistViewModel", "generateTwistVariation", "twist replay counter"]
  patterns: ["Stack-based badge overlay on card", "Depth-based AI prompt variation", "Service layer extension without pipeline changes"]
key-files:
  created:
    - "lib/features/scenario_selection/viewmodels/twist_viewmodel.dart"
  modified:
    - "lib/core/services/ai_service.dart"
    - "lib/core/services/scenario_service.dart"
    - "lib/features/scenario_selection/widgets/scenario_card.dart"
    - "lib/features/scenario_selection/viewmodels/scenario_selection_viewmodel.dart"
    - "lib/features/scenario_selection/screens/scenario_selection_screen.dart"
    - "lib/features/conversation/viewmodels/conversation_viewmodel.dart"
  removed: []
decisions:
  - "Twist badge uses Stack-based overlay on ScenarioCard to avoid disrupting existing card layout"
  - "Twist scenario IDs use 'twist_{originalId}_{timestamp}' format for isTwist detection via prefix"
  - "TwistViewModel wraps generateAndLaunchTwist in AsyncValue state for screen to watch and navigate"
  - "Completed scenario detection checks bestScore OR completed OR completedAt for guard against started-but-not-finished scenarios"
  - "Twist badge shown for both curated and custom scenarios when completion data exists"
metrics:
  duration: "18 minutes"
  completed_date: "2026-07-23"
status: "complete"
---

# Phase 5 Plan 03: Today's Twist — Summary

Added "Today's Twist" — a gold sparkle badge on completed scenario cards that lets users replay with AI-generated variations. First replay is subtle, subsequent replays get more creative. No twist history screen or counter — just a visible badge that invites replay. Twist variations flow through the existing conversation pipeline unchanged.

## What Was Built

### Task 1: Twist Replay Counter and Variation Generation (Service Layer)

**FirestoreScenarioService** (`lib/core/services/scenario_service.dart`):
- `getTwistReplayCount(uid, scenarioId)` — reads twist replay count from `users/{uid}/scenarios/{scenarioId}.twistReplayCount`, defaults to 0
- `incrementTwistReplay(uid, scenarioId)` — atomically increments twistReplayCount via `FieldValue.increment(1)` and records `twistLastPlayedAt` timestamp via `FieldValue.serverTimestamp()`, using `SetOptions(merge: true)` so existing scenario data is preserved

**AiService** (`lib/core/services/ai_service.dart`):
- `generateTwistVariation(scenario, replayCount)` — generates a scenario variation via Gemini with structured JSON output:
  - `replayCount == 0`: subtle change (different time of day, slightly different request, same character and goal)
  - `replayCount >= 1`: moderate change (different character, different goal, or complication, same theme)
  - Uses `responseSchema` for reliable JSON parsing (title, description, personaName, personaDescription, goalDescription, openingMessage)
  - 30-second timeout with `TimeoutException`
  - Fresh GenerativeModel instance — does not affect existing chat sessions

### Task 2: Twist Badge on ScenarioCard and Detection Logic

**ScenarioCard** (`lib/features/scenario_selection/widgets/scenario_card.dart`):
- New optional parameters: `showTwistBadge` (bool, default false), `onTwistTap` (VoidCallback?)
- Gold sparkle icon (`Icons.auto_awesome`) positioned top-right via Stack with `Positioned`
- Container: 28x28, gold fill (#F5C862), top-right/bottom-left curved border, gold shadow glow
- Tooltip: "Play again with a twist" (per UI-SPEC)
- GestureDetector on badge prevents the card's main onTap from firing

**ScenarioSelectionViewModel** (`lib/features/scenario_selection/viewmodels/scenario_selection_viewmodel.dart`):
- Added `completedScenarioIds` (Set<String>) and `twistReplayCounts` (Map<String, int>) to `ScenarioSelectionState`
- In `build()`, loads completed scenario data from `users/{uid}/scenarios/` collection via `FirestoreService.getScenarios()`
- Only marks a scenario as completed if the document has `completed == true` OR `bestScore != null` OR `completedAt != null` (Pitfall 2 protection)
- Failure to load completion data is silent — twist badges simply don't show

**TwistViewModel** (`lib/features/scenario_selection/viewmodels/twist_viewmodel.dart`) — new file:
- `StateNotifier<AsyncValue<Scenario?>>` — exposes generated twist scenario for screen navigation
- `generateAndLaunchTwist()`: reads replay count → generates variation → builds Scenario → increments replay count → sets state to AsyncData
- `reset()`: clears state back to null after navigation
- Provider: `twistProvider` (StateNotifierProvider)

### Task 3: Screen Wiring and Pipeline Integration

**ScenarioSelectionScreen** (`lib/features/scenario_selection/screens/scenario_selection_screen.dart`):
- `ref.listen(twistProvider)` watches for generated twist scenario → sets `selectedScenarioProvider` → navigates to `/conversation/:id` → resets twist state
- Curated scenario cards receive `showTwistBadge: state.completedScenarioIds.contains(scenario.id)` and `onTwistTap` that calls `twistProvider.notifier.generateAndLaunchTwist()`

**ConversationViewModel** (`lib/features/conversation/viewmodels/conversation_viewmodel.dart`):
- Added `isTwist` getter: `state.value?.scenario?.id.startsWith('twist_') ?? false`
- No pipeline changes — twist scenarios use same `initializePersona()` and `sendMessage()` flow
- Evaluation and gamification flow unchanged (no special XP for twist per D-03)

**Router** — no changes. Twist scenarios navigate to existing `/conversation/:id` route via `selectedScenarioProvider`.

## Deviations from Plan

None — plan executed exactly as written.

## Verification

| Check | Result |
|-------|--------|
| `flutter analyze lib/` | 0 errors (1 pre-existing info-level note) |
| FirestoreScenarioService.getTwistReplayCount | PASS |
| FirestoreScenarioService.incrementTwistReplay | PASS |
| AiService.generateTwistVariation | PASS |
| TwistViewModel created | PASS |
| TwistViewModel provider registered | PASS |
| ScenarioCard: showTwistBadge param | PASS |
| ScenarioCard: onTwistTap param | PASS |
| Gold sparkle badge (Icons.auto_awesome) top-right | PASS |
| Tooltip: "Play again with a twist" | PASS |
| ScenarioSelectionState: completedScenarioIds | PASS |
| ScenarioSelectionState: twistReplayCounts | PASS |
| build() loads completed scenarios from Firestore | PASS |
| Completion guard (completed OR bestScore OR completedAt) | PASS |
| Twist badge on curated cards in grid | PASS |
| ref.listen twistProvider for navigation | PASS |
| ConversationViewModel.isTwist getter | PASS |
| No twist history/counter screen | PASS per D-05 |

## Known Stubs

None. Twist badge shows on completed scenarios based on Firestore completion data. Twist variation generation goes through the existing conversation pipeline with no visual or behavioral changes.

## Threat Flags

No new security surface introduced beyond the plan's threat model. Twist generation counts toward the existing AI call rate limit (T-05-09). Scenario content sent to Gemini is non-sensitive learning content (T-05-10, accepted).

## Self-Check: PASSED

- All created files exist at expected paths
- All 3 task commits present in git log
- flutter analyze passes with 0 errors
