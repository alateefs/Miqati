# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /usr/local/Cellar/android-sdk/24.3.3/tools/proguard/proguard-android.txt

# Keep Adhan library classes
-keep class com.batoulapps.adhan.** { *; }

# Keep Kotlin coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

# Keep Hilt generated classes
-keep class dagger.hilt.** { *; }
-keep class javax.inject.** { *; }
-keep class * extends dagger.hilt.android.internal.managers.ComponentSupplier { *; }

# Keep DataStore
-keep class androidx.datastore.** { *; }

# Keep ExoPlayer / Media3
-keep class androidx.media3.** { *; }
-keep class com.google.android.exoplayer2.** { *; }

# Keep Compose
-keep class androidx.compose.** { *; }

# Keep model classes
-keep class com.abdlateef.miqati.** { *; }

# Keep OSMDroid
-keep class org.osmdroid.** { *; }

# Keep enum fields
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep parcelable creators
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}
