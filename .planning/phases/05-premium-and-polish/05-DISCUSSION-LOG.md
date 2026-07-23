# Phase 5: Premium-and-Polish - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-07-23 (Updated)
**Phase:** 05-premium-and-polish
**Mode:** Update existing context

---

## Context Update Session

**Prior state:** CONTEXT.md existed with 9 decisions (D-01 through D-09), 2 plans existed (05-01, 05-02), UI-SPEC.md locked UI design.

**Action:** Updated context with custom scenario lifecycle decisions. Remaining gray areas (Daily Challenge rotation, Twist tracking, curated scenario schema) deferred to Claude's discretion.

---

## Custom Scenario Lifecycle

### Edit after save

| Option | Description | Selected |
|--------|-------------|----------|
| No editing needed | Once saved, the scenario is fixed | ✓ |
| Yes — edit before replay | Pre-filled form to regenerate | |
| You decide | Claude's pragmatic choice | |

**User's choice:** No editing needed

---

### Delete after save

| Option | Description | Selected |
|--------|-------------|----------|
| Yes — with confirmation | Delete with "This can't be undone" dialog | ✓ |
| No delete | Users can only create, not remove | |
| You decide | Claude's choice | |

**User's choice:** Yes — with confirmation

---

### Ordering

| Option | Description | Selected |
|--------|-------------|----------|
| By creation date (newest first) | Most recently created at top | ✓ |
| By last played date | Most recently practiced at top | |
| Alphabetical order | Simple, predictable sorting | |

**User's choice:** By creation date (newest first)

---

### Practical limit

| Option | Description | Selected |
|--------|-------------|----------|
| No limit | Unlimited — consistent with free app | ✓ |
| Soft limit (50) | Sanity cap no regular user would hit | |

**User's choice:** No limit (Claude's recommendation, user said "You decide")

---

## Area Completion

- Custom scenario lifecycle: Discussed and captured ✓
- Daily Challenge rotation: Deferred to Claude's discretion
- Twist completion tracking: Deferred to Claude's discretion
- Curated scenario schema + seed workflow: Deferred to Claude's discretion

---

## Claude's Discretion (from this session)

- Daily Challenge rotation: timezone handling, reset timing, global vs per-user
- Twist tracking: where/how to store replay count for progressive depth
- Curated scenario schema: fields beyond current model
- Scenario seed prompt design
- Custom scenario deletion UX interaction (long-press, swipe, or menu)
- Custom scenario generation output schema

---

## Deferred Ideas

*(No new deferred ideas — Phase 5 scope unchanged)*
