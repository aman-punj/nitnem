# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class * extends io.flutter.app.FlutterApplication { *; }
-keep class * extends io.flutter.plugin.common.PluginRegistry$PluginRegistrantCallback { *; }

# Firebase & Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Audio & Notification Plugins (just_audio, audio_service)
-keep class com.ryanheise.** { *; }
-dontwarn com.ryanheise.**
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# General
-dontwarn io.flutter.plugins.**
-keep class * implements io.flutter.plugin.common.Plugin { *; }
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
