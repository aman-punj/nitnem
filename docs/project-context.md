# Nitnem Project Context

This document provides a high-level overview for new developers and AI agents to quickly understand the system's purpose, structure, and key architectural principles.

## Purpose

Nitnem delivers Sikh daily prayers (Nitnem) with offline-first audio playback and synchronized Punjabi lyrics. Content is managed remotely via Firebase and a React admin panel.

## Key Technologies

| Layer | Technology |
|---|---|
| Mobile | Flutter (Dart) |
| State management | GetX |
| Audio | just_audio + just_audio_background |
| Firebase | Firestore, Messaging, Analytics, Crashlytics, Storage |
| Notifications | flutter_local_notifications + flutter_timezone |
| Home widgets | home_widget |
| Admin panel | React + Vite (TypeScript) |
| Audio hosting | Cloudinary |

## Repository Structure

```
nitnem/
├── mobile_app/      Flutter app
├── admin_panel/     React dashboard
├── backend/         Backend services
├── shared/          Shared schemas and transcript samples
└── docs/            This documentation
```

## Architectural Principles

- **Offline-First:** Audio files are downloaded permanently to device storage, not streamed.
- **Firebase-Driven:** Firestore holds all prayer metadata and config; RemoteConfig used for feature flags.
- **Sync Engine:** Periodic background sync keeps local content updated from Firebase.
- **Component-Based:** Reusable Flutter widgets enforce design system consistency.
- **Timezone-Aware Notifications:** Scheduled local notifications (6:00 AM / 6:30 PM) use `flutter_timezone` for correct device-local scheduling.

## Android Release Build

Release builds use R8/ProGuard minification. The `proguard-rules.pro` file must include keep rules for every Flutter plugin with native Android code. See [android-release.md](android-release.md) for full details.

## Documentation Index

- [Terminology](terminology.md) — key terms
- [Issues](issue.md) — open tasks and known issues
- [Android Release Notes](android-release.md) — ProGuard, signing, CI guidance
