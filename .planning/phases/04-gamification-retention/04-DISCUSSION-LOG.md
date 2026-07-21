# Phase 4: Gamification & Retention - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-07-21
**Phase:** 04-gamification-retention
**Areas discussed:** Navigation & GoRouter, Streak & XP mechanics, Badge system, SRS & Mistake dashboard

---

## Navigation & GoRouter

### Tab count

| Option | Description | Selected |
|--------|-------------|----------|
| 4 tabs: Home, Scenarios, Progress, Profile | Home (dashboard), Scenarios (list), Progress (stats/badges), Profile (settings). Conversation is full-screen push. | ✓ |
| 3 tabs: Home, Progress, Profile | Home (dashboard+scenarios combined), Progress (stats/badges), Profile (settings). Fewer taps to start conversation. | |
| 3 tabs: Home, Scenarios, Profile | Home (dashboard), Scenarios (list), Profile (settings+stats combined). Progress stays lightweight. | |

**User's choice:** 4 tabs: Home, Scenarios, Progress, Profile
**Notes:** Conversation screen will always be full-screen push with no bottom nav visible during conversation.

### Tab icons

| Option | Description | Selected |
|--------|-------------|----------|
| Standard Material icons | Home: house, Scenarios: chat bubble, Progress: chart/trophy, Profile: person. Standard Flutter icons. | |
| Custom claymorphism icons | Use custom claymorphism-style icons matching the app theme. More work but consistent aesthetic. | ✓ |
| Material icons first, custom later | Start with Material icons, replace with custom icons in a later polish phase. | |

**User's choice:** Custom claymorphism icons
**Notes:** Consistent with the app's 3D claymorphism design theme.

### Guest navigation

| Option | Description | Selected |
|--------|-------------|----------|
| Same tabs, limited content | Same 4 tabs, but Progress and Profile show limited data + "Sign up to save" banner. Conversations still work. | |
| Reduced tabs for guests | Only 2 tabs (Home, Scenarios) for guests. Progress/Profile hidden until account creation. | ✓ |
| Same tabs, modal gate | Same 4 tabs, but tapping Progress/Profile shows a login prompt modal before content. | |

**User's choice:** Reduced tabs for guests
**Notes:** Guests see only Home and Scenarios tabs. Progress and Profile hidden until account creation.

### Route logic

| Option | Description | Selected |
|--------|-------------|----------|
| Onboarding → Home (linear) | Check if onboarding completed, then auth state. Splash → Onboarding → Home (guest or logged-in). Simple, linear. | |
| Auth-first (skip onboarding if profile exists) | Splash → check auth → if no profile, onboarding → Home. If has profile, straight to Home. Faster for returning users. | ✓ |
| Resume-aware onboarding | Same as auth-first, but also check if user completed onboarding step 2/3. Resume from where they left off if interrupted. | |

**User's choice:** Auth-first (skip onboarding if profile exists)
**Notes:** Splash → check if profile exists → if yes, skip onboarding and go to Home; if no, go to onboarding flow.

---

## Streak & XP mechanics

### Streak rules

| Option | Description | Selected |
|--------|-------------|----------|
| Daily: 1+ scenario = streak maintained | Complete 1+ scenarios per day to maintain streak. Missing a day resets to 0. Simple, classic. | ✓ |
| Daily with 1 grace day | Complete 1+ scenarios per day. 1 grace day allowed (miss 1 day, streak survives). More forgiving. | |
| Daily, timezone-aware reset | Complete 1+ scenarios per day, but timezone-aware (resets at midnight in user's local timezone). | |

**User's choice:** Daily: 1+ scenario = streak maintained
**Notes:** Classic daily streak with no grace period. Resets at midnight in user's local timezone.

### XP formula

| Option | Description | Selected |
|--------|-------------|----------|
| Fixed XP (50 per scenario) | Flat 50 XP per scenario completed. Simple, predictable. | ✓ |
| Score-based (30-100 XP range) | Base XP (30) + score bonus (up to 70). Higher score = more XP. Rewards quality. | |
| Score + streak bonus (30-150 XP range) | Base XP (30) + score bonus + streak bonus (+10 per streak day, max +50). Rewards consistency. | |

**User's choice:** Fixed XP (50 per scenario)
**Notes:** Simple, predictable XP earning. No score-based variability.

### XP display

| Option | Description | Selected |
|--------|-------------|----------|
| Total XP only | Just show total XP number. Simple, no level system. | |
| XP + level progression | Total XP + level tiers (Beginner → Intermediate → Advanced → Master). Visual progress bar to next level. | ✓ |
| XP + levels + progress bar | Total XP + level tiers + XP progress bar. More engaging but more UI complexity. | |

**User's choice:** XP + level progression
**Notes:** 5 levels with linear progression (500 XP per level).

### Level tiers

| Option | Description | Selected |
|--------|-------------|----------|
| Linear (500 XP per level) | 500 XP each. 5 levels total (Beginner 0, Elementary 500, Intermediate 1000, Advanced 1500, Master 2000). Linear progression. | ✓ |
| Exponential (harder at higher levels) | Exponential: 200, 500, 1000, 2000, 5000. Early levels fast, later levels require commitment. | |
| Configurable (decide exact numbers later) | Define level names and thresholds in config, easy to tweak later. Don't lock exact numbers now. | |

**User's choice:** Linear (500 XP per level)
**Notes:** 5 levels: Beginner (0), Elementary (500), Intermediate (1000), Advanced (1500), Master (2000).

---

## Badge system

### Badge count

| Option | Description | Selected |
|--------|-------------|----------|
| Small set (5-8 badges) | 5-8 core badges (First Conversation, 7-Day Streak, 100 XP, etc.). Simple, achievable. | ✓ |
| Medium set (10-15 badges) | 10-15 badges across categories (streak, XP, scenarios, social). More goals to chase. | |
| Start small, extensible system | Start with 5-8, design the system to be extensible for future badges. | |

**User's choice:** Small set (5-8 badges)
**Notes:** 5-8 core badges at launch. System designed to be extensible for future badges.

### Badge types

| Option | Description | Selected |
|--------|-------------|----------|
| Milestone-based (streak, XP, scenarios) | Streak badges (7-day, 30-day), XP badges (100, 500, 1000), Scenario badges (1st, 10th, 50th completion). | |
| Milestone + skill achievements | Same as above + skill badges (Perfect Score, No Mistakes, Fast Learner). More variety. | ✓ |
| Decide badge list later | Decide exact badge list during planning, focus on the trigger system now. | |

**User's choice:** Milestone + skill achievements
**Notes:** Categories: milestone-based (streak, XP, scenarios) + skill achievements (Perfect Score, No Mistakes, Fast Learner).

### Badge notification

| Option | Description | Selected |
|--------|-------------|----------|
| Immediate animated popup | Show animated badge popup immediately when earned. Celebratory, but interrupts flow. | ✓ |
| Toast + details on Progress screen | Toast notification during conversation, full details on Progress screen. Less interruption. | |
| Subtle indicator + details on Progress | Badge icon animates on Progress tab, full details when user opens Progress screen. | |

**User's choice:** Immediate animated popup
**Notes:** Celebratory, interruptive by design — user should feel rewarded.

---

## SRS & Mistake dashboard

### SRS scope

| Option | Description | Selected |
|--------|-------------|----------|
| Grammar corrections only | Track words/phrases user struggled with (grammar corrections from AI feedback). Resurface in future scenarios. | |
| Grammar + vocabulary | Track grammar corrections + vocabulary user didn't know (AI flags unknown words). Broader coverage. | |
| Grammar + vocabulary + phrases | Track grammar + vocabulary + phrases user missed. Most comprehensive, but more data to manage. | ✓ |

**User's choice:** Grammar + vocabulary + phrases
**Notes:** Most comprehensive SRS scope. Tracks all items user struggled with.

### SRS integration

| Option | Description | Selected |
|--------|-------------|----------|
| AI prompt injection (subtle) | AI prompt includes user's weak points, naturally weaves them into conversation. Subtle, immersive. | |
| Pre-scenario review screen | Show a 'Review' section before scenario starts with words to practice. Explicit, user-controlled. | ✓ |
| AI injection + review screen | Both: AI subtly includes them AND show a brief review. Reinforces from two angles. | |

**User's choice:** Pre-scenario review screen
**Notes:** Explicit, user-controlled approach. User sees words/phrases to practice before starting a scenario.

### Mistake metrics

| Option | Description | Selected |
|--------|-------------|----------|
| Summary metrics only | Overall accuracy %, grammar mistakes count, vocabulary gaps count. Simple summary. | ✓ |
| Summary + trend chart | Summary + time-series chart showing improvement over last 7/30 days. Visual progress. | |
| Summary + trend + category breakdown | Summary + trend + category breakdown (grammar types, vocabulary topics). Detailed but complex. | |

**User's choice:** Summary metrics only
**Notes:** Simple summary: overall accuracy %, grammar mistakes count, vocabulary gaps count.

### Dashboard data

| Option | Description | Selected |
|--------|-------------|----------|
| Last 7 days only | Show last 7 days only. Simple, recent focus. | ✓ |
| All-time | Show all-time data. Complete picture but can be overwhelming. | |
| 7 days default, toggle options | Default to 7 days, user can toggle to 30 days or all-time. | |

**User's choice:** Last 7 days only
**Notes:** Simple, recent focus. No time range toggle.

---

## Claude's Discretion

- Badge visual design (claymorphism style, colors, animations)
- Level tier names and icons (Beginner → Elementary → Intermediate → Advanced → Master)
- Pre-scenario review screen layout and interaction design
- Leaderboard implementation details (global vs friends, anonymous vs named)
- SRS algorithm specifics (interval calculation, ease factor)
- Mistake dashboard visual layout

---

## Deferred Ideas

None — discussion stayed within phase scope.
