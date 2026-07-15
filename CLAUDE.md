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
- **TTS**: `flutter_tts` package (device-native, free); later upgrade path: ElevenLabs / Google Cloud WaveNet
- **Pronunciation scoring** (Premium, later phase): Azure Speech or Speechace (paid, phoneme-level)

## Design Style
Theme: **3D Claymorphism** (soft, rounded, matte clay-style 3D character illustration + minimal pastel UI)


## Architecture
MVVM,Feature First folders


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

### Phase 4 — Premium / Monetization
- Premium gating: unlimited daily conversations, advanced scenarios, ad-free
- Pronunciation-level feedback (paid API integration)
- "Today's twist" — Gemini-generated scenario variation for repeat-play value

## Engineering Notes
- Keep AI system prompts (persona, scenario goal, redirect logic) server-side or in a config layer, not hardcoded per-screen — scenarios will grow over time.
- Guest-mode data model should be structured so it can migrate cleanly into a Firestore user doc on sign-up (avoid two separate schemas).
- Rate-limit AI calls per device/IP for guests and per-user for free tier; premium tier gets higher/unlimited quota.
- CEFR level filter lives inside Scenario Selection screen as a chip row — no separate level-selection screen.
