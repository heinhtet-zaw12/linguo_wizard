# Roadmap: Linguo Wizard

**Mode:** horizontal-layers
**Phases:** 6
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

**Plans:** 3/3 plans complete

Plans:
**Wave 1**

- [x] 03-01-PLAN.md — Firebase foundation: dependencies, AuthService, FirestoreService, auth state providers

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 03-02-PLAN.md — Auth UI and Home dashboard: login, sign-up, forgot password, home screen, navigation

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 03-03-PLAN.md — Cloud sync integration: guest migration, Firestore sync, user-based rate limiting

---

## Phase 4: Gamification & Retention ✅

**Goal:** Add engagement mechanics and learning intelligence
**Success Criteria:**

1. Streak count + flame icon, XP, badges
2. Spaced repetition (SRS) for missed vocab/phrases
3. Mistake pattern dashboard (summary metrics, last 7 days)
4. Leaderboard/social features (requires account)

**Requirements:** FDBK-01, FDBK-02, FDBK-03

**Plans:** 3/3 plans complete

Plans:
**Wave 1**

- [x] 04-01-PLAN.md — GoRouter navigation shell: bottom nav, route guards, stateful tabs

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 04-02-PLAN.md — Gamification data layer: config files, models, services, Firestore extension

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 04-03-PLAN.md — UI screens and integration: Progress, Leaderboard, Pre-Scenario Review, Badge Popup, ViewModel wiring

---

## Phase 5: Polish & Custom Scenarios 🔄

**Goal:** Production-scale scenario catalog, AI-generated custom scenarios, Today's Twist, Daily Challenge
**Success Criteria:**

1. 30+ curated scenarios in Firestore catalog with category tabs, search, and infinite scroll pagination
2. Users can create unlimited custom scenarios via Gemini generation
3. Today's Twist — replay completed scenarios with progressive AI-generated variations
4. Daily Challenge — fresh AI-generated scenario daily with 2x XP bonus on Home dashboard

**Requirements:** CONV-01, CONV-03, CONV-04, CONV-05

**Plans:** 4/4 plans executed

Plans:
**Wave 1**

- [x] 05-01-PLAN.md — Firestore scenario catalog: 34 curated scenarios, categories, search, pagination, local cache
- [x] 05-02-PLAN.md — Custom scenarios: Gemini generation, read-only preview, "My Scenarios" with delete, unlimited for all users

**Wave 2** *(blocked on Wave 1 completion)*

[No plans this wave — 05-03 and 05-04 depend on both 05-01 AND 05-02]

**Wave 3** *(blocked on Wave 1 + Wave 2 plans)*

- [x] 05-03-PLAN.md — Today's Twist: Twist badge on completed cards, progressive AI variations, no counter/history
- [x] 05-04-PLAN.md — Daily Challenge: UTC-based fresh AI challenge daily, Home hero card with countdown, 2x XP (100 total)

---

## Phase 6: UI/UX Overhaul

**Goal:** Complete visual redesign — modern "Soft Glass" design system, dark mode, shared component library, micro-interactions, and polished screens across the entire app

**Design Philosophy:** Refined glassmorphism with frosted glass cards, soft gradient mesh backgrounds, fluid typography (Plus Jakarta Sans + Inter), and breathing whitespace. Elevated yet warm — matching the language learning context.

**Success Criteria:**

1. Centralized design system — tokens for colors (light + dark), typography, spacing, shadows, radii
2. Dark mode — full light/dark theme with system preference detection and manual toggle
3. Shared component library — `AppButton`, `AppTextField`, `AppCard`, `AppChip`, `AppNavBar` in `lib/core/widgets/`
4. New typography — Plus Jakarta Sans (headings) + Inter (body) + JetBrains Mono (scores/numbers)
5. All 14 screens redesigned with new visual language (glass cards, gradient backgrounds, proper hierarchy)
6. Micro-interactions — tap feedback, screen transitions, animated score circles, card entrance animations
7. Zero breaking changes — all logic, state, navigation, services, and functionality preserved

**Requires:** Phase 5 complete

**Plans:** 2/2 plans complete

Plans:

- [x] 06-01-PLAN.md
- [x] 06-02-PLAN.md

**Wave 1** — Design System Foundation (tokens, dark mode, typography, dependencies)
**Wave 2** — Shared Component Library (extract + upgrade duplicated widgets)
**Wave 3** — Screen Redesign (feature by feature, all 14 screens)
**Wave 4** — Dark Mode Toggle + Polish (persistence, QA, animation audit)

---

## Phase 7: UI Redesign — Futuristic Dark Theme

**Goal:** Complete visual redesign — futuristic dark-only theme with blue-violet electric palette, frosted glass components, animated mesh gradient backgrounds, and micro-interactions across all 13 screens

**Design Philosophy:** Futuristic dark-only — deep navy/charcoal surfaces, electric blue → violet gradients, cyan highlights, frosted glass (glassmorphism 2.0), spring physics animations, animated gradient mesh backdrop. Premium, bold, zero light mode.

**Success Criteria:**

1. Single dark palette — no light/dark toggle, no AppColorProvider, no ThemeModeProvider
2. All 333 legacy color references replaced with new semantic tokens
3. Component library — GlassCard, AppButton (3 variants), GlassChip, GradientNavBar, MeshGradientBackground, AppTextField, StatCard, CefrBadge
4. All 13 screens redesigned with new visual language (glass cards, gradient backgrounds, proper hierarchy)
5. Micro-interactions — spring press animations, staggered card entrances, gradient nav indicator, score counter animation
6. Zero breaking changes — all logic, state, navigation, services, and functionality preserved
7. `flutter analyze` passes with zero errors after each implementation step

**Requires:** Phase 6 complete

**Spec:** `docs/superpowers/specs/2026-08-05-ui-redesign-design.md`

**Plans:** 3/3 plans complete

Plans:
**Wave 1**

- [x] 07-01-PLAN.md — Theme foundation rewrite (flat dark palette, AppGradients, glow shadows) + all 9 core widgets restyled to glassmorphism 2.0 + AppColorProvider/ThemeModeProvider deleted

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 07-02-PLAN.md — Screen redesigns batch 1: splash, onboarding (3 steps), auth (3 screens), home dashboard (5 widgets), scenario selection (3 screens) — 18 files total

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 07-03-PLAN.md — Screen redesigns batch 2: conversation (hero screen, mic button, voice bubbles), feedback (score circle, confetti), profile, leaderboard, progress (3 widgets), badge popup — 11 files total + final zero-legacy audit

---

*Last updated: 2026-08-05*
