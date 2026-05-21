# Nitnem

A Sikh daily prayer (Nitnem) mobile application with offline-first audio playback, synchronized lyrics, and a React-based admin panel for content management.

## Repository Structure

```
nitnem/
├── mobile_app/      Flutter mobile application (Android/iOS)
├── admin_panel/     React + Vite administration dashboard
├── backend/         Backend services
├── shared/          Shared schemas and transcript samples
├── docs/            Technical documentation
└── firebase.json    Firebase project configuration
```

## Tech Stack

### Mobile App
| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State management | GetX |
| Audio | just_audio + just_audio_background |
| Firebase | Core, Firestore, Messaging, Analytics, Crashlytics, Storage |
| Notifications | flutter_local_notifications |
| Timezone | flutter_timezone |
| Home widgets | home_widget |
| Permissions | permission_handler |

### Admin Panel
| Layer | Technology |
|---|---|
| Framework | React + Vite (TypeScript) |
| Auth | Firebase Auth |
| Database | Firebase Firestore |
| Storage | Cloudinary |

## Getting Started

### Prerequisites
- Flutter SDK (^3.6.2)
- Node.js 18+
- Firebase project with `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

### Mobile App
```bash
cd mobile_app
flutter pub get
# Place google-services.json in mobile_app/android/app/
flutter run
```

### Admin Panel
```bash
cd admin_panel
npm install
cp .env.example .env   # fill in Firebase config values
npm run dev
```

## Android Release Builds

The release build uses R8 minification (`minifyEnabled true`). ProGuard rules are maintained in [mobile_app/android/app/proguard-rules.pro](mobile_app/android/app/proguard-rules.pro) and cover:

- Flutter engine and plugin registration
- Firebase / Google Play Services
- flutter_local_notifications + Gson
- Audio (just_audio / ExoPlayer)
- flutter_timezone
- permission_handler
- home_widget
- App widget providers

**Note:** The `SecurityException: Unknown calling package name 'com.google.android.gms'` warnings visible in logcat are a benign GMS/Phenotype API issue on certain devices and emulators. They do not affect app functionality.

To build a release APK:
```bash
cd mobile_app
flutter build apk --release
```

## Documentation

See the [`docs/`](docs/) directory for:
- [Terminology](docs/terminology.md) — key terms used across the project
- [Issues](docs/issue.md) — open issues and tasks
- [Android Release Notes](docs/android-release.md) — ProGuard, signing, and CI build guidance
- [Project Context](docs/project-context.md) — architecture overview

Current version: **1.0.23+26**
