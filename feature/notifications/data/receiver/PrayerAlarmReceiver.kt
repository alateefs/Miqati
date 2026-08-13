package com.abdlateef.miqati.feature.notifications.data.receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class PrayerAlarmReceiver : BroadcastReceiver() {
    
    companion object {
        const val EXTRA_PRAYER_NAME = "extra_prayer_name"
        const val ACTION_PRAYER_ALARM = "com.abdlateef.miqati.PRAYER_ALARM"
    }

    @Inject
    lateinit var notificationScheduler: NotificationScheduler

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION_PRAYER_ALARM) {
            val prayerName = intent.getStringExtra(EXTRA_PRAYER_NAME) ?: return
            notificationScheduler.showPrayerNotification(context, prayerName)
        }
    }
}
