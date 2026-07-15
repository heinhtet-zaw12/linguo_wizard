---
phase: 01-foundation-core-voice-loop
plan: 01
subsystem: ui
tags: [flutter, riverpod, speech_to_text, flutter_tts, google_generative_ai, gemini]

# Dependency graph
requires: []
provides:
  - Core services layer (STT, TTS, AI) ready for conversation screen
  - Data models (Message, Scenario) for conversation flow
  - Scenario selection UI with 3 curated scenarios
  - Riverpod state management and routing foundation
affects: [01-02-conversation-screen, 01-03-feedback-screen]

# Tech tracking
tech-stack:
  added: [flutter_riverpod, speech_to_text, flutter_tts, google_generative_ai, shared_preferences, device_info_plus, uuid, path_provider]
  patterns: [MVVM feature-first, ProviderScope, FutureProvider for asset loading, StateProvider for selection]

key-files:
  created:
    - lib/core/config/app_config.dart
    - lib/core/services/stt_service.dart
    - lib/core/services/tts_service.dart
    - lib/core/services/ai_service.dart
    - lib/features/conversation/models/message.dart
    - lib/features/conversation/models/scenario.dart
    - lib/features/scenario_selection/providers/scenario_provider.dart
    - lib/features/scenario_selection/screens/scenario_selection_screen.dart
    - lib/features/scenario_selection/widgets/scenario_card.dart
    - assets/data/scenarios/cafe_ordering.json
    - assets/data/scenarios/job_interview.json
    - assets/data/scenarios/airport_navigation.json
  modified:
    - pubspec.yaml
    - lib/main.dart

key-decisions:
  - "Used SpeechListenOptions (v7 API) instead of deprecated listen() parameters"
  - "Bundled scenario data as JSON assets for Phase 1 (no auth yet), Firebase in Phase 2"
  - "Gemini API key via --dart-define=API_KEY, never hardcoded"

patterns-established:
  - "Service wrapper pattern: STT/TTS/AI services wrap packages in clean async interfaces"
  - "Scenario data: JSON assets loaded via rootBundle into FutureProvider"
  - "Navigation: named routes with pushReplacementNamed from splash"

requirements-completed: [CONV-01, CONV-03, CONV-04, PLAT-01]

coverage:
  - id: D1
    description: "Core services (STT, TTS, AI) with correct interfaces"
    requirement: CONV-03
    verification:
      - kind: unit
        ref: "dart analyze lib/core/services/ — 0 errors"
        status: pass
    human_judgment: false
  - id: D2
    description: "Scenario data models with fromJson factory"
    requirement: CONV-01
    verification:
      - kind: unit
        ref: "dart analyze lib/features/conversation/models/ — 0 errors"
        status: pass
    human_judgment: false
  - id: D3
    description: "Scenario selection screen with 3 curated cards in grid"
    requirement: CONV-01
    verification:
      - kind: manual_procedural
        ref: "Launch app, verify splash navigates to scenario grid with 3 cards"
        status: unknown
    human_judgment: true
    rationale: "Visual UI verification requires manual check on device/simulator"
  - id: D4
    description: "Riverpod ProviderScope wrapping app with named routes"
    requirement: PLAT-01
    verification:
      - kind: unit
        ref: "dart analyze lib/main.dart — 0 errors"
        status: pass
    human_judgment: false

duration: 6min
completed: 2026-07-15
status: complete
---

# Phase 1 Plan 1: Foundation & Core Services Summary

**Core services layer (STT/TTS/AI), data models, and scenario selection UI with 3 curated cards — ready for conversation screen wiring**

## Performance

- **Duration:** 6 min
- **Started:** 2026-07-15T13:18:41Z
- **Completed:** 2026-07-15T13:24:59Z
- **Tasks:** 3
- **Files modified:** 14

## Accomplishments
- Installed all 8 dependencies (riverpod, speech_to_text, flutter_tts, google_generative_ai, shared_preferences, device_info_plus, uuid, path_provider)
- Created STT, TTS, and AI service wrappers with clean async interfaces
- Created Message and Scenario data models with serialization
- Built scenario selection screen with 3 curated cards (cafe, job interview, airport)
- Wired splash-to-scenario navigation with Riverpod ProviderScope

## Task Commits

Each task was committed atomically:

1. **Task 1: Install Dependencies and Create Core Infrastructure** - `409fcde` (feat)
2. **Task 2: Create Scenario Data, Provider, and Selection Screen** - `99176f5` (feat)
3. **Task 3: Wire Splash Navigation and Wrap App in Riverpod** - `97b20b8` (feat)

## Files Created/Modified
- `lib/core/config/app_config.dart` - AppConfig with Gemini API key, model, and STT/TTS timeouts
- `lib/core/services/stt_service.dart` - SttService wrapping speech_to_text with SpeechListenOptions (v7 API)
- `lib/core/services/tts_service.dart` - TtsService wrapping flutter_tts with awaitSpeakCompletion
- `lib/core/services/ai_service.dart` - AiService wrapping google_generative_ai with persona system instruction
- `lib/features/conversation/models/message.dart` - MessageSender enum and Message class with auto-generated ID
- `lib/features/conversation/models/scenario.dart` - Scenario class with fromJson factory
- `lib/features/scenario_selection/providers/scenario_provider.dart` - scenariosProvider (FutureProvider) and selectedScenarioProvider
- `lib/features/scenario_selection/screens/scenario_selection_screen.dart` - ConsumerWidget with 2-column GridView
- `lib/features/scenario_selection/widgets/scenario_card.dart` - ScenarioCard with claymorphism styling, CEFR badge, persona hint
- `assets/data/scenarios/cafe_ordering.json` - Cafe ordering scenario (A2, travel)
- `assets/data/scenarios/job_interview.json` - Job interview scenario (B1, work)
- `assets/data/scenarios/airport_navigation.json` - Airport navigation scenario (A1, travel)
- `pubspec.yaml` - Added 8 dependencies and assets/data/scenarios/ path
- `lib/main.dart` - Wrapped in ProviderScope, added named routes (/, /scenarios, /conversation)

## Decisions Made
- Used SpeechListenOptions (v7 API) with listenFor/pauseFor/localeId fields instead of deprecated listen() parameters
- Bundled scenario data as JSON assets for Phase 1 (no auth/Firebase yet), plan to migrate to Firestore in Phase 2
- Gemini API key injected via --dart-define=API_KEY at build time, never hardcoded in source

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Updated speech_to_text version constraint from ^6.8.0 to ^7.4.0**
- **Found during:** Task 1 (Install dependencies)
- **Issue:** speech_to_text ^6.8.0 does not exist on pub.dev; resolved to 7.4.0
- **Fix:** Used `flutter pub add speech_to_text` to resolve correct version, updated pubspec.yaml
- **Files modified:** pubspec.yaml
- **Verification:** flutter pub get succeeds, dart analyze clean
- **Committed in:** 409fcde (Task 1 commit)

**2. [Rule 1 - Bug] Fixed deprecated STT API usage**
- **Found during:** Task 1 (Verify step)
- **Issue:** speech_to_text 7.4.0 deprecated listenFor/pauseFor/localeId as top-level listen() params — must use SpeechListenOptions
- **Fix:** Moved listenFor, pauseFor, localeId into SpeechListenOptions constructor, removed unused speech_recognition_result.dart import
- **Files modified:** lib/core/services/stt_service.dart
- **Verification:** dart analyze lib/core/ — 0 errors
- **Committed in:** 409fcde (Task 1 commit)

---

**Total deviations:** 2 auto-fixed (1 blocking version mismatch, 1 deprecated API usage)
**Impact on plan:** Both fixes necessary for compilation. No scope creep — stayed within plan file list.

## Issues Encountered
None beyond the auto-fixed deviations above.

## User Setup Required
None - no external service configuration required for Phase 1 foundation.

## Next Phase Readiness
- Core services (STT, TTS, AI) ready to be wired into conversation screen
- Scenario data loading and selection flow operational
- Riverpod infrastructure in place for conversation state management
- Next plan (01-02) can build conversation screen using these services and models

---
*Phase: 01-foundation-core-voice-loop*
*Completed: 2026-07-15*

## Self-Check: PASSED

All 12 created files verified present. All 3 task commits verified in git history. SUMMARY.md verified on disk.
