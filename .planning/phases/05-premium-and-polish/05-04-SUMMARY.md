---
phase: "05"
plan: "04"
subsystem: "home-dashboard"
tags: ["daily-challenge", "engagement", "countdown", "bonus-xp", "gemini", "firestore", "utc-rotation"]
requires: ["05-01-PLAN.md", "05-02-PLAN.md", "05-03-PLAN.md"]
provides: ["Daily Challenge hero card", "UTC-based rotation via Firestore seed", "2x XP bonus on completion", "countdown timer urgency"]
affects: ["home-screen", "home-viewmodel", "conversation-pipeline", "firestore-rules"]
tech-stack:
  added: ["DailyChallengeService", "DailyChallengeCard", "dailyChallengeProvider", "challengeCompletedProvider", "generateDailyChallenge"]
  patterns: ["First-user-of-UTC-day generates seed", "Firestore document as globally consistent source of truth", "1-minute Timer.periodic countdown with dispose cleanup"]
key-files:
  created:
    - "lib/core/services/daily_challenge_service.dart"
    - "lib/features/home/widgets/daily_challenge_card.dart"
  modified:
    - "lib/core/services/ai_service.dart"
    - "lib/core/providers/service_providers.dart"
    - "firestore.rules"
    - "lib/features/home/viewmodels/home_viewmodel.dart"
    - "lib/features/home/screens/home_screen.dart"
    - "lib/features/conversation/viewmodels/conversation_viewmodel.dart"
  removed: []
decisions:
  - "Daily Challenge uses UTC-based rotation via DateTime.now().toUtc() — no timezone package needed per RESEARCH.md"
  - "First user of UTC day triggers AI generation and writes to /challenges/YYYY-MM-DD; subsequent users read existing document"
  - "Globally consistent challenge — same challenge for all users on a given UTC day (per Claude's discretion, RESEARCH.md Q2)"
  - "Gold (#F5C862) used exclusively for XP badge and award elements — never for primary action buttons"
  - "Countdown updates every 1 minute via Timer.periodic, cancelled in dispose() to prevent memory leaks (Pitfall 3)"
  - "Coral (#E8836B) used for urgency when < 1h remaining in countdown"
  - "Completed state uses gold checkmark (accentGold) not green — stays on-brand per UI-SPEC"
metrics:
  duration: "12 minutes"
  completed_date: "2026-07-23"
status: "complete"
---

# Phase 5 Plan 04: Daily Challenge — Summary

Added a Daily Challenge hero card to the Home dashboard — a fresh AI-generated variation of a random curated scenario, available once per UTC day. The first user of the day triggers generation via Gemini; subsequent users read the existing Firestore seed document. Completing the challenge awards 200% XP (50 base + 50 bonus = 100 total). A countdown timer creates daily urgency ("5h remaining"), switching to coral when under 1 hour.

## What Was Built

### Task 1: DailyChallengeService and AiService Extension (Service Layer)

**DailyChallengeService** (`lib/core/services/daily_challenge_service.dart`) — new file:
- `todayDateString` — returns "YYYY-MM-DD" for the current UTC day
- `nextDateString` — returns "YYYY-MM-DD" for the next UTC day
- `timeUntilNextChallenge` — calculates `Duration` until next UTC midnight, clamped to non-negative
- `formatCountdown(Duration)` — formats as "{X}h remaining" or "{X}m remaining" or "Ended — new challenge tomorrow"
- `getOrCreateDailyChallenge(uid)` — main entrypoint: reads `/challenges/YYYY-MM-DD` from Firestore, or if none exists (first user of UTC day), picks a random curated scenario as base, calls `AiService.generateDailyChallenge()`, constructs a `Scenario` from the Gemini output, writes the seed document with `createdAt` and `generatedBy` fields, and returns the challenge
- `hasCompletedTodayChallenge(uid)` — checks `users/{uid}/scenarios/challenge_{date}` for `completed == true`
- `markChallengeCompleted(uid)` — writes `{ completed: true, completedAt: serverTimestamp }` to the user's challenge completion document
- `_loadAllCuratedScenarios()` — loads all scenarios from Firestore's `/scenarios` collection for random base selection

**AiService** (`lib/core/services/ai_service.dart`):
- `generateDailyChallenge(baseScenario)` — Gemini prompt for scenario variation generation:
  - Uses `responseMimeType: 'application/json'` + `responseSchema` for structured JSON output (same pattern as `generateTwistVariation` and `generateScenario`)
  - Temperature 0.9 for creative variation
  - 30-second timeout with `TimeoutException`
  - Returns `Map<String, dynamic>` with title, description, personaName, personaDescription, goalDescription, openingMessage

**Providers** (`lib/core/providers/service_providers.dart`):
- `dailyChallengeServiceProvider` — injects `DailyChallengeService` with `aiServiceProvider`

**Firestore Rules** (`firestore.rules`):
- `/challenges/{date}` — `allow read: if true` (public), `allow create: if request.auth != null` (authenticated users create seed), `allow write: if request.auth != null && request.auth.token.admin == true` (admin-only updates)

### Task 2: DailyChallengeCard Hero Widget

**DailyChallengeCard** (`lib/features/home/widgets/daily_challenge_card.dart`) — new `ConsumerStatefulWidget`:
- **Card container**: white fill, borderRadius 20, 2px left gold border (accentGold), claymorphism dual box-shadow
- **Inner Timer**: `Timer.periodic` at 1-minute interval, stores in member variable, cancelled in `dispose()` (Pitfall 3 prevention)
- **Row 1 — Heading**: "Today's Challenge" (Fredoka 18px 600 textDark) + gold "2x XP" pill badge (accentGold fill, white text 12px 600)
- **Row 2 — Description**: Challenge description (Quicksand 13px 500 textMuted, 2 lines max, overflow ellipsis)
- **Row 3 — Countdown**: Format "{X}h remaining" (Quicksand 12px 600 textMuted; accentCoral if < 1h for urgency); if expired shows "Ended — new challenge tomorrow" in textMuted
- **Row 4a — Not completed**: Full-width "Start Challenge" button (primaryPink background, white text, borderRadius 12) — navigates to `/conversation/{challenge.id}` via `selectedScenarioProvider`
- **Row 4b — Completed**: Gold checkmark icon + "Challenge Complete! +100 XP" (accentGold, not green per UI-SPEC)
- **Loading state**: Skeleton placeholder (white semi-transparent container with gold left border)
- **Error state**: `SizedBox.shrink()` — silently hides on error

**Providers** (`lib/features/home/viewmodels/home_viewmodel.dart`):
- `dailyChallengeProvider` — `FutureProvider<Scenario?>` that loads today's challenge for the current user via `getOrCreateDailyChallenge(uid)`
- `challengeCompletedProvider` — `FutureProvider<bool>` that checks `hasCompletedTodayChallenge(uid)`

### Task 3: Home Dashboard Integration and 2x XP Award Flow

**HomeState** (`lib/features/home/viewmodels/home_viewmodel.dart`):
- New fields: `dailyChallenge` (Scenario?), `challengeCompletedToday` (bool), `alreadyLoadedChallenge` (bool, prevents re-fetch on every build)
- `build()` — loads daily challenge data for authenticated users after base state loading; sets `alreadyLoadedChallenge: true`

**HomeScreen** (`lib/features/home/screens/home_screen.dart`):
- `DailyChallengeCard` widget inserted between `GoalRing` and the "Recommended" section header
- Import added for `daily_challenge_card.dart`

**ConversationViewModel** (`lib/features/conversation/viewmodels/conversation_viewmodel.dart`):
- `isChallenge` getter: `state.value?.scenario?.category == 'daily-challenge'`
- `_triggerGamification()`: after the base 50 XP award, if `isChallenge` is true:
  - Awards bonus 50 XP via `gamification.awardXp(uid, 50)` (total = 50 + 50 = 100 per D-08)
  - Calls `dcService.markChallengeCompleted(uid)` to record completion in Firestore

## Deviations from Plan

None — plan executed exactly as written.

### Design Refinements (within plan scope)
- `DailyChallengeService` constructor simplified — `FirestoreService` dependency removed because the service uses `FirebaseFirestore.instance` directly via its own `_db` field (same pattern as `FirestoreScenarioService`)
- Countdown changes to coral when under 1 hour remaining for visual urgency (extending the plan's design per UI-SPEC urgency hint)

## Verification

| Check | Result |
|-------|--------|
| `flutter analyze` (all changed files) | 0 errors, 0 warnings |
| `DailyChallengeService` created with UTC rotation | PASS |
| `todayDateString` returns UTC YYYY-MM-DD | PASS |
| `timeUntilNextChallenge` calculates UTC midnight delta | PASS |
| `formatCountdown` formats duration correctly | PASS |
| `getOrCreateDailyChallenge()` reads existing Firestore doc | PASS |
| `getOrCreateDailyChallenge()` generates new if missing | PASS |
| `AiService.generateDailyChallenge()` prompt + responseSchema | PASS |
| `dailyChallengeServiceProvider` registered | PASS |
| Firestore rules: `/challenges/{date}` read/create/write permissions | PASS |
| `DailyChallengeCard` widget created with gold left border | PASS |
| "Today's Challenge" heading + gold "2x XP" badge | PASS |
| Countdown timer updates every minute | PASS |
| Timer cancelled in dispose() (no leak) | PASS |
| "Start Challenge" navigates to conversation | PASS |
| Completed state shows gold checkmark + "+100 XP" | PASS |
| Skeleton loading placeholder | PASS |
| `dailyChallengeProvider` created | PASS |
| `challengeCompletedProvider` created | PASS |
| `HomeState.dailyChallenge` field added | PASS |
| `HomeState.challengeCompletedToday` field added | PASS |
| `HomeViewModel.build()` loads challenge for auth users | PASS |
| `DailyChallengeCard` inserted between GoalRing and Recommended | PASS |
| `ConversationViewModel.isChallenge` getter | PASS |
| Bonus 50 XP awarded on challenge completion | PASS |
| `markChallengeCompleted` called on completion | PASS |

## Known Stubs

None. Daily Challenge card renders challenge data from Firestore/Gemini. Completion state relies on real Firestore writes. Countdown timer is live. All integration points are wired end-to-end.

## Threat Flags

| Flag | File | Description |
|------|------|-------------|
| threat_flag: new_firestore_path | firestore.rules | New `/challenges/{date}` path added with public read and authenticated create. Matches plan's threat model T-05-11 (admin-only write, authenticated create). |

No other new security surface introduced beyond the plan's threat model. Challenge content is non-sensitive learning content (T-05-14, accepted). Completion status falsification (T-05-12) is mitigated by Firestore auth rules — client cannot forge writes outside auth scope.

## Self-Check: PASSED

- All created files exist at expected paths
- All 3 task commits present in git log
- `flutter analyze` passes with 0 errors
