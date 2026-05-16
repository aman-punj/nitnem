# ---------------- Flutter ----------------

-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

-keep class * extends io.flutter.app.FlutterApplication { *; }

-keep class * implements io.flutter.plugin.common.PluginRegistry$PluginRegistrantCallback {
    *;
}

-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin {
    *;
}

# ---------------- Firebase / GMS ----------------

-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ---------------- Notifications ----------------

-keep class com.dexterous.flutterlocalnotifications.** { *; }

# ---------------- Audio ----------------

-keep class com.ryanheise.** { *; }
-dontwarn com.ryanheise.**

-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# ---------------- Kotlin ----------------

-keep class kotlin.Metadata { *; }

# ---------------- Reflection / Serialization ----------------

-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# ---------------- Enum Safety ----------------

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}