# Environment Setup

## 1) Admin Panel (React)

This project uses Vite environment variables for the React admin panel.

### Create `.env`

From the repository root:

```bash
cp admin_panel/.env.example admin_panel/.env
```

Then fill values in `admin_panel/.env`.

... (rest of admin panel section) ...

## 2) Mobile App (Flutter)

The Flutter app is located in `mobile_app/`.

### Prerequisites
- Flutter SDK installed.
- Android Studio / Xcode for native builds.

### Setup
1. `cd mobile_app`
2. `flutter pub get`
3. Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are present in their respective native directories if not managed via FlutterFire CLI.

### Run
```bash
flutter run
```

## 2) Required Variables

```env
VITE_FIREBASE_API_KEY=
VITE_FIREBASE_AUTH_DOMAIN=
VITE_FIREBASE_PROJECT_ID=
VITE_FIREBASE_STORAGE_BUCKET=
VITE_FIREBASE_MESSAGING_SENDER_ID=
VITE_FIREBASE_APP_ID=

VITE_CLOUDINARY_CLOUD_NAME=
VITE_CLOUDINARY_AUDIO_UPLOAD_PRESET=nitnem_audio`r`nVITE_CLOUDINARY_TRANSCRIPT_UPLOAD_PRESET=nitnem_transcripts
```

## 3) Where Firebase Values Come From

Open Firebase Console:
1. Project Settings
2. General tab
3. Your apps section (Web app)
4. Copy SDK config fields into matching `VITE_FIREBASE_*` keys.

## 4) Where Cloudinary Values Come From

Open Cloudinary Console:
1. Dashboard -> copy `Cloud name`
2. Settings -> Upload -> Upload presets -> use preset name
3. Put them in:
- `VITE_CLOUDINARY_CLOUD_NAME`
- `VITE_CLOUDINARY_AUDIO_UPLOAD_PRESET`

## 5) Vite Env Rules

- Vite only exposes variables prefixed with `VITE_` to browser code.
- Variables without `VITE_` are not available in `import.meta.env` on client.
- After changing `.env`, restart Vite dev server.

## 6) Validation Behavior

The admin panel reads env values from `admin_panel/src/config/env.ts`.
- Missing required variables throw a clear startup error.
- No secrets are hardcoded in source.

## 7) Safety

- `admin_panel/.env` is gitignored.
- Commit only `admin_panel/.env.example` with placeholders.
