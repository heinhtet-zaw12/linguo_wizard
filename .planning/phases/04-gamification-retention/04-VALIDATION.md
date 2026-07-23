---
phase: 4
slug: gamification-retention
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-07-21
---

# Phase 4 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (built-in) |
| **Config file** | none — standard Flutter test setup |
| **Quick run command** | `flutter test` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~10 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter test`
- **After every plan wave:** Run `flutter test`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 10 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 04-01-01 | 01 | 1 | FDBK-03 | — | XP award only after successful evaluation | unit | `flutter test` | ❌ W0 | ⬜ pending |
| 04-02-01 | 02 | 1 | FDBK-01 | — | Grammar corrections tracked in SRS | unit | `flutter test` | ❌ W0 | ⬜ pending |
| 04-02-02 | 02 | 1 | FDBK-02 | — | Score display with XP/level info | unit | `flutter test` | ❌ W0 | ⬜ pending |
| 04-03-01 | 03 | 2 | FDBK-01 | — | SRS items stored securely per user | unit | `flutter test` | ❌ W0 | ⬜ pending |
| 04-04-01 | 04 | 2 | FDBK-03 | — | Leaderboard data integrity | unit | `flutter test` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/models/streak_data_test.dart` — streak calculation logic
- [ ] `test/models/srs_item_test.dart` — SM-2 algorithm
- [ ] `test/models/badge_test.dart` — badge condition evaluation
- [ ] `test/viewmodels/progress_viewmodel_test.dart` — progress stats
- [ ] `test/viewmodels/leaderboard_viewmodel_test.dart` — leaderboard queries
- [ ] `test/navigation/router_test.dart` — GoRouter route guards and redirects

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Badge popup animation | FDBK-03 | Visual animation requires human judgment | Complete a scenario, verify badge popup appears with confetti on FeedbackScreen |
| Bottom nav state preservation | D-01 | Tab state persistence is visual/interactive | Switch between tabs, verify scroll position and widget state preserved |
| Pre-scenario review screen | D-14 | SRS items display requires visual verification | Trigger SRS review before scenario, verify items shown correctly |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 10s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
