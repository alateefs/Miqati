package com.abdlateef.miqati.feature.prayer.domain.repository

import com.abdlateef.miqati.core.common.Result
import com.abdlateef.miqati.feature.prayer.domain.model.DailyPrayerSchedule
import com.abdlateef.miqati.feature.prayer.domain.model.PrayerCalculationSettings
import java.util.Date

/**
 * Repository interface for prayer time calculations.
 * Defines the contract for prayer calculation operations.
 */
interface PrayerRepository {

    /**
     * Calculate prayer times for a specific date and location.
     * @param date The date to calculate for
     * @param latitude Location latitude
     * @param longitude Location longitude
     * @param timezone Timezone offset in hours
     * @param settings Calculation settings
     * @return Result containing the daily prayer schedule or error
     */
    suspend fun calculatePrayerTimes(
        date: Date,
        latitude: Double,
        longitude: Double,
        timezone: Double,
        settings: PrayerCalculationSettings = PrayerCalculationSettings()
    ): Result<DailyPrayerSchedule>

    /**
     * Calculate prayer times for today.
     */
    suspend fun calculateTodayPrayerTimes(
        latitude: Double,
        longitude: Double,
        timezone: Double,
        settings: PrayerCalculationSettings = PrayerCalculationSettings()
    ): Result<DailyPrayerSchedule>

    /**
     * Get prayer times for multiple days.
     * @param startDate Start date
     * @param days Number of days
     */
    suspend fun getPrayerTimesForDays(
        startDate: Date,
        days: Int,
        latitude: Double,
        longitude: Double,
        timezone: Double,
        settings: PrayerCalculationSettings = PrayerCalculationSettings()
    ): Result<List<DailyPrayerSchedule>>
}
