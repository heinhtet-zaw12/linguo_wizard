# Roadmap: Linguo Wizard

**Mode:** horizontal-layers
**Phases:** 4
**Requirements mapped:** 15/15 ✓
**Architecture:** MVVM (Model-View-ViewModel) + Feature-First

---

## Phase 1: Foundation & Core Voice Loop ✅ ~70%

**Goal:** Build MVVM architecture, foundational services, and a working voice conversation loop end-to-end
**Success Criteria:**

1. ✅ MVVM architecture established — ViewModels own business logic, screens are pure UI
2. ✅ User can speak into mic and see their voice message bubble with transcript
3. ✅ User can receive AI response as voice message bubble with transcript
4. ✅ AI responds in character with appropriate persona (Gemini API)
5. ✅ Scenario selection works with 3 curated scenarios
6. ✅ CEFR level filter chips on scenario selection screen
7. ⬜ Onboarding flow collects language, CEFR level, and goal
8. ⬜ Goal progress indicator shows scenario goal during conversation
9. ⬜ Task-based goal evaluation (AI assesses completion)
10. ⬜ Feedback & Score screen (XP, grammar corrections)
11. ⬜ Local progress storage (guest mode)
12. ⬜ Rate limiting (device/IP based)

**Requirements:** CONV-01 ✅, CONV-02 ✅, CONV-03 ✅, CONV-04 ✅, CONV-05 ✅, CONV-06 ✅, CONV-07 ⬜, ONBD-01 ⬜, ONBD-02 ⬜, PLAT-01 ✅

---

## Phase 2: Accounts & Cloud Sync

**Goal:** Add authentication, cloud sync, and home dashboard
**Success Criteria:**

1. Sign up / login (email, Google, continue-as-guest)
2. Home Dashboard with streak, daily goal ring, recommended scenarios
3. Guest mode "sign up to save progress" banner
4. Full Firestore cloud sync for progress data
5. Guest-to-authenticated data migration

**Requirements:** PLAT-02 (partial)

**Depends on:** Phase 1 complete (onboarding, local storage, rate limiting)

---

## Phase 3: Gamification & Retention

**Goal:** Add engagement mechanics and learning intelligence
**Success Criteria:**

1. Streak count + flame icon, XP, badges
2. Spaced repetition (SRS) for missed vocab/phrases
3. Mistake pattern dashboard (time-series)
4. Leaderboard/social features (requires account)

**Requirements:** FDBK-01, FDBK-02, FDBK-03

---

## Phase 4: Premium & Polish

**Goal:** Monetization, pronunciation scoring, production polish
**Success Criteria:**

1. Premium gating: unlimited conversations, advanced scenarios, ad-free
2. Pronunciation-level feedback (Azure Speech / Speechace)
3. "Today's twist" — Gemini-generated scenario variation
4. Cross-platform polish (iOS, Android, Web)
5. All edge cases handled (network errors, mic permissions, etc.)

**Requirements:** PLAT-03

---

*Last updated: 2026-07-15 after MVVM refactor and Phase 1 progress*
