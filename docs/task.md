You are a senior Android + Flutter release engineering expert.

I have a Flutter app that works correctly in:

* debug mode
* locally built release APKs

But the app hangs/crashes on native splash ONLY when the release APK is built from GitHub Actions CI.

Important findings:

* Issue started after enabling:
  minifyEnabled true
* Disabling minifyEnabled fixes the issue.
* Flutter engine loads successfully in logs.
* No Dart/Flutter exceptions appear.
* App hangs after MainActivity launch.
* Firebase/Google Play Services logs show:

  * DEVELOPER_ERROR
  * SecurityException
  * Unknown calling package name 'com.google.android.gms'
* CI builds are done using:
  flutter build apk --release

Current Android release config:

```gradle
release {
    signingConfig = signingConfigs.debug
    minifyEnabled true
    proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
}
```

GitHub Actions build pipeline:

```yaml
- name: Build Android APK
  run: flutter build apk --release
```

Tech stack/plugins likely involved:

* Firebase
* flutter_local_notifications
* audio/background services
* just_audio / audio_service related plugins
* Kotlin + Java 17
* Flutter stable

I need you to:

1. Identify the MOST likely root cause.
2. Determine whether this is:

   * Proguard/R8 stripping
   * signing mismatch
   * Firebase SHA mismatch
   * CI environment mismatch
   * resource shrinking issue
   * plugin reflection stripping
3. Generate a COMPLETE fix.
4. Generate:

   * corrected build.gradle
   * recommended proguard-rules.pro
   * proper release signing setup
   * CI-safe GitHub Actions workflow
5. Include keep rules for:

   * Flutter
   * Firebase
   * Google Play Services
   * notifications
   * audio/background services
6. Explain WHY CI builds fail while local builds work.
7. Include verification/debugging steps.
8. Suggest best practices for Flutter Android release builds and CI/CD.

Do NOT give generic advice.
Provide production-ready fixes with exact code/config changes.
Focus heavily on R8/Proguard + Flutter release build behavior in CI environments.
