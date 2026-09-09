# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Supabase & GoTrue reflection safety
-keepattributes *Annotation*,EnclosingMethod,Signature
-keep class com.google.gson.** { *; }
-dontwarn okio.**
-dontwarn javax.annotation.**