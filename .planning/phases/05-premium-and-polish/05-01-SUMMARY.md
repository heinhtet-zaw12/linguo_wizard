---
phase: "05"
plan: "01"
subsystem: "scenario-selection"
tags: ["firestore", "scenario-catalog", "caching", "seed-data", "pagination", "search"]
requires: []
provides: ["Firestore-scenario-catalog-API", "SharedPreferences-scenario-cache", "30plus-curated-scenarios", "redesigned-scenario-selection-UI"]
affects: ["scenario-selection-screen", "home-dashboard-recommendations", "firestore-rules"]
tech-stack:
  added: ["FirestoreScenarioService", "SharedPreferences cache pattern"]
  patterns: ["Cache-then-Firestore (instant startup + background refresh)", "Client-side pagination via list slicing", "Stacked filters (CEFR AND category AND search)"]
key-files:
  created:
    - "lib/core/services/scenario_service.dart"
    - "assets/data/scenarios/seed_list.json"
    - "scripts/seed_scenarios.dart"
  modified:
    - "lib/features/scenario_selection/models/scenario.dart"
    - "lib/features/scenario_selection/viewmodels/scenario_selection_viewmodel.dart"
    - "lib/features/scenario_selection/screens/scenario_selection_screen.dart"
    - "lib/features/scenario_selection/widgets/scenario_card.dart"
    - "lib/core/providers/service_providers.dart"
    - "lib/features/home/viewmodels/home_viewmodel.dart"
    - "firestore.rules"
    - "pubspec.yaml"
  removed:
    - "assets/data/scenarios/cafe_ordering.json"
    - "assets/data/scenarios/job_interview.json"
    - "assets/data/scenarios/airport_navigation.json"
decisions:
  - "Client-side pagination (list slicing by _visibleCount) instead of Firestore cursor pagination for simplicity"
  - "Removed DocumentSnapshot lastDocument from state — unused with slicing approach"
  - "home_viewmodel.dart updated to use FirestoreScenarioService instead of bundled JSON for recommended scenarios"
metrics:
  duration: "38 minutes"
  completed_date: "2026-07-23"
status: "complete"
---

# Phase 5 Plan 01: Firestore Scenario Catalog — Summary

Migrated the scenario system from 3 bundled JSON files to a Firestore-backed catalog with local SharedPreferences caching. Redesigned the scenario selection screen with category tabs, search bar, CEFR chips, and infinite scroll pagination. Seeded 34 curated scenarios across all CEFR levels and categories.

## What Was Built

### Core Infrastructure

1. **Extended Scenario model** (`lib/features/scenario_selection/models/scenario.dart`)
   - Added 4 new fields: `tags`, `difficultyRating`, `isFeatured`, `completionCount`
   - Added `toJson()` and `copyWith()` methods for serialization and immutable state
   - All new fields use `??` defaults in `fromJson` for backward compatibility

2. **FirestoreScenarioService** (`lib/core/services/scenario_service.dart`)
   - `getScenarios()` — main entrypoint: cache-first (instant), background-refresh if stale (>24h), blocks on first call
   - `fetchAll()` — paginated Firestore fetch ordered by `completionCount` descending
   - `getCachedScenarios()` / `cacheScenarios()` — SharedPreferences JSON serialization
   - `isCacheStale()` — checks 24h TTL
   - Provider registered in `service_providers.dart`

3. **Firestore rules** (`firestore.rules`)
   - Added `/scenarios/{scenarioId}` block: public read, admin-only write

### UI Redesign

4. **ScenarioSelectionViewModel** — complete rewrite:
   - State: `allScenarios`, `displayScenarios`, `selectedCefrLevel`, `selectedCategory`, `searchQuery`, `isLoading`, `isLoadingMore`, `hasMore`
   - Stacked filters: CEFR AND category AND search query (all three active simultaneously)
   - Client-side pagination: 20 at a time via list slicing
   - Sort: by `completionCount` descending (popular first)

5. **ScenarioSelectionScreen** — full redesign:
   - Category tabs: [All, Travel, Work, Social, Academic, Daily Life]
   - Search bar: icon toggle, autofocus, 300ms debounce
   - CEFR chips: horizontal row below categories (coexist with category tabs)
   - Infinite scroll: triggers `loadMore()` within 300px of bottom
   - Empty states: "No scenarios match your search", "Try adjusting your filters", network error with Retry
   - End-of-list indicator: "You've seen them all!"

6. **ScenarioCard** — extended:
   - "Featured" gold star badge (top-right) when `isFeatured`
   - Difficulty dots (3 small circles) below CEFR badge
   - All existing design maintained

### Seed Data

7. **34 curated scenarios** (`assets/data/scenarios/seed_list.json`)
   - A1: 6, A2: 8, B1: 8, B2: 7, C1: 5
   - travel: 8, work: 7, social: 7, academic: 5, daily-life: 7
   - 6 featured scenarios
   - All required fields: tags, difficultyRating, isFeatured, completionCount

### Cleanup

8. **Removed old artifacts:**
   - Deleted 3 bundled JSON files (cafe_ordering, job_interview, airport_navigation)
   - Updated pubspec.yaml to reference seed_list.json
   - Created `scripts/seed_scenarios.dart` with Firebase Console upload instructions
   - Updated `home_viewmodel.dart` to use FirestoreScenarioService instead of bundled JSONs

## Deviations from Plan

### Rule 2 — Auto-add missing critical functionality

**Issue: home_viewmodel.dart still referenced old bundled JSON files**
- Found during Task 6 (cleanup verification)
- The home dashboard's recommended scenarios section was still loading from the 3 old JSON files
- Fix: Replaced `_loadBundledScenarios()` with `_loadRecommendedScenarios()` using FirestoreScenarioService
- Files modified: `lib/features/home/viewmodels/home_viewmodel.dart`
- Commit: `397ac27`

### Minor Design Deviation

**Removed `DocumentSnapshot? lastDocument` from state**
- The plan's initial state design included a `lastDocument` cursor for Firestore pagination
- However, the pagination algorithm is client-side list slicing (`_visibleCount`), not Firestore cursor-based
- The field was unused — removed to avoid unnecessary `cloud_firestore` dependency in the ViewModel

### Task 6 Scope Extension

**home_viewmodel.dart was not in the plan's `files_modified` list but needed updating**
- This is consistent with Rule 2 (auto-add missing critical functionality)
- The file now uses FirestoreScenarioService to load recommended scenarios from the full catalog

## Verification

| Check | Result |
|-------|--------|
| `flutter analyze lib/` | 0 errors, 0 warnings, 1 pre-existing info-level note |
| Old JSON files removed | PASS |
| No code references to old files | PASS |
| Seed list: 34 scenarios | PASS |
| Seed list: 5 CEFR levels | PASS |
| Seed list: 5 categories | PASS |
| Seed list: unique IDs | PASS |
| Seed list: 6+ featured | PASS |
| ScenarioService provider registered | PASS |

## Known Stubs

None. The scenario selection screen loads from cache (empty on first launch post-migration until Firestore is seeded, then shows Firestore data). The seed list is a migration artifact for Firestore upload.

## Threat Flags

No new security surface introduced beyond what the plan's threat model covers. Firestore rules enforce public-read/admin-write on `/scenarios`. Cache corruption is handled with try/catch fallback.

## Self-Check: PASSED

- All created files exist at their expected paths
- All commits present in git log
- `flutter analyze lib/` passes with 0 errors
