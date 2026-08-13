package com.abdlateef.miqati.feature.adhan.domain.model

data class AdhanConfig(
    val isEnabled: Boolean = true,
    val prayerSettings: Map<PrayerType, PrayerAdhanSetting> = defaultPrayerSettings()
)

data class PrayerAdhanSetting(
    val isEnabled: Boolean = true,
    val soundUri: String? = null,
    val volume: Int = 80
)

enum class PrayerType {
    FAJR,
    SUNRISE,
    DHUHR,
    ASR,
    MAGHRIB,
    ISHA
}

fun defaultPrayerSettings(): Map<PrayerType, PrayerAdhanSetting> {
    return PrayerType.entries.associateWith { type ->
        // Disable sunrise by default as it's not a prayer time
        PrayerAdhanSetting(isEnabled = type != PrayerType.SUNRISE)
    }
}
