# Roadmap: Linguo Wizard

**Mode:** horizontal-layers
**Phases:** 4
**Requirements mapped:** 15/15 ✓

---

## Phase 1: Foundation & Core Voice Loop
**Goal:** Build the foundational architecture and get a working voice conversation loop end-to-end
**Success Criteria:**
1. User can speak into mic and see their voice message bubble with transcript
2. User can receive AI response as voice message bubble with transcript
3. AI responds in character with appropriate persona
4. Basic scenario selection works (at least 3 curated scenarios)
**Requirements:** CONV-01, CONV-03, CONV-04, CONV-05, CONV-06, PLAT-01

---

## Phase 2: Onboarding & Scenario Experience
**Goal:** Complete the user journey from first open to scenario selection
**Success Criteria:**
1. Splash screen displays with claymorphism aesthetic
2. Onboarding flow collects language, CEFR level, and goal
3. Scenario selection screen shows scenarios with CEFR filter chips
4. Progress indicator shows scenario goal during conversation
**Requirements:** ONBD-01, ONBD-02, CONV-02, CONV-07

---

## Phase 3: Feedback & Gamification
**Goal:** Deliver post-conversation feedback and basic progression
**Success Criteria:**
1. Post-conversation transcript shows inline grammar corrections
2. Summary score displays (fluency, grammar, vocabulary)
3. XP earned for completing scenarios
4. User sees their accumulated XP
**Requirements:** FDBK-01, FDBK-02, FDBK-03

---

## Phase 4: Polish & Platform
**Goal:** Production-ready app with guest mode and rate limiting
**Success Criteria:**
1. Guest mode works with local-only progress storage
2. Rate limiting prevents AI call abuse (server-side)
3. App works on iOS, Android, and Web
4. All edge cases handled (network errors, mic permissions, etc.)
**Requirements:** PLAT-02, PLAT-03

---

*Last updated: 2026-07-14 after roadmap creation*
