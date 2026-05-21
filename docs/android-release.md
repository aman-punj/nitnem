# Android Release Build Notes

## Overview

Release APKs are built with R8 minification enabled (`minifyEnabled true` in `build.gradle`). This strips unused classes — including those accessed only via reflection by Flutter plugins — so ProGuard keep rules must be maintained alongside any new plugin additions.

## Build Command

```bash
cd mobile_app
flutter build apk --release
```

## Signing

Signing config is loaded from `mobile_app/android/key.properties` (not committed). Format:

```properties
keyAlias=<alias>
keyPassword=<password>
storeFile=<path-to-keystore>
storePassword=<password>
```

The release `signingConfig` in `build.gradle` reads this file.

## ProGuard Rules

Rules are in `mobile_app/android/app/proguard-rules.pro`.

### Rule when adding a new plugin

If the app hangs on the splash screen in a release build after adding a new Flutter plugin, the most likely cause is R8 stripping a plugin's native Java/Kotlin class. Add a keep rule:

```proguard
-keep class com.package.name.of.plugin.** { *; }
-dontwarn com.package.name.of.plugin.**
```

### Current plugin keep rules

| Plugin | Package kept |
|---|---|
| flutter_timezone | `com.flutter_timezone.**` |
| permission_handler | `com.baseflow.permissionhandler.**` |
| home_widget | `es.antonborri.home_widget.**` |
| flutter_local_notifications | `com.dexterous.flutterlocalnotifications.**` |
| just_audio / audio_session | `com.ryanheise.**` |
| ExoPlayer | `com.google.android.exoplayer2.**` |
| Firebase | `com.google.firebase.**` |
| Google Play Services | `com.google.android.gms.**` |

## Common Logcat Warnings (Not Bugs)

### `SecurityException: Unknown calling package name 'com.google.android.gms'`
### `API: Phenotype.API is not available on this device`

These appear in logcat from `GoogleApiManager` and `FlagRegistrar`. They are GMS-internal IPC failures from the Phenotype (feature flagging) system and occur on:
- Emulators without fully configured GMS
- Devices after a GMS update pending restart
- Certain custom ROM environments

**They do not affect Firebase, Crashlytics, FCM, or any app functionality.** They cannot be suppressed from application code. Ignore them.

### How to distinguish a real ProGuard crash from these warnings

A ProGuard-caused splash freeze will have NO Flutter/Dart output in logcat — the engine loads (`FlutterJNI`, `FlutterActivity` logs appear) but `flutter` tagged logs never appear and the first frame is never rendered.

A GMS warning freeze (if any) would show Crashlytics and Firebase initializing normally alongside the GMS errors.

## Debugging a Release Build

1. Build with `shrinkResources false` first to isolate ProGuard vs resource issues.
2. Temporarily set `minifyEnabled false` — if the freeze goes away, it's a missing keep rule.
3. Check `mobile_app/build/outputs/mapping/release/usage.txt` to see what R8 removed.
4. Search for the plugin's Android package name in `usage.txt` to confirm it was stripped.
