---
phase: 05
slug: premium-and-polish
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-07-23
---

# Phase 5 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (SDK) |
| **Config file** | analysis_options.yaml (flutter_lints) |
| **Quick run command** | `flutter analyze lib/` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter analyze lib/`
- **After every plan wave:** Run `flutter test`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 05-01-T1 | 05-01 | 1 | CONV-01 | — | N/A | unit | `flutter test test/core/services/scenario_service_test.dart` | ❌ W0 | ⬜ pending |
| 05-01-T2 | 05-01 | 1 | CONV-01 | T-01 | Firestore rules: `allow read: if true` on /scenarios | integration | Manual (Firestore) | ❌ W0 | ⬜ pending |
| 05-01-T3 | 05-01 | 1 | CONV-01 | — | N/A | widget | `flutter test test/features/scenario_selection/` | ❌ W0 | ⬜ pending |
| 05-01-T4 | 05-01 | 1 | CONV-01 | — | N/A | unit | `flutter analyze lib/features/scenario_selection/` | ❌ W0 | ⬜ pending |
| 05-02-T1 | 05-02 | 2 | CONV-03, CONV-04 | — | N/A | unit | `flutter test test/core/services/ai_service_test.dart` | ❌ W0 | ⬜ pending |
| 05-02-T2 | 05-02 | 2 | CONV-03 | T-02 | Firestore rules: `allow read, write: if request.auth.uid == userId` | integration | Manual (Firestore) | ❌ W0 | ⬜ pending |
| 05-02-T3 | 05-02 | 2 | CONV-03 | — | N/A | widget | `flutter test test/features/scenario_selection/viewmodels/create_scenario_viewmodel_test.dart` | ❌ W0 | ⬜ pending |
| 05-03-T1 | 05-03 | 3 | CONV-03 | — | N/A | unit | `flutter test test/features/scenario_selection/viewmodels/twist_scenario_viewmodel_test.dart` | ❌ W0 | ⬜ pending |
| 05-03-T2 | 05-03 | 3 | CONV-03 | — | N/A | unit | `flutter test test/features/scenario_selection/widgets/scenario_card_test.dart` | ❌ W0 | ⬜ pending |
| 05-04-T1 | 05-04 | 3 | CONV-05 | — | N/A | unit | `flutter test test/features/home/viewmodels/home_viewmodel_test.dart` | ❌ W0 | ⬜ pending |
| 05-04-T2 | 05-04 | 3 | CONV-05 | T-03 | Firestore rules: admin-only write on /challenges/{date} | integration | Manual (Firestore) | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/core/services/scenario_service_test.dart` — caching and Firestore fetch
- [ ] `test/core/services/ai_service_generation_test.dart` — generateScenario() parsing
- [ ] `test/features/scenario_selection/viewmodels/scenario_selection_viewmodel_test.dart` — filtering/category/search logic
- [ ] `test/features/scenario_selection/viewmodels/create_scenario_viewmodel_test.dart` — generation flow
- [ ] `test/features/home/viewmodels/home_viewmodel_daily_challenge_test.dart` — Daily Challenge detection and countdown
- [ ] `test/features/scenario_selection/widgets/scenario_card_test.dart` — Twist badge visibility
- [ ] No new infra installs needed — flutter_test is SDK-internal

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Scenario catalog loads from Firestore with categories/search/pagination | CONV-01 | Firestore dependency requires running app | Launch app → Scenario Selection tab → verify categories, search, pagination |
| Custom scenario delete confirmation dialog | CONV-03 | Widget integration test with Firestore | Create scenario → tap delete → verify "This can't be undone" dialog |
| Daily Challenge seed generation | CONV-05 | First-user-generates pattern | Clear Firestore /challenges/{date} → open app → verify seed document created |
| Firestore rules enforcement | CONV-01, CONV-03, CONV-05 | Security rules not testable in unit tests | Deploy rules → verify unauthenticated /scenarios read, authenticated-only /users/{uid}/custom_scenarios CRUD |

---

## Validation Sign-Off

- [ ] All tasks have automated verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
