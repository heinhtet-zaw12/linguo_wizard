# Requirements: Linguo Wizard

**Defined:** 2026-07-14
**Core Value:** The voice conversation loop — speak naturally to an AI character, get immersive practice, and receive actionable feedback afterward.

## v1 Requirements

### Core Conversation

- [x] **CONV-01**: User can browse and select from curated real-world scenarios
- [x] **CONV-02**: User can filter scenarios by CEFR level (A1–C1)
- [x] **CONV-03**: User enters a free-flow voice conversation with an AI character
- [x] **CONV-04**: AI stays in character throughout the conversation (has a name, personality)
- [x] **CONV-05**: User sees their own voice message bubbles with transcript
- [x] **CONV-06**: User sees AI response bubbles with transcript
- [x] **CONV-07**: Progress indicator at top shows scenario goal

### Feedback

- [x] **FDBK-01**: Post-conversation screen shows full transcript with inline grammar corrections
- [x] **FDBK-02**: Post-conversation screen shows summary score (fluency, grammar, vocabulary)
- [x] **FDBK-03**: User earns XP for completing scenarios

### Onboarding

- [x] **ONBD-01**: Splash screen with claymorphism aesthetic
- [x] **ONBD-02**: User selects target language, CEFR level (A1–C1), and goal (travel/work/exam)

### Platform & Infrastructure

- [x] **PLAT-01**: Works on iOS, Android, and Web
- [x] **PLAT-02**: Guest mode with local-only progress storage
- [x] **PLAT-03**: Device/IP-based daily AI-call rate limiting (server-side)

## v2 Requirements

(None yet — will emerge from v1 validation)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Sign-up/login & cloud sync | Deferred to Phase 2 |
| Streaks, badges, leaderboard | Deferred to Phase 3 |
| Premium gating / monetization | Deferred to Phase 4 |
| Pronunciation scoring (phoneme-level) | Requires paid API, deferred to Phase 4 |
| Real-time conversation | Voice messages, not live phone-call style |
| AI mid-conversation corrections | Post-conversation only to preserve immersion |
| Multiple languages | English only in v1 |
| Offline mode | Requires AI API connection |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| CONV-01 | Phase 1 | ✅ Done |
| CONV-02 | Phase 1 | ✅ Done |
| CONV-03 | Phase 1 | ✅ Done |
| CONV-04 | Phase 1 | ✅ Done |
| CONV-05 | Phase 1 | ✅ Done |
| CONV-06 | Phase 1 | ✅ Done |
| CONV-07 | Phase 2 | ✅ Done |
| FDBK-01 | Phase 2 | ✅ Done |
| FDBK-02 | Phase 2 | ✅ Done |
| FDBK-03 | Phase 2 | ✅ Done |
| ONBD-01 | Phase 1 | ✅ Done |
| ONBD-02 | Phase 2 | ✅ Done |
| PLAT-01 | Phase 1 | ✅ Done |
| PLAT-02 | Phase 2 | ✅ Done |
| PLAT-03 | Phase 2 | ✅ Done |

**Coverage:**

- v1 requirements: 15 total
- Mapped to phases: 15
- Complete: 15/15 ✓
- Unmapped: 0 ✓

---
*Requirements defined: 2026-07-14*
*Last updated: 2026-07-18 after Phase 2 completion*
