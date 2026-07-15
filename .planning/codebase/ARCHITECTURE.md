<!-- refreshed: 2026-07-14 -->
# Architecture

**Analysis Date:** 2026-07-14

## System Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                      Flutter App Layer                       │
│                  lib/ (MVVM + Feature-First)                 │
├──────────────────┬──────────────────┬───────────────────────┤
│   View Layer     │   ViewModel      │   Model Layer         │
│   (Screens/     │   (Providers/    │   (Data classes/      │
│    Widgets)     │    State)        │    Services)          │
└────────┬─────────┴────────┬─────────┴──────────┬────────────┘
         │                  │                     │
         ▼                  ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│                  Service / Repository Layer                  │
│              (Firebase, AI APIs, Device Services)            │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│                   External Backends                          │
│         (Firebase Auth/Firestore, Gemini/Groq,               │
│          speech_to_text, flutter_tts)                        │
└─────────────────────────────────────────────────────────────┘
```

## Current State

**Stage:** Phase 1 ~70% — MVVM architecture implemented, core voice loop working.

**Entry point:** `lib/main.dart` — loads .env, wraps in ProviderScope, sets up routes.

**Implemented features:**
- Splash screen (3D claymorphism animation)
- Scenario selection (2-column grid, CEFR filter chips)
- Conversation screen (voice message loop: STT → AI → TTS)
- Core services (SttService, TtsService, AiService)
- Data models (Message, Scenario)
- MVVM architecture (ViewModels extract business logic from screens)

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| `LinguoWizardApp` | Root widget, theme, routing | `lib/main.dart` |
| `SplashScreen` | Animated entry, navigates to scenarios | `lib/features/splash/splash_screen.dart` |
| `ScenarioSelectionViewModel` | Loads scenarios, manages CEFR filter | `lib/features/scenario_selection/viewmodels/scenario_selection_viewmodel.dart` |
| `ScenarioSelectionScreen` | Displays scenario grid, filter chips | `lib/features/scenario_selection/screens/scenario_selection_screen.dart` |
| `ScenarioCard` | Individual scenario card widget | `lib/features/scenario_selection/widgets/scenario_card.dart` |
| `ConversationViewModel` | Voice loop state machine, STT/TTS/AI orchestration | `lib/features/conversation/viewmodels/conversation_viewmodel.dart` |
| `ConversationScreen` | Displays conversation UI, forwards actions to ViewModel | `lib/features/conversation/screens/conversation_screen.dart` |
| `VoiceMessageBubble` | Voice message bubble (user/AI) with transcript | `lib/features/conversation/widgets/voice_message_bubble.dart` |
| `MicButton` | Animated mic button reflecting loop state | `lib/features/conversation/widgets/mic_button.dart` |
| `SttService` | Speech-to-text wrapper | `lib/core/services/stt_service.dart` |
| `TtsService` | Text-to-speech wrapper | `lib/core/services/tts_service.dart` |
| `AiService` | Gemini API chat wrapper | `lib/core/services/ai_service.dart` |
| `AppConfig` | Environment config, constants | `lib/core/config/app_config.dart` |

**Planned components (not yet implemented):**

| Component | Responsibility | Planned Location |
|-----------|----------------|------------------|
| Onboarding | User preference setup | `lib/features/onboarding/` |
| Feedback & Score | XP, grammar summary | `lib/features/feedback/` |
| Home Dashboard | Streaks, goals, recommendations | `lib/features/home/` |

## Pattern Overview

**Overall:** MVVM (Model-View-ViewModel) with Feature-First organization

**Key Characteristics:**
- Views (Screens) are stateless widgets that delegate state to ViewModels
- ViewModels expose state via Riverpod providers (planned)
- Models are plain data classes (no business logic)
- Feature-first folder grouping: each feature owns its own views, viewmodels, and models
- Shared infrastructure (services, utilities, theme) lives in `lib/core/` or `lib/shared/`

**MVVM Flow:**
1. View listens to ViewModel via Riverpod provider
2. ViewModel handles business logic and calls services/repositories
3. Services interact with external APIs (Firebase, Gemini, device STT/TTS)
4. State changes propagate back to View via provider updates

## Layers

**Views (Screens & Widgets):**
- Purpose: UI rendering only — no business logic
- Location: `lib/features/{feature}/views/`
- Contains: StatelessWidget/StatelessWidget screen widgets, reusable UI components
- Depends on: ViewModels (via Riverpod providers), Theme
- Used by: Flutter framework (routing/navigation)

**ViewModels (State & Logic):**
- Purpose: Business logic, state management, orchestration
- Location: `lib/features/{feature}/viewmodels/`
- Contains: Riverpod providers/notifiers, state classes
- Depends on: Models, Services, Repositories
- Used by: Views (via provider listeners)

**Models (Data):**
- Purpose: Data representation, serialization
- Location: `lib/features/{feature}/models/`
- Contains: Data classes, enums, DTOs
- Depends on: Nothing (pure Dart)
- Used by: ViewModels, Services

**Services (Infrastructure):**
- Purpose: External API communication, device capabilities
- Location: `lib/core/services/` or `lib/shared/services/`
- Contains: Firebase client wrappers, AI API clients, STT/TTS wrappers
- Depends on: External packages (firebase, speech_to_text, flutter_tts, http)
- Used by: ViewModels, Repositories

**Repositories (Data Access):**
- Purpose: Data source abstraction, caching
- Location: `lib/core/repositories/`
- Contains: Firestore operations, local storage, data migration logic
- Depends on: Services, Models
- Used by: ViewModels

## Data Flow

### Primary Request Path (Conversation Flow)

1. User taps mic button on Conversation Screen (`lib/features/conversation/views/`)
2. ViewModel activates `speech_to_text` service to record audio
3. Service returns transcribed text → ViewModel sends to AI API (Gemini/Groq)
4. AI response text → ViewModel calls `flutter_tts` to synthesize audio
5. Voice message bubble rendered with transcript text beneath
6. Goal tracking updated in ViewModel state → View reflects progress

### Onboarding Flow

1. Splash screen loads → checks for existing guest/profile data
2. Onboarding screen collects: target language, CEFR level (A1-C1), goal (travel/work/exam)
3. Preferences saved to local storage (guest) or Firestore (authenticated user)
4. Scenario Selection filtered by saved CEFR level

### Authentication Flow (Phase 2)

1. User chooses: email, Google, or continue-as-guest
2. Firebase Auth handles credential validation
3. Guest data migrates to Firestore user document on sign-up
4. Cloud sync activates for progress, streaks, and scenarios

## State Management

**Framework:** Riverpod (installed, in use)

**Provider Types in Use:**
- `StateNotifierProvider` — ViewModel state (ConversationViewModel, ScenarioSelectionViewModel)
- `StateProvider` — simple mutable state (selectedScenarioProvider)
- `FutureProvider` — async data loading (scenarios, user profile — planned)

**Provider Types Planned:**
- `StreamProvider` — for real-time data (Firestore listener for streaks)

**State Scope:**
- Conversation state: scoped to conversation session
- User progress: app-level, persisted to local storage or Firestore
- Theme/settings: app-level provider

## Key Abstractions

**Scenario:**
- Purpose: Represents a real-world conversation scenario (e.g., "Ordering Coffee", "Job Interview")
- Examples: To be created in `lib/features/scenarios/models/scenario.dart`
- Pattern: Immutable data class with CEFR level, category, dialogue tree

**VoiceMessage:**
- Purpose: Represents a single voice turn in conversation (user or AI)
- Examples: To be created in `lib/features/conversation/models/voice_message.dart`
- Pattern: Contains audio data reference, transcript text, speaker, timestamp

**UserProgress:**
- Purpose: Tracks XP, streaks, completed scenarios, mistake patterns
- Examples: To be created in `lib/features/home/models/user_progress.dart`
- Pattern: Serializable to both local storage and Firestore (schema-compatible)

**CEFR Level:**
- Purpose: Language proficiency classification (A1, A2, B1, B2, C1)
- Examples: Enum in shared models
- Pattern: Used for filtering scenarios and adaptive difficulty

## Entry Points

**App Entry:**
- Location: `lib/main.dart`
- Triggers: Flutter engine launch
- Responsibilities: Initializes app, sets up providers, launches MaterialApp

**Planned Entry Points:**

| Entry Point | Location | Purpose |
|------------|----------|---------|
| Main | `lib/main.dart` | App bootstrap, provider scope |
| Splash | `lib/features/splash/views/splash_screen.dart` | Initial loading, routing decision |
| Onboarding | `lib/features/onboarding/views/` | First-run user setup |

## Architectural Constraints

- **Threading:** Dart's single-threaded event loop; isolate used only for heavy computation (AI response parsing, audio processing if needed)
- **State management:** All state flows through Riverpod; no direct setState() in feature code after Phase 1
- **AI prompt management:** System prompts and scenario configuration must live in config layer or server, never hardcoded in screen widgets
- **Guest data model:** Must be structurally identical to Firestore user document to enable clean migration on sign-up
- **Rate limiting:** AI call limits enforced server-side (Cloud Function) or via secure device fingerprint; never trust client-side counters alone
- **Voice-first interaction:** Conversation is voice-message-based, not text chat; UI reflects voice message bubbles with transcripts

## Anti-Patterns

### Business Logic in View Layer

**What happens:** Network calls, data transformation, or state mutation directly inside widget build methods or setState callbacks
**Why it's wrong:** Makes code untestable, tightly couples UI to backend, violates MVVM
**Do this instead:** All logic belongs in ViewModel (Riverpod provider); View only reads state and dispatches user actions. Reference: any future screen in `lib/features/*/views/`

### Hardcoded AI Prompts

**What happens:** Gemini/Groq system prompts written as string literals inside conversation screen widgets
**Why it's wrong:** Scenarios will grow; prompts need versioning, A/B testing, and server-side updates without app release
**Do this instead:** Store prompts in `lib/core/config/` or fetch from Firebase Remote Config / Firestore; ViewModel references config by scenario ID

### Client-Side-Only Rate Limiting

**What happens:** Daily AI call limit tracked in SharedPreferences or local state
**Why it's wrong:** Users can bypass by clearing storage, modifying app state, or using different devices
**Do this instead:** Enforce rate limits server-side via Firebase Cloud Functions; client caches quota for UX but server is source of truth

### Two Separate Data Schemas (Guest vs Authenticated)

**What happens:** Guest mode uses one data model, authenticated users use a different Firestore structure
**Why it's wrong:** Migration on sign-up becomes complex, data loss risk, dual maintenance burden
**Do this instead:** Design guest data model to be a subset of Firestore user document; local storage mirrors Firestore schema exactly

## Error Handling

**Strategy:** Layered error handling — services catch and wrap exceptions, ViewModels handle business errors, Views display user-friendly messages

**Patterns:**
- Service layer catches API/SDK exceptions, wraps in typed exceptions (`ApiException`, `NetworkException`, `RateLimitException`)
- ViewModels expose error state via provider (e.g., `AsyncValue.error` or dedicated error state field)
- Views pattern-match on error state to show retry UI, snackbar, or fallback
- Global error boundary at MaterialApp level catches unhandled exceptions

## Cross-Cutting Concerns

**Logging:** Use `logging` package with feature-tagged loggers; no print() statements in production code

**Validation:** CEFR level and user input validated at ViewModel layer before service calls; UI shows inline validation errors

**Authentication:** Firebase Auth with three flows (email/password, Google Sign-In, anonymous); auth state exposed via Riverpod StreamProvider wrapping `AuthStateChanges()`

**Theme & Styling:** 3D Claymorphism theme (pastel colors, rounded shapes, soft shadows); theme defined in `lib/core/theme/` and provided via MaterialApp theme; consistent spacing/typography tokens

**Navigation:** Named routes initially; consider go_router package for deep linking and route guards (auth check, onboarding complete check)

---

*Architecture analysis: 2026-07-14*
