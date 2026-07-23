# Linguo Wizard

## What This Is

A Flutter mobile/web app for practicing spoken English through simulated real-world dialogues with an AI conversation partner. Users are dropped into character-driven scenarios (ordering coffee, checking into a hotel, job interviews) where they speak freely and receive post-conversation feedback with transcript corrections and scores. Designed for casual learners who want low-pressure, fun, gamified speaking practice.

## Core Value

The voice conversation loop — speak naturally to an AI character, get immersive practice, and receive actionable feedback afterward. Everything else supports this.

## Requirements

### Validated

- ✓ Streak count, XP, badges — Phase 4
- ✓ Spaced repetition (SRS) for missed vocab/phrases — Phase 4
- ✓ Mistake pattern dashboard (summary metrics) — Phase 4
- ✓ Leaderboard/social features — Phase 4

### Active

- [x] User can browse and select from curated real-world scenarios (with CEFR level filter chips)
- [x] User enters a free-flow voice conversation with an AI character (speaks via mic, AI responds via TTS)
- [x] AI stays in character throughout the conversation (has a name, personality, context)
- [ ] AI adapts to user's level — simple prompts for beginners, natural speech for advanced
- [x] User sees their own voice message bubbles (with transcript) and AI response bubbles (with transcript)
- [x] Progress indicator at top shows scenario goal (e.g., "Order your coffee")
- [x] Post-conversation screen shows full transcript with inline grammar corrections
- [x] Post-conversation screen shows summary score (fluency, grammar, vocabulary)
- [x] User earns XP for completing scenarios
- [x] Works on iOS, Android, and Web (Flutter cross-platform)
- [x] Splash screen with claymorphism aesthetic
- [x] Onboarding: select target language, CEFR level (A1–C1), goal (travel/work/exam)
- [x] Scenario selection screen with CEFR filter chips
- [x] Guest mode with local-only progress storage
- [x] Device/IP-based daily AI-call rate limiting (server-side, not client-side)

### Out of Scope

- **Premium gating / monetization** — not planned, app is 100% free
- **Pronunciation scoring (phoneme-level)** — requires paid API (Azure/Speechace), not planned
- **Real-time conversation** — voice messages, not live phone-call style
- **AI mid-conversation corrections** — feedback is post-conversation only to preserve immersion
- **Multiple languages** — English only in v1
- **Offline mode** — requires AI API connection

## Context

- **Tech stack**: Flutter (cross-platform: iOS, Android, Web), Riverpod state management, Firebase (Auth + Firestore), Gemini/Groq API for AI conversation, `speech_to_text` for STT, `flutter_tts` for TTS
- **Design theme**: 3D Claymorphism — soft, rounded, matte clay-style 3D character illustrations with minimal pastel UI
- **Architecture**: MVVM, feature-first folder structure
- **Existing code**: Initial Flutter project scaffold exists with basic structure
- **AI system prompts** (persona, scenario goal, redirect logic) should live server-side or in a config layer, not hardcoded per-screen — scenarios will grow over time
- **Guest-mode data model** must be structured to migrate cleanly into a Firestore user doc on sign-up
- **Rate limiting** must be server-side (Cloud Function), never client-side

## Constraints

- **Tech stack**: Flutter cross-platform (iOS, Android, Web) — non-negotiable
- **AI API**: Free tier only (Gemini or Groq) for v1 — budget constraint
- **STT/TTS**: Device-native packages (`speech_to_text`, `flutter_tts`) — free, no paid APIs
- **Guest mode**: No auth required for v1 — local storage only
- **Rate limiting**: Server-side enforcement per device/IP for guests
- **Web compatibility**: STT/TTS must work on web (check package web support)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Free-flow dialogue over guided repetition | More immersive, matches casual learner motivation | ✅ Validated — core loop works end-to-end |
| Post-conversation feedback (not mid-conversation) | Preserves immersion, keeps AI in character | ✅ Validated — Gemini evaluation with structured JSON |
| AI as named characters | Creates emotional connection, more engaging than neutral guide | ✅ Validated — 3 personas (cafe, airport, interview) |
| Voice messages not free-typing chat | Core product differentiator — speaking practice, not typing | ✅ Validated — STT→AI→TTS pipeline works |
| Web support alongside mobile | Broader reach, Flutter makes it feasible | ✅ Implemented — Flutter cross-platform |
| Config-driven badge system | New badges added via config list without code changes | ✅ Implemented — 8 badges, extensible |
| SM-2 algorithm for SRS | Industry-standard spaced repetition, battle-tested | ✅ Implemented — ease factor + interval progression |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-07-21 after Phase 4 completion*
