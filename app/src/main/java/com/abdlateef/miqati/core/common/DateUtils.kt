package com.abdlateef.miqati.core.common

import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

/**
 * Utility functions for date and time formatting.
 * All formatting is locale-aware and supports RTL languages.
 */
object DateUtils {

    /**
     * Format a date to Gregorian string.
     */
    fun formatGregorian(date: Date, pattern: String = "MMMM dd, yyyy"): String {
        val formatter = SimpleDateFormat(pattern, Locale.getDefault())
        return formatter.format(date)
    }

    /**
     * Format a time to 12-hour format with AM/PM.
     */
    fun formatTime(date: Date, pattern: String = "h:mm a"): String {
        val formatter = SimpleDateFormat(pattern, Locale.getDefault())
        return formatter.format(date)
    }

    /**
     * Get current day of week (1 = Sunday, 7 = Saturday).
     */
    fun getCurrentDayOfWeek(): Int {
        return Calendar.getInstance().get(Calendar.DAY_OF_WEEK)
    }

    /**
     * Check if a date is today.
     */
    fun isToday(date: Date): Boolean {
        val today = Calendar.getInstance()
        val dateCal = Calendar.getInstance().apply { time = date }
        return today.get(Calendar.YEAR) == dateCal.get(Calendar.YEAR) &&
                today.get(Calendar.DAY_OF_YEAR) == dateCal.get(Calendar.DAY_OF_YEAR)
    }

    /**
     * Get the start of day for a given date.
     */
    fun getStartOfDay(date: Date): Date {
        val calendar = Calendar.getInstance().apply {
            time = date
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        return calendar.time
    }

    /**
     * Get the end of day for a given date.
     */
    fun getEndOfDay(date: Date): Date {
        val calendar = Calendar.getInstance().apply {
            time = date
            set(Calendar.HOUR_OF_DAY, 23)
            set(Calendar.MINUTE, 59)
            set(Calendar.SECOND, 59)
            set(Calendar.MILLISECOND, 999)
        }
        return calendar.time
    }

    /**
     * Add days to a date.
     */
    fun addDays(date: Date, days: Int): Date {
        val calendar = Calendar.getInstance().apply {
            time = date
            add(Calendar.DAY_OF_YEAR, days)
        }
        return calendar.time
    }
}
