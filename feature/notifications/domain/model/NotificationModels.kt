package com.abdlateef.miqati.feature.notifications.domain.model

data class NotificationConfig(
    val isEnabled: Boolean = true,
    val useExactAlarms: Boolean = true,
    val prayerNotifications: Map<PrayerNotificationType, PrayerNotificationSetting> = defaultPrayerNotifications()
)

data class PrayerNotificationSetting(
    val isEnabled: Boolean = true,
    val notifyBeforeMinutes: Int = 0,
    val vibrate: Boolean = true,
    val sound: Boolean = true
)

enum class PrayerNotificationType {
    FAJR,
    SUNRISE,
    DHUHR,
    ASR,
    MAGHRIB,
    ISHA
}

fun defaultPrayerNotifications(): Map<PrayerNotificationType, PrayerNotificationSetting> {
    return PrayerNotificationType.entries.associateWith { type ->
        PrayerNotificationSetting(
            isEnabled = true,
            notifyBeforeMinutes = 0,
            vibrate = true,
            sound = true
        )
    }
}
