---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: Ready to plan
stopped_at: Phase 5 context gathered
last_updated: "2026-07-23T08:06:25.316Z"
progress:
  total_phases: 5
  completed_phases: 4
  total_plans: 12
  completed_plans: 10
  percent: 80
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-07-14)

**Core value:** The voice conversation loop — speak naturally to an AI character, get immersive practice, and receive actionable feedback afterward.
**Current focus:** Phase 05 — premium-&-polish

## Progress

| Phase | Status | Progress |
|-------|--------|----------|
| Phase 1 | **Complete** | 100% |
| Phase 2 | **Complete** | 100% |
| Phase 3 | **Complete** | 100% |
| Phase 4 | **Complete** | 100% |
| Phase 5 | Ready to plan | 0% |

## Phase 1 — Complete

- [x] Splash screen with 3D claymorphism animation
- [x] Scenario selection screen with 2-column grid of curated scenario cards
- [x] CEFR filter chips (All, A1, A2, B1, B2, C1) on scenario selection
- [x] Conversation screen with full voice message loop (STT → AI → TTS)
- [x] Voice message bubbles (user: pink/right, AI: white/left, with transcript)
- [x] Animated mic button (idle/recording/processing/speaking states)
- [x] AI persona system (Gemini API with scenario-based system instructions)
- [x] Core services: SttService, TtsService, AiService
- [x] Data models: Message, Scenario
- [x] MVVM architecture implemented (ViewModels extract business logic from screens)
- [x] Environment config via .env file (bundled as Flutter asset)
- [x] Human verification passed (UAT resolved 2026-07-18)

## Phase 2 — Complete

- [x] Onboarding per-step persistence (crash-safe, SharedPreferences)
- [x] Rate limiting (device fingerprint, 10 calls/day sliding window)
- [x] End Conversation button with evaluation flow trigger
- [x] EvaluationService (Gemini structured JSON with responseSchema)
- [x] ScoreData model (overall/fluency/grammar/vocabulary scores, grammar corrections)
- [x] FeedbackScreen (score circle, breakdown, XP badge, grammar corrections, Done button)
- [x] Rate limit enforcement at conversation start (ViewModel-level check)
- [x] Navigation flow: conversation → feedback → scenarios

## Phase 3 — Complete

- [x] Firebase foundation: dependencies, AuthService, FirestoreService, auth state providers
- [x] Auth UI and Home dashboard: login, sign-up, forgot password, home screen, navigation
- [x] Cloud sync integration: guest migration, Firestore sync, user-based rate limiting
- [x] Human verification passed (UAT resolved 2026-07-21)

## Phase 4 — Complete

- [x] GoRouter navigation shell: bottom nav, route guards, stateful tabs
- [x] Gamification data layer: config files, models, services, Firestore extension
- [x] UI screens and integration: Progress, Leaderboard, Pre-Scenario Review, Badge Popup, ViewModel wiring
- [x] Human verification passed (UAT resolved 2026-07-21)

## Architecture Decision

**MVVM (Model-View-ViewModel)** with Feature-First folder structure was implemented in Phase 1:

```
View (Screen)  → watches state, forwards user actions
    ↓
ViewModel       → owns business logic, state machine
    ↓
Service         → wraps STT/TTS/AI packages
    ↓
Model           → data classes (Message, Scenario)
```

Screens are pure UI layers. ViewModels (StateNotifiers) own all orchestration logic. Services are injectable wrappers around external packages.

## Recent Activity

- 2026-07-14: Project initialized, requirements defined, roadmap created
- 2026-07-15: Phase 1 plans 01 & 02 executed — splash, scenario selection, conversation screen built
- 2026-07-15: MVVM architecture refactored, CEFR filter chips added
- 2026-07-18: Phase 1 marked complete, human verification passed
- 2026-07-18: Roadmap restructured — missing MVP items moved to new Phase 2
- 2026-07-18: Phase 2 complete — feedback loop, rate limiting, onboarding persistence all done
- 2026-07-21: Phase 3 complete — Firebase Auth, Firestore, cloud sync
- 2026-07-21: Phase 4 complete — gamification (streaks, XP, badges, SRS, leaderboard, progress)
- 2026-07-21: Phase 4 UAT passed — 13/13 automated verification tests
- 2026-07-22: **Enhancement session** — Conversation voice message UI overhaul + history persistence:
  - Audio-first bubble with Play/Pause controls for AI messages
  - Collapsible transcript ("Show Transcript"/"Hide Transcript" toggle)
  - New `ConversationStorageService` (SharedPreferences for guests, Firestore for auth users)
  - Save/discard dialog on exit, New Chat button to reset, Resume prompt on re-entry
  - See `.planning/tmp/conversation-update-plan.md` for full scope

---
*Last updated: 2026-07-22 after enhancement session*

## Session

**Last session:** 2026-07-23T08:06:25.312Z
**Stopped at:** Phase 5 context gathered
**Resume file:** .planning/phases/05-premium-and-polish/05-CONTEXT.md

## Remaining Work

The following were scoped but not implemented (flagged as Future Roadmap):

- **Myanmar (Burmese) language UI** — localization support in conversation view
- **Dynamic transcript translation** — inline option to translate/switch transcripts to Myanmar text
