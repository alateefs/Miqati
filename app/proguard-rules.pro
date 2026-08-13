# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.kts.

# Keep Adhan models
-keep class com.batoulapps.adhan.** { *; }

# Keep ExoPlayer
-keep class com.google.android.exoplayer2.** { *; }
-keep interface com.google.android.exoplayer2.** { *; }

# Keep DataStore
-keep class androidx.datastore.** { *; }

# Keep Hilt
-keep class dagger.hilt.** { *; }
-keep class javax.inject.** { *; }
-keep class * extends dagger.hilt.android.internal.managers.ComponentSupplier { *; }

# Keep Kotlin Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

# Keep Compose
-keep class androidx.compose.** { *; }
-keepclassmembers class androidx.compose.** { *; }

# Ignore warnings from libraries
-dontwarn com.batoulapps.**
-dontwarn androidx.datastore.**
