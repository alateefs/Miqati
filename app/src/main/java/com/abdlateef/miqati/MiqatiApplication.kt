package com.abdlateef.miqati

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

/**
 * Application class for Miqati.
 * HiltAndroidApp enables Hilt dependency injection throughout the app.
 */
@HiltAndroidApp
class MiqatiApp : Application() {
    override fun onCreate() {
        super.onCreate()
        // No analytics, tracking, or initialization of external services
        // This app is offline-first and privacy-focused
    }
}
