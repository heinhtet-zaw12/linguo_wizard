# Phase 2: Complete MVP Features (onboarding, feedback, local storage) - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-07-18
**Phase:** 02-complete-mvp-features
**Areas discussed:** Onboarding flow design, Goal progress & evaluation, Local storage & rate limiting

---

## Onboarding Flow Design

### Flow Structure

| Option | Description | Selected |
|--------|-------------|----------|
| Multi-step wizard | Each selection gets its own screen with big illustrations (claymorphism style). More immersive, matches the design theme. | ✓ |
| Single screen | All three selections on one scrollable screen. Faster to complete, less visual impact. | |
| Two-step (compact) | Combine language+CEFR on one screen, goal on the next. Compromise between immersion and speed. | |

**User's choice:** Multi-step wizard
**Notes:** Matches the 3D Claymorphism design theme

### Step Order

| Option | Description | Selected |
|--------|-------------|----------|
| Language → CEFR → Goal | Starts with the most personal choice, then narrows down. Feels progressive. | ✓ |
| CEFR → Language → Goal | Starts with skill level (feels like a test), then language and motivation. | |
| Goal → Language → CEFR | Starts with motivation (why are you learning?), then language and level. | |

**User's choice:** Language → CEFR → Goal

### Required vs Skippable

| Option | Description | Selected |
|--------|-------------|----------|
| Required | All three steps mandatory. Ensures preferences are set for personalized experience. | ✓ |
| Skippable with defaults | Allow skipping with sensible defaults (English, B1, Travel). Less friction but weaker personalization. | |

**User's choice:** Required

### Post-Onboarding Destination

| Option | Description | Selected |
|--------|-------------|----------|
| Scenario selection | Land on scenario selection, filtered by chosen CEFR level. Direct path to starting a conversation. | ✓ |
| Home dashboard | Land on a home dashboard with recommended scenarios, streaks, and stats. More feature-rich but adds complexity. | |

**User's choice:** Scenario selection

### Editable Later

| Option | Description | Selected |
|--------|-------------|----------|
| Editable later | Add a settings/profile section where users can update language, CEFR level, and goal after onboarding. | ✓ |
| Locked after onboarding | Once set, preferences are locked until app reinstall. Simpler but less flexible. | |

**User's choice:** Editable later

---

## Goal Progress & Evaluation

### Goal Indicator Style

| Option | Description | Selected |
|--------|-------------|----------|
| Top bar with goal text | A thin progress bar at the top of the conversation screen showing scenario goal text (e.g., "Order your coffee"). Simple, non-intrusive. | ✓ |
| Progress bar with percentage | A progress indicator with percentage or step markers. More visual feedback but potentially distracting. | |
| Minimal (scenario name only) | Just the scenario name in the app bar. Minimal — user remembers the goal from scenario selection. | |

**User's choice:** Top bar with goal text

### Evaluation Timing

| Option | Description | Selected |
|--------|-------------|----------|
| End of conversation | AI analyzes the full conversation after user ends it. More accurate assessment, simpler implementation. | ✓ |
| Periodic mid-conversation checks | AI periodically checks progress during the conversation. More complex but provides real-time feedback. | |

**User's choice:** End of conversation

### Evaluation Output

| Option | Description | Selected |
|--------|-------------|----------|
| Pass/Fail + short note | Simple pass/fail with optional brief explanation. Clean, easy to display. | |
| 3-tier (full/partial/miss) | Three tiers: fully achieved, partially achieved, not achieved. More nuance for the feedback screen. | |
| Scored (0-100) | Numeric score (0-100) with breakdown. Most detailed but may feel overly judgmental. | ✓ |

**User's choice:** Scored (0-100)

### Conversation End Trigger

| Option | Description | Selected |
|--------|-------------|----------|
| Manual end button | A 'Done' or 'End conversation' button that the user taps when ready. Simple, user-controlled. | ✓ |
| AI-suggested end | AI detects when the goal is likely complete and suggests ending. More magical but less predictable. | |
| Both options | User can end manually, or AI suggests ending after a threshold. Best of both but more complex. | |

**User's choice:** Manual end button

---

## Local Storage & Rate Limiting

### Storage Solution

| Option | Description | Selected |
|--------|-------------|----------|
| shared_preferences | Simple key-value store, built into Flutter. Perfect for preferences and small progress data. Already commonly used. | ✓ |
| Hive | NoSQL database with rich querying. Better for complex data but heavier for simple needs. | |
| sqflite | Official SQLite plugin. Best for relational data but overkill for this use case. | |

**User's choice:** shared_preferences

### Data to Persist

| Option | Description | Selected |
|--------|-------------|----------|
| Onboarding preferences | Language, CEFR level, goal — persisted after onboarding. Needed for personalizing scenario filtering. | ✓ |
| Progress data (scenarios, XP, scores) | Completed scenarios, scores, XP, timestamps. Needed for progress tracking and future streaks. | |
| Conversation history | Full conversation transcripts with grammar corrections. Valuable for review but can grow large. | |

**User's choice:** Onboarding preferences only

### Save Timing

| Option | Description | Selected |
|--------|-------------|----------|
| After each onboarding step | Save after each step of the onboarding wizard. Ensures partial progress is never lost. | ✓ |
| Only at onboarding completion | Save once at the end when user taps 'Start'. Simpler but loses data if app crashes. | |

**User's choice:** After each onboarding step

### Rate Limit Type

| Option | Description | Selected |
|--------|-------------|----------|
| Daily call limit | Simple daily cap. Easy to understand, easy to enforce server-side. | ✓ |
| Rolling 24-hour window | Rolling window (e.g., 20 calls per 24 hours from first call). More fair but harder to communicate to user. | |
| Tiered (free + ad + premium) | Tiered: 10 free/day, watch ad for +5, premium for unlimited. More complex but monetizable. | |

**User's choice:** Daily call limit

### Daily Quota

| Option | Description | Selected |
|--------|-------------|----------|
| 5 calls/day | Conservative limit. Enough for 2-3 scenario practices per day. Encourages premium upgrade. | |
| 10 calls/day | Moderate limit. Enough for 4-5 scenarios. Balanced for free users. | ✓ |
| 20 calls/day | Generous limit. Almost unlimited for casual users. Harder to upsell premium. | |

**User's choice:** 10 calls/day

### Device Identification

| Option | Description | Selected |
|--------|-------------|----------|
| Device ID + IP hash | Combine device ID + IP hash for identification. More robust against simple bypasses like clearing storage. | ✓ |
| Device ID only | Simple device fingerprint via shared_preferences. Easy to bypass but good enough for MVP. | |
| IP-based only | IP-based only. No client storage needed but shared IPs (schools, offices) affect multiple users. | |

**User's choice:** Device ID + IP hash

---

## Claude's Discretion

- AI prompt design for goal evaluation
- Feedback screen layout details
- Error handling UX for rate limit exceeded
- Onboarding screen visual design
- Settings screen location and navigation

## Deferred Ideas

None — discussion stayed within phase scope.
