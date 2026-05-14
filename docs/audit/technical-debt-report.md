# Technical Debt Report

## Overview
This report highlights areas in the Bani Sagar codebase that require refactoring or cleanup to prevent future maintenance headaches.

## 1. Controller Overloading (Mobile)
- **Problem:** `PrayerController` handles UI state, business logic (mode switching), audio playback controls (`just_audio`), sync negotiation, and scroll positioning (`ScrollablePositionedList`).
- **Impact:** Makes testing difficult, increases risk of bugs when modifying audio logic, and hurts readability.
- **Solution:** Extract audio management into a dedicated `AudioPlaybackService`. Extract scroll syncing logic into a `TranscriptScrollManager`.

## 2. Incomplete Migrations & Hardcoded Values
- **Problem:** `firebase_service.dart` contains TODOs for mapping `AppConfig` to a unified interface.
- **Problem:** Some values, like the application ID in `build.gradle` or feedback submission endpoints in `feedback_controller.dart`, are hardcoded or marked with TODOs.
- **Problem:** Transcript segment JSON parsing handles multiple historical key formats (`start` vs `startTime`, `text` vs `pa`), indicating unsafe/legacy parsing logic that needs consolidation.

## 3. UI Inconsistencies & Architecture Drift
- **Problem:** While the `core/design_system` exists, some screens still hardcode styling or padding values instead of referencing `AppTokens`.
- **Problem:** The Theme setup file (`sacred_dark_theme.dart`) is a massive monolith.
- **Impact:** Upgrading or tweaking the design system becomes an error-prone search-and-replace operation.

## 4. Admin Panel State Management
- **Problem:** `AdminApp.tsx` contains too much state (search, items, drag-and-drop, remote config, forms).
- **Problem:** Error states are represented by basic strings and lack unified toast notifications.
- **Solution:** Introduce a proper state management/query library (e.g., React Query) and break down `AdminApp.tsx` into smaller, focused container components.

## 5. Storage Leaks
- **Problem:** `TranscriptSyncService` downloads new tracks but does not delete old track audio files if the active track changes.
- **Impact:** Over time, the app's local storage footprint will bloat unnecessarily.
- **Solution:** Implement a cache eviction or garbage collection routine for unreferenced local files.

## 6. Duplicated/Coupled Systems
- **Problem:** Firestore content models contain nested `tracks` and `VersionedFile` maps. If the app needs to query all tracks independently, this nested structure will be a bottleneck.
