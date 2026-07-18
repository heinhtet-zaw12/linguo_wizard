# Roadmap: Linguo Wizard

**Mode:** horizontal-layers
**Phases:** 5
**Requirements mapped:** 15/15 ✓
**Architecture:** MVVM (Model-View-ViewModel) + Feature-First

---

## Phase 1: Foundation & Core Voice Loop ✅

**Goal:** Build MVVM architecture, foundational services, and a working voice conversation loop end-to-end
**Success Criteria:**

1. ✅ MVVM architecture established — ViewModels own business logic, screens are pure UI
2. ✅ User can speak into mic and see their voice message bubble with transcript
3. ✅ User can receive AI response as voice message bubble with transcript
4. ✅ AI responds in character with appropriate persona (Gemini API)
5. ✅ Scenario selection works with 3 curated scenarios
6. ✅ CEFR level filter chips on scenario selection screen

**Requirements:** CONV-01 ✅, CONV-03 ✅, CONV-04 ✅, CONV-05 ✅, CONV-06 ✅, PLAT-01 ✅

---

## Phase 2: Complete MVP Features (onboarding, feedback, local storage) ✅

**Goal:** Add onboarding, goal tracking, feedback, and local persistence to complete the core MVP
**Success Criteria:**

1. ✅ Onboarding flow collects language, CEFR level, and goal (with per-step persistence)
2. ✅ Goal progress indicator shows scenario goal during conversation
3. ✅ Task-based goal evaluation (Gemini structured JSON with responseSchema)
4. ✅ Feedback & Score screen (score circle, breakdown, XP badge, grammar corrections)
5. ✅ Local progress storage (SharedPreferences, crash-safe per-step save)
6. ✅ Rate limiting (device fingerprint, 10 calls/day sliding window)

**Requirements:** CONV-07 ✅, ONBD-01 ✅, ONBD-02 ✅, FDBK-01 ✅, FDBK-02 ✅, FDBK-03 ✅, PLAT-02 ✅, PLAT-03 ✅

**Depends on:** Phase 1 complete

**Plans:** 2/2 plans executed

Plans:

- [x] 02-01-PLAN.md — Foundation: rate limiter, onboarding persistence, end conversation action
- [x] 02-02-PLAN.md — Feedback feature: evaluation service, score screen, route integration

---

## Phase 3: Accounts & Cloud Sync

**Goal:** Add authentication, cloud sync, and home dashboard
**Success Criteria:**

1. Sign up / login (email, Google, continue-as-guest)
2. Home Dashboard with streak, daily goal ring, recommended scenarios
3. Guest mode "sign up to save progress" banner
4. Full Firestore cloud sync for progress data
5. Guest-to-authenticated data migration

**Requirements:** PLAT-02 (partial)

**Depends on:** Phase 2 complete (onboarding, local storage)

**Plans:** 1/3 plans executed

Plans:
**Wave 1**

- [x] 03-01-PLAN.md — Firebase foundation: dependencies, AuthService, FirestoreService, auth state providers

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] 03-02-PLAN.md — Auth UI and Home dashboard: login, sign-up, forgot password, home screen, navigation

**Wave 3** *(blocked on Wave 2 completion)*

- [ ] 03-03-PLAN.md — Cloud sync integration: guest migration, Firestore sync, user-based rate limiting

---

## Phase 4: Gamification & Retention

**Goal:** Add engagement mechanics and learning intelligence
**Success Criteria:**

1. Streak count + flame icon, XP, badges
2. Spaced repetition (SRS) for missed vocab/phrases
3. Mistake pattern dashboard (time-series)
4. Leaderboard/social features (requires account)

**Requirements:** FDBK-01, FDBK-02, FDBK-03

---

## Phase 5: Premium & Polish

**Goal:** Monetization, pronunciation scoring, production polish
**Success Criteria:**

1. Premium gating: unlimited conversations, advanced scenarios, ad-free
2. Pronunciation-level feedback (Azure Speech / Speechace)
3. "Today's twist" — Gemini-generated scenario variation
4. Cross-platform polish (iOS, Android, Web)
5. All edge cases handled (network errors, mic permissions, etc.)

**Requirements:** PLAT-03

---

*Last updated: 2026-07-18 after Phase 2 completion*
