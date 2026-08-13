package com.abdlateef.miqati.feature.prayer.domain.model

import java.util.Date

/**
 * Represents a single prayer time.
 */
data class PrayerTime(
    val name: PrayerName,
    val time: Date,
    val isNext: Boolean = false,
    val isCurrent: Boolean = false
)

/**
 * Enum representing the five daily prayers plus sunrise.
 */
enum class PrayerName {
    FAJR,
    SUNRISE,
    DHUHR,
    ASR,
    MAGHRIB,
    ISHA
}

/**
 * Represents a full day's prayer schedule.
 */
data class DailyPrayerSchedule(
    val date: Date,
    val fajr: Date,
    val sunrise: Date,
    val dhuhr: Date,
    val asr: Date,
    val maghrib: Date,
    val isha: Date,
    val hijriDate: HijriDate? = null
) {
    fun getPrayerTimes(): List<PrayerTime> {
        return listOf(
            PrayerTime(PrayerName.FAJR, fajr),
            PrayerTime(PrayerName.SUNRISE, sunrise),
            PrayerTime(PrayerName.DHUHR, dhuhr),
            PrayerTime(PrayerName.ASR, asr),
            PrayerTime(PrayerName.MAGHRIB, maghrib),
            PrayerTime(PrayerName.ISHA, isha)
        )
    }

    fun getNextPrayer(currentTime: Date = Date()): PrayerTime? {
        val prayers = getPrayerTimes()
        // Find the first prayer that is after current time
        val nextPrayer = prayers.find { it.time.after(currentTime) }
        return nextPrayer?.copy(isNext = true)
    }

    fun getCurrentPrayer(currentTime: Date = Date()): PrayerTime? {
        val prayers = getPrayerTimes().reversed()
        // Find the last prayer that has already passed
        return prayers.find { it.time.before(currentTime) }?.copy(isCurrent = true)
    }
}

/**
 * Represents an Islamic (Hijri) date.
 */
data class HijriDate(
    val day: Int,
    val month: Int,
    val year: Int,
    val monthName: String,
    val weekday: String
) {
    companion object {
        val MONTH_NAMES = listOf(
            "Muharram", "Safar", "Rabi' al-Awwal", "Rabi' al-Thani",
            "Jumada al-Ula", "Jumada al-Thani", "Rajab", "Sha'ban",
            "Ramadan", "Shawwal", "Dhu al-Qi'dah", "Dhu al-Hijjah"
        )
    }
}

/**
 * Prayer calculation settings.
 */
data class PrayerCalculationSettings(
    val method: CalculationMethod = CalculationMethod.MUSLIM_WORLD_LEAGUE,
    val asrMethod: AsrMethod = AsrMethod.STANDARD,
    val highLatitudeRule: HighLatitudeRule = HighLatitudeRule.MIDDLE_OF_NIGHT,
    val adjustments: Map<PrayerName, Int> = emptyMap() // in minutes
)

/**
 * Supported calculation methods.
 */
enum class CalculationMethod(val id: String, val displayName: String) {
    MUSLIM_WORLD_LEAGUE("MWL", "Muslim World League"),
    EGYPTIAN("EGYPT", "Egyptian General Authority"),
    KARACHI("KARACHI", "University of Islamic Sciences, Karachi"),
    UMM_AL_QURA("UMMALQURA", "Umm al-Qura University, Makkah"),
    DUBAI("DUBAI", "Dubai"),
    MOON_SIGHTING_COMMITTEE("MOON", "Moon Sighting Committee"),
    ISNA("ISNA", "Islamic Society of North America"),
    KUWAIT("KUWAIT", "Kuwait"),
    QATAR("QATAR", "Qatar"),
    SINGAPORE("SINGAPORE", "Majlis Ugama Islam Singapura"),
    TEHRAN("TEHRAN", "Institute of Geophysics, Tehran"),
    TURKEY("TURKEY", "Diyanet İşleri Başkanlığı, Turkey"),
    CUSTOM("CUSTOM", "Custom")
}

/**
 * Asr calculation method (juristic).
 */
enum class AsrMethod(val id: String, val displayName: String) {
    STANDARD("STANDARD", "Standard (Shafi'i, Maliki, Hanbali)"),
    HANAFI("HANAFI", "Hanafi")
}

/**
 * High latitude adjustment rule.
 */
enum class HighLatitudeRule(val id: String, val displayName: String) {
    MIDDLE_OF_NIGHT("MIDDLE", "Middle of the Night"),
    SEVENTH_OF_NIGHT("SEVENTH", "One Seventh of the Night"),
    ANGULAR_BASED("ANGULAR", "Angle Based")
}
