# Phase 5: Polish & Custom Scenarios - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-07-23
**Phase:** 05-premium-and-polish
**Areas discussed:** Premium infrastructure, Phase 5 scope, Today's Twist, Daily Challenge, Scenario seeding, Phase 6 features

---

## Premium Infrastructure

| Option | Description | Selected |
|--------|-------------|----------|
| Simple boolean flag | Premium is just a config flag in AppConfig / Firestore user doc | |
| Firebase user doc field | Add 'isPremium'/'tier' field to Firestore user doc | |
| Let Claude decide | Flexible recommendation | |

**User's choice:** **Clarification requested** — user clarified the app is completely free, no premium features at all.

---

## Phase 5 Scope (After Premium Removal)

| Option | Description | Selected |
|--------|-------------|----------|
| Just the two plans | Firestore catalog + custom scenarios. That's the finish line. | |
| Add 'Today's Twist' | AI generates a fun variation for replayability | |
| Let's brainstorm | User has other features in mind | ✓ |

**User's choice:** Let's brainstorm
**Notes:** User was enthusiastic about all 6 proposed features. Decided to split into Phase 5 + Phase 6.

---

## Today's Twist — Trigger

| Option | Description | Selected |
|--------|-------------|----------|
| Badge on card | Twist badge on completed scenario cards | ✓ |
| Auto-offer on completion | 'Play again with a twist?' on feedback screen | |
| Shuffle button | Explicit 'Random Twist' control | |

**User's choice:** Badge on card

---

## Today's Twist — Depth

| Option | Description | Selected |
|--------|-------------|----------|
| Subtle | Change one situational detail | |
| Moderate | Change persona or goal | |
| Progressive twist | Subtle on first replay, moderate on subsequent | ✓ |

**User's choice:** Progressive twist

---

## Today's Twist — Tracking

| Option | Description | Selected |
|--------|-------------|----------|
| Visible badge only | No detailed tracking | ✓ |
| Tracked with history | Counter + past twists browsable | |
| Hidden / surprise | No indicator at all | |

**User's choice:** Visible badge only

---

## Daily Challenge — Selection

| Option | Description | Selected |
|--------|-------------|----------|
| Random pick | Pick a random curated scenario daily | |
| AI-generated daily unique | Fresh AI-generated variation each day | ✓ |
| Manual curation | You pick which scenario is featured | |

**User's choice:** AI-generated daily unique

---

## Daily Challenge — Placement

| Option | Description | Selected |
|--------|-------------|----------|
| Top of scenario screen | Card at top of scenario selection | |
| Home dashboard hero | Featured placement on Home screen | ✓ |
| Both placements | Home + scenario screen | |

**User's choice:** Home dashboard hero

---

## Daily Challenge — Reward

| Option | Description | Selected |
|--------|-------------|----------|
| 1.5x XP bonus | 50 + 25 XP | |
| 2x XP bonus | 50 + 50 = 100 XP | ✓ |
| XP + streak protection | Double XP + auto-streak | |

**User's choice:** 2x XP bonus

---

## Scenario Seeding (Plan 05-01)

| Option | Description | Selected |
|--------|-------------|----------|
| Hand-crafted by me | Full manual control | |
| AI-generated + reviewed | Gemini generates, you review | ✓ |
| AI drafts, hand-curated | Hybrid approach | |

**User's choice:** AI-generated + reviewed

---

## Phase 6 Features

| Feature | Decision |
|---------|----------|
| Vocabulary Book | Dropped — replaced by AI Explain button |
| Conversation History | Dropped — scope decision |
| Scenario Collections | Included in Phase 6 |
| Myanmar UI | Included in Phase 6 |
| AI Explain button | Included in Phase 6 (tightly scoped: inline text-only on bubbles) |

---

## Claude's Discretion

- Today's Twist Gemini prompt design (how to generate the variation)
- Daily Challenge rotation logic and timezone handling
- Scenario seed prompt design for Gemini generation
- UI details for the Twist badge, Challenge hero card, and Create Scenario button
- Category tab design and ordering (Travel, Work, Social, Academic, Daily Life)
- Search bar debounce and minimum character behavior

## Deferred Ideas

- Conversation History & Review — dropped after reconsideration
- Vocabulary Book — dropped after reconsideration
- Pronunciation scoring (phoneme-level) — requires paid API, not pursued
