package com.abdlateef.miqati.feature.prayer.data.repository

import com.abdlateef.miqati.core.common.Result
import com.abdlateef.miqati.core.common.errorOf
import com.abdlateef.miqati.core.common.successOf
import com.abdlateef.miqati.feature.prayer.domain.model.AsrMethod
import com.abdlateef.miqati.feature.prayer.domain.model.CalculationMethod
import com.abdlateef.miqati.feature.prayer.domain.model.DailyPrayerSchedule
import com.abdlateef.miqati.feature.prayer.domain.model.HighLatitudeRule
import com.abdlateef.miqati.feature.prayer.domain.model.HijriDate
import com.abdlateef.miqati.feature.prayer.domain.model.PrayerCalculationSettings
import com.abdlateef.miqati.feature.prayer.domain.repository.PrayerRepository
import com.batoulapps.adhan.CalculationParameters
import com.batoulapps.adhan.Coordinates
import com.batoulapps.adhan.DateComponents
import com.batoulapps.adhan.Madhab
import com.batoulapps.adhan.Method
import com.batoulapps.adhan.Prayers
import com.batoulapps.adhan.SunTimesCalculator
import java.util.Calendar
import java.util.Date
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Implementation of PrayerRepository using the Adhan library.
 * All calculations are done offline using astronomical formulas.
 */
@Singleton
class PrayerRepositoryImpl @Inject constructor() : PrayerRepository {

    override suspend fun calculatePrayerTimes(
        date: Date,
        latitude: Double,
        longitude: Double,
        timezone: Double,
        settings: PrayerCalculationSettings
    ): Result<DailyPrayerSchedule> {
        return try {
            val calendar = Calendar.getInstance().apply { time = date }
            
            // Convert to DateComponents for Adhan library
            val dateComponents = DateComponents(
                calendar.get(Calendar.YEAR),
                calendar.get(Calendar.MONTH) + 1, // Adhan uses 1-based months
                calendar.get(Calendar.DAY_OF_MONTH)
            )

            // Create coordinates
            val coordinates = Coordinates(latitude, longitude)

            // Build calculation parameters based on settings
            val params = buildCalculationParameters(settings)

            // Calculate prayer times
            val prayers = Prayers(dateComponents, coordinates, params)

            // Extract prayer times as Date objects
            val fajr = prayers.fajr?.let { calendarFrom(it, timezone) }
                ?: return errorOf("Failed to calculate Fajr time")
            val sunrise = prayers.sunrise?.let { calendarFrom(it, timezone) }
                ?: return errorOf("Failed to calculate Sunrise time")
            val dhuhr = prayers.dhuhr?.let { calendarFrom(it, timezone) }
                ?: return errorOf("Failed to calculate Dhuhr time")
            val asr = prayers.asr?.let { calendarFrom(it, timezone) }
                ?: return errorOf("Failed to calculate Asr time")
            val maghrib = prayers.maghrib?.let { calendarFrom(it, timezone) }
                ?: return errorOf("Failed to calculate Maghrib time")
            val isha = prayers.isha?.let { calendarFrom(it, timezone) }
                ?: return errorOf("Failed to calculate Isha time")

            // Calculate Hijri date
            val hijriDate = calculateHijriDate(date)

            successOf(
                DailyPrayerSchedule(
                    date = date,
                    fajr = fajr,
                    sunrise = sunrise,
                    dhuhr = dhuhr,
                    asr = asr,
                    maghrib = maghrib,
                    isha = isha,
                    hijriDate = hijriDate
                )
            )
        } catch (e: Exception) {
            errorOf(e)
        }
    }

    override suspend fun calculateTodayPrayerTimes(
        latitude: Double,
        longitude: Double,
        timezone: Double,
        settings: PrayerCalculationSettings
    ): Result<DailyPrayerSchedule> {
        return calculatePrayerTimes(Date(), latitude, longitude, timezone, settings)
    }

    override suspend fun getPrayerTimesForDays(
        startDate: Date,
        days: Int,
        latitude: Double,
        longitude: Double,
        timezone: Double,
        settings: PrayerCalculationSettings
    ): Result<List<DailyPrayerSchedule>> {
        return try {
            val schedules = mutableListOf<DailyPrayerSchedule>()
            val calendar = Calendar.getInstance().apply { time = startDate }

            for (i in 0 until days) {
                val result = calculatePrayerTimes(
                    date = calendar.time,
                    latitude = latitude,
                    longitude = longitude,
                    timezone = timezone,
                    settings = settings
                )
                
                if (result.isSuccess) {
                    schedules.add(result.getOrNull()!!)
                }
                
                calendar.add(Calendar.DAY_OF_YEAR, 1)
            }

            successOf(schedules)
        } catch (e: Exception) {
            errorOf(e)
        }
    }

    /**
     * Build Adhan CalculationParameters from our settings.
     */
    private fun buildCalculationParameters(settings: PrayerCalculationSettings): CalculationParameters {
        val baseParams = when (settings.method) {
            CalculationMethod.MUSLIM_WORLD_LEAGUE -> Method.MUSLIM_WORLD_LEAGUE
            CalculationMethod.EGYPTIAN -> Method.EGYPTIAN
            CalculationMethod.KARACHI -> Method.KARACHI
            CalculationMethod.UMM_AL_QURA -> Method.UMM_AL_QURA
            CalculationMethod.DUBAI -> Method.DUBAI
            CalculationMethod.MOON_SIGHTING_COMMITTEE -> Method.MOON_SIGHTING_COMMITTEE
            CalculationMethod.ISNA -> Method.NORTH_AMERICA
            CalculationMethod.KUWAIT -> Method.KUWAIT
            CalculationMethod.QATAR -> Method.QATAR
            CalculationMethod.SINGAPORE -> Method.SINGAPORE
            CalculationMethod.TEHRAN -> Method.TEHARAN
            CalculationMethod.TURKEY -> Method.TURKEY
            CalculationMethod.CUSTOM -> Method.MUSLIM_WORLD_LEAGUE // Default for custom
        }.getParameters()

        // Apply Asr method (Madhab)
        baseParams.madhab = when (settings.asrMethod) {
            AsrMethod.STANDARD -> Madhab.SHAFI
            AsrMethod.HANAFI -> Madhab.HANAFI
        }

        // Apply high latitude rule
        baseParams.highLatitudeRule = when (settings.highLatitudeRule) {
            HighLatitudeRule.MIDDLE_OF_NIGHT -> com.batoulapps.adhan.HighLatitudeRule.MIDDLE_OF_THE_NIGHT
            HighLatitudeRule.SEVENTH_OF_NIGHT -> com.batoulapps.adhan.HighLatitudeRule.SEVENTH_OF_THE_NIGHT
            HighLatitudeRule.ANGULAR_BASED -> com.batoulapps.adhan.HighLatitudeRule.ANGLE_BASED
        }

        // Apply manual adjustments
        settings.adjustments.forEach { (prayer, minutes) ->
            when (prayer) {
                com.abdlateef.miqati.feature.prayer.domain.model.PrayerName.FAJR -> 
                    baseParams.adjustments.fajr = minutes
                com.abdlateef.miqati.feature.prayer.domain.model.PrayerName.DHUHR -> 
                    baseParams.adjustments.dhuhr = minutes
                com.abdlateef.miqati.feature.prayer.domain.model.PrayerName.ASR -> 
                    baseParams.adjustments.asr = minutes
                com.abdlateef.miqati.feature.prayer.domain.model.PrayerName.MAGHRIB -> 
                    baseParams.adjustments.maghrib = minutes
                com.abdlateef.miqati.feature.prayer.domain.model.PrayerName.ISHA -> 
                    baseParams.adjustments.isha = minutes
                else -> {} // Sunrise doesn't need adjustment
            }
        }

        return baseParams
    }

    /**
     * Convert Adhan Calendar to Java Date with timezone adjustment.
     */
    private fun calendarFrom(calendar: Calendar, timezoneOffset: Double): Date {
        // Adjust for timezone
        val tzOffsetMillis = (timezoneOffset * 3600 * 1000).toInt()
        return Date(calendar.timeInMillis - tzOffsetMillis)
    }

    /**
     * Calculate approximate Hijri date.
     * Note: This is an approximation. For precise Hijri dates, 
     * actual moon sighting is required.
     */
    private fun calculateHijriDate(gregorianDate: Date): HijriDate {
        val calendar = Calendar.getInstance().apply { time = gregorianDate }
        
        // Simple approximation algorithm
        // The Islamic calendar started on July 16, 622 CE
        val epoch = Calendar.getInstance().apply {
            set(622, Calendar.JULY, 16)
        }
        
        val daysSinceEpoch = (calendar.timeInMillis - epoch.timeInMillis) / (1000 * 60 * 60 * 24)
        val lunarYear = (daysSinceEpoch / 354.367).toInt()
        val remainingDays = daysSinceEpoch - (lunarYear * 354.367)
        val lunarMonth = (remainingDays / 29.5).toInt()
        val lunarDay = (remainingDays - (lunarMonth * 29.5)).toInt()
        
        val monthIndex = lunarMonth % 12
        val year = lunarYear + 1
        
        return HijriDate(
            day = lunarDay.coerceIn(1, 30),
            month = monthIndex + 1,
            year = year,
            monthName = HijriDate.MONTH_NAMES.getOrElse(monthIndex) { "Unknown" },
            weekday = getWeekdayName(calendar.get(Calendar.DAY_OF_WEEK))
        )
    }

    private fun getWeekdayName(dayOfWeek: Int): String {
        return when (dayOfWeek) {
            Calendar.SUNDAY -> "Al-Ahad"
            Calendar.MONDAY -> "Al-Ithnayn"
            Calendar.TUESDAY -> "Al-Thulatha"
            Calendar.WEDNESDAY -> "Al-Arbi'a"
            Calendar.THURSDAY -> "Al-Khamis"
            Calendar.FRIDAY -> "Al-Jumu'ah"
            Calendar.SATURDAY -> "Al-Sabt"
            else -> "Unknown"
        }
    }
}
