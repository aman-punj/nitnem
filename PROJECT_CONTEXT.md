# Nitnem Project Context

## Overview

Nitnem is a Sikh prayer application with:

* offline-first audio playback (files downloaded permanently, not streamed)
* synchronized prayer lyrics (Punjabi; Hindi/English planned)
* remotely updateable content via Firebase
* local notifications for daily prayers
* React-based admin panel for content management

---

## Repository Structure

* `/mobile_app` — Flutter mobile application (Android/iOS)
* `/admin_panel` — React/Vite administration dashboard
* `/backend` — Backend services
* `/shared` — Shared schemas, examples, and transcript samples
* `/docs` — Technical documentation
* `firebase.json` — Firebase configuration (root)
* `PROJECT_CONTEXT.md` — This file (AI memory)

---

## Mobile Stack

* Flutter (Dart, SDK ^3.6.2)
* GetX (state management)
* just_audio + just_audio_background (audio playback)
* Firebase Core, Firestore, Messaging, Analytics, Crashlytics, Storage
* flutter_local_notifications
* flutter_timezone (timezone-aware scheduling)
* permission_handler
* home_widget (Android/iOS home screen widgets)
* wakelock_plus
* shared_preferences
* scrollable_positioned_list (transcript sync scrolling)
* google_fonts
* package_info_plus, url_launcher, share_plus, image_picker, path_provider

---

## Admin Stack

* React + Vite (TypeScript)
* Firebase Auth
* Firebase Firestore
* Cloudinary (audio/image uploads)

---

## Current Transcript Format

Input format:
```
[00:09.16]ਆਦਿ ਸਚੁ ਜੁਗਾਦਿ ਸਚੁ ॥
```

Parsed format:
```json
[
  {
    "start": 9.16,
    "end": 10.45,
    "pa": "ਆਦਿ ਸਚੁ ਜੁਗਾਦਿ ਸਚੁ ॥",
    "hi": "",
    "en": ""
  }
]
```

Rules:
* `end` = next segment start
* Punjabi currently enabled
* Hindi/English planned

---

## Architecture Decisions

* Audio files are downloaded permanently to local storage — NOT streamed
* Cloudinary hosts audio source files
* Firebase Firestore stores metadata and config
* Multi-language transcript support planned
* Dynamic/server-driven home screen planned
* Notification schedules are device-local (6:00 AM Japji Sahib, 6:30 PM Rehras Sahib)

---

## Android Build Notes

Release builds use R8 minification (`minifyEnabled true`). ProGuard rules in `mobile_app/android/app/proguard-rules.pro` must be updated whenever a new native-bridge Flutter plugin is added.

Packages that needed explicit keep rules (not bundled with consumer rules):
* `flutter_timezone` — `com.flutter_timezone.**`
* `permission_handler` — `com.baseflow.permissionhandler.**`
* `home_widget` — `es.antonborri.home_widget.**`

The `SecurityException: Unknown calling package name 'com.google.android.gms'` logcat warnings are a device/emulator GMS configuration issue — benign, not fixable from app code.

---

## Implemented Features

* Transcript parser abstraction
* Transcript sync engine with ScrollablePositionedList
* Offline asset service (permanent local audio storage)
* Track metadata model
* Prayer update/sync service
* React admin panel scaffold
* Timing tool scaffold
* Env infrastructure (dotenv)
* Firebase env config abstraction
* Firebase Crashlytics + Analytics
* Firebase Cloud Messaging (push notifications)
* Firebase Storage integration
* Local notifications (flutter_local_notifications + flutter_timezone)
* Home screen widgets (home_widget)
* Admin login with email/password auth

---

## Pending Work

* Cloudinary upload flow in admin panel
* Firestore content management UI
* Dynamic prayer catalog
* Transcript timing workflow improvements
* Offline asset syncing refinement
* Feature flags
* Multi-language transcript support (Hindi, English)
* Configurable notification text from admin panel
* Design tokens audit across all screens

---

## Important Rules

* Do NOT run `flutter analyze`, `dart analyze`, `dart format`, `npm run build`, `flutter build` automatically
* Do NOT rewrite existing playback logic unnecessarily
* Prefer incremental refactors
* Keep Flutter widgets modular
* Avoid GlobalKey-heavy scrolling
* Prefer indexed scrolling approaches
* Always update `proguard-rules.pro` when adding a new Flutter plugin with native Android code

---

## Long-Term Goal

The app should support:
* remotely configurable prayers
* multiple tracks per prayer
* YouTube Live content
* dynamic content types
* offline-first playback
* synchronized multilingual subtitles
