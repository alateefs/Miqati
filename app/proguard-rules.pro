# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /usr/local/Cellar/android-sdk/24.3.3/tools/proguard/proguard-android.txt

# Keep Adhan models
-keep class com.batoulapps.adhan.** { *; }

# Keep Hilt generated classes
-keep class dagger.hilt.** { *; }
-keep class javax.inject.** { *; }

# Keep DataStore
-keep class androidx.datastore.** { *; }

# Keep Media3 ExoPlayer
-keep class androidx.media3.** { *; }

# Keep OSMDroid
-keep class org.osmdroid.** { *; }
