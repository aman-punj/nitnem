# Mobile Architecture Audit

## Overview
The mobile app is built using **Flutter** and **GetX** for state management and dependency injection. The architecture follows a feature-centric structure with a strong offline-first design.

## Core Stack
- **Framework:** Flutter
- **State Management:** GetX
- **Audio Playback:** `just_audio`
- **Data persistence:** `shared_preferences`
- **Networking/Sync:** `http` and Firebase Firestore/Storage

## Project Structure (`mobile_app/lib/`)
- `/bindings`: Dependency injection bindings (`di.dart`).
- `/controllers`: GetX controllers managing business logic and UI state (`home_controller.dart`, `prayer_controller.dart`, `preference_controller.dart`).
- `/core/design_system`: Centralized design system with tokens, themes, and reusable widgets.
- `/models`: Data models (`content_item.dart`, `app_config_model.dart`, `transcript_segment.dart`).
- `/screens`: UI views (`home_screen.dart`, `prayer_page.dart`, `splash_screen.dart`).
- `/services`: Core services for fetching content, syncing, and parsing transcripts (`firebase_content_service.dart`, `transcript_sync_service.dart`, `local_content_service.dart`).

## Key Flows
- **Initialization:** App starts at `main.dart`, initializes Firebase and `SharedPrefsService`, then sets up DI via `DependencyInjection.init()`. Starts on `SplashScreen`, then transitions to `HomeScreen`.
- **Prayer Flow:** `PrayerPage` relies on `PrayerController`. It supports a "listen" mode and a "read" mode (with standard and focus reading styles). Syncs current playback time to the transcript segments.
- **Audio Engine:** Handled by `PrayerController` wrapping `AudioPlayer` (`just_audio`). Supports variable playback speeds, skipping, and position tracking.

## Technical Debt & Observations
- **Coupling in Controllers:** Controllers like `PrayerController` are large and handle fetching, state management, syncing logic checks, and audio engine control.
- **State Management:** GetX is deeply integrated throughout the app.
- **Scroll Synchronization:** Synchronizing the highlighted transcript to the audio uses `ScrollablePositionedList` and threshold-based visibility checks which can be complex and sometimes janky.

## Summary
The mobile architecture is practical and well-suited for the immediate offline-first requirements. The primary area for improvement is decoupling audio logic from UI state and transcript syncing within the controllers.
