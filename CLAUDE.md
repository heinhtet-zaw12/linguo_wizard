# Conversational Language Learning App — Project Brief

## Product Concept
Flutter mobile app for practicing spoken English through simulated real-world
dialogues with an AI conversation partner. Users are dropped into simulated real-world dialogue from session one. Freemium model, retention/daily engagement focused.

## Tech Stack
- **Frontend**: Flutter (cross-platform)
- **State management**: riverpod
- **Backend/DB**: Firebase (Auth + Firestore)
- **AI Conversation Engine**: Gemini API (free tier) or Groq API
- **STT**: `speech_to_text` package (device-native, free)
- **TTS**: `flutter_tts` package (device-native, free)
- **Pronunciation scoring**: Not planned — all paid APIs avoided to keep the app 100% free

## Design Style
Theme: **3D Claymorphism** (soft, rounded, matte clay-style 3D character illustration + minimal pastel UI)


## Architecture

**Pattern:** MVVM (Model-View-ViewModel) + Feature-first folder structure

### Layer Responsibilities

| Layer | Responsibility | Location |
|---|---|---|
| **Model** | Data classes, JSON serialization | `features/*/models/` |
| **ViewModel** | Business logic, state management, service orchestration. Extends `StateNotifier`. Owns the state machine and coordinates services (STT, TTS, AI). Never imports widgets. | `features/*/viewmodels/` |
| **View** | Pure UI rendering. Watches ViewModel state via Riverpod providers. Forwards user actions to ViewModel. Zero business logic. | `features/*/screens/`, `features/*/widgets/` |
| **Service** | Wrappers around external packages (Gemini, STT, TTS). Stateless, injectable, testable. | `core/services/` |

### Rules
- Screens (Views) NEVER directly call services — they go through the ViewModel
- ViewModels NEVER import Flutter widgets or UI packages
- Models are plain Dart classes with no framework dependencies
- Services are injected into ViewModels for testability
- Each feature owns its own ViewModel, models, screens, and widgets


## Build Phases

### Phase 1 — Core Loop (MVP, no auth)
- Splash screen
- Onboarding (target language, CEFR level A1–C1, goal: travel/work/exam) — follow theme + mascot per Design Style section
- Scenario Selection screen (curated fixed scenarios + CEFR filter chips)
- Conversation screen — **voice-message based, not free-typing chat**:
  - User speaks via mic → sent as a voice message bubble (own side)
  - AI replies as a voice message bubble (STT input, response generated, then TTS'd into a VM) with the transcript text shown underneath the VM bubble
  - Top progress indicator shows current scenario goal
  - Task-based goal tracking (goal achieved/partial evaluation)
- Feedback & Score screen (XP summary, grammar correction side-by-side)
- Local-only progress storage (guest mode)
- Device ID/IP-based daily AI-call limit (abuse prevention) — **implement rate limiting server-side or via Cloud Function, never trust client**

### Phase 2 — Accounts & Cloud Sync
- Sign up / login (email, Google, continue-as-guest)
- Home Dashboard (logged-in): streak, daily goal ring, recommended scenario cards, full cloud sync
- Home Dashboard (guest): same cards, "sign up to save progress" banner, soft paywall after N scenarios, leaderboard/social hidden until account created

### Phase 3 — Gamification & Retention
- Streak count + flame icon, XP, badges
- Spaced repetition (SRS): resurface previously-missed vocab/phrases in later scenarios
- Mistake pattern dashboard (time-series)

### Phase 5 — Polish & Custom Scenarios
- Firestore-backed scenario catalog (30+ curated scenarios with categories, search, pagination)
- AI-generated custom scenarios (unlimited, free)
- Today's Twist — replay completed scenarios with progressive AI-generated variations
- Daily Challenge — fresh AI-generated scenario daily with 2x XP bonus

## Engineering Notes
- Keep AI system prompts (persona, scenario goal, redirect logic) server-side or in a config layer, not hardcoded per-screen — scenarios will grow over time.
- Guest-mode data model should be structured so it can migrate cleanly into a Firestore user doc on sign-up (avoid two separate schemas).
- Rate-limit AI calls per device/IP for guests and per-user for free tier.
- CEFR level filter lives inside Scenario Selection screen as a chip row — no separate level-selection screen.
