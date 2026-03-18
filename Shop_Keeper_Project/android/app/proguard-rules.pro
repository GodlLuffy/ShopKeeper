# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase ProGuard Rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Service specific
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.firebase.firestore.** { *; }
-keep class com.google.firebase.storage.** { *; }

# Add any additional rules for plugins used
-keep class com.ryanheise.audio_session.** { *; }

# Ignore Play Core warnings (often triggered by R8 and certain Flutter versions)
-dontwarn com.google.android.play.core.**
