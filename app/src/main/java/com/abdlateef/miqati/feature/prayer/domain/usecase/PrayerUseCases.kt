package com.abdlateef.miqati.feature.prayer.domain.usecase

import com.abdlateef.miqati.core.common.Result
import com.abdlateef.miqati.feature.prayer.domain.model.DailyPrayerSchedule
import com.abdlateef.miqati.feature.prayer.domain.model.PrayerCalculationSettings
import com.abdlateef.miqati.feature.prayer.domain.repository.PrayerRepository
import java.util.Date
import javax.inject.Inject

/**
 * Use case for calculating today's prayer times.
 * Follows single responsibility principle.
 */
class GetTodayPrayerTimes @Inject constructor(
    private val prayerRepository: PrayerRepository
) {
    suspend operator fun invoke(
        latitude: Double,
        longitude: Double,
        timezone: Double,
        settings: PrayerCalculationSettings = PrayerCalculationSettings()
    ): Result<DailyPrayerSchedule> {
        return prayerRepository.calculateTodayPrayerTimes(
            latitude = latitude,
            longitude = longitude,
            timezone = timezone,
            settings = settings
        )
    }
}

/**
 * Use case for calculating prayer times for a specific date.
 */
class CalculatePrayerTimes @Inject constructor(
    private val prayerRepository: PrayerRepository
) {
    suspend operator fun invoke(
        date: Date,
        latitude: Double,
        longitude: Double,
        timezone: Double,
        settings: PrayerCalculationSettings = PrayerCalculationSettings()
    ): Result<DailyPrayerSchedule> {
        return prayerRepository.calculatePrayerTimes(
            date = date,
            latitude = latitude,
            longitude = longitude,
            timezone = timezone,
            settings = settings
        )
    }
}

/**
 * Use case for getting prayer times for multiple days.
 */
class GetPrayerTimesForDays @Inject constructor(
    private val prayerRepository: PrayerRepository
) {
    suspend operator fun invoke(
        startDate: Date,
        days: Int,
        latitude: Double,
        longitude: Double,
        timezone: Double,
        settings: PrayerCalculationSettings = PrayerCalculationSettings()
    ): Result<List<DailyPrayerSchedule>> {
        return prayerRepository.getPrayerTimesForDays(
            startDate = startDate,
            days = days,
            latitude = latitude,
            longitude = longitude,
            timezone = timezone,
            settings = settings
        )
    }
}
