package com.abdlateef.miqati.feature.prayer.presentation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.abdlateef.miqati.core.common.DateUtils
import com.abdlateef.miqati.feature.prayer.domain.model.PrayerName
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import javax.inject.Inject

/**
 * UI State for Prayer Times Screen.
 */
data class PrayerTimesUiState(
    val gregorianDate: String = "",
    val hijriDate: String = "",
    val prayers: List<Pair<PrayerName, String>> = emptyList(),
    val nextPrayer: PrayerName? = null,
    val isLoading: Boolean = true,
    val error: String? = null
)

/**
 * ViewModel for Prayer Times Screen.
 */
@HiltViewModel
class PrayerTimesViewModel @Inject constructor() : ViewModel() {

    private val _uiState = MutableStateFlow(PrayerTimesUiState())
    val uiState: StateFlow<PrayerTimesUiState> = _uiState.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = PrayerTimesUiState()
    )

    init {
        loadPrayerTimes()
    }

    private fun loadPrayerTimes() {
        viewModelScope.launch {
            // In production, this would call a use case to get actual prayer times
            val mockPrayers = getMockPrayerTimes()
            val nextPrayer = determineNextPrayer(mockPrayers)
            
            _uiState.update {
                it.copy(
                    gregorianDate = formatGregorianDate(Date()),
                    hijriDate = formatHijriDate(Date()),
                    prayers = mockPrayers.map { prayer -> prayer.first to formatTime(prayer.second) },
                    nextPrayer = nextPrayer,
                    isLoading = false
                )
            }
        }
    }

    private fun getMockPrayerTimes(): List<Pair<PrayerName, Date>> {
        val calendar = Calendar.getInstance()
        
        return listOf(
            PrayerName.FAJR to calendar.apply { set(Calendar.HOUR_OF_DAY, 5); set(Calendar.MINUTE, 30) }.time,
            PrayerName.SUNRISE to calendar.apply { set(Calendar.HOUR_OF_DAY, 6); set(Calendar.MINUTE, 45) }.time,
            PrayerName.DHUHR to calendar.apply { set(Calendar.HOUR_OF_DAY, 12); set(Calendar.MINUTE, 15) }.time,
            PrayerName.ASR to calendar.apply { set(Calendar.HOUR_OF_DAY, 15); set(Calendar.MINUTE, 30) }.time,
            PrayerName.MAGHRIB to calendar.apply { set(Calendar.HOUR_OF_DAY, 18); set(Calendar.MINUTE, 0) }.time,
            PrayerName.ISHA to calendar.apply { set(Calendar.HOUR_OF_DAY, 19); set(Calendar.MINUTE, 30) }.time
        )
    }

    private fun determineNextPrayer(prayers: List<Pair<PrayerName, Date>>): PrayerName? {
        val now = Date()
        return prayers.find { it.second.after(now) }?.first
    }

    private fun formatGregorianDate(date: Date): String {
        val formatter = SimpleDateFormat("EEEE, MMMM dd, yyyy", Locale.getDefault())
        return formatter.format(date)
    }

    private fun formatHijriDate(date: Date): String {
        // Simplified Hijri date calculation
        val calendar = Calendar.getInstance().apply { time = date }
        val daysSinceEpoch = (calendar.timeInMillis - Calendar.getInstance().apply { 
            set(622, Calendar.JULY, 16) 
        }.timeInMillis) / (1000 * 60 * 60 * 24)
        val lunarYear = (daysSinceEpoch / 354.367).toInt()
        val remainingDays = daysSinceEpoch - (lunarYear * 354.367)
        val lunarMonth = (remainingDays / 29.5).toInt()
        val lunarDay = (remainingDays - (lunarMonth * 29.5)).toInt()
        
        val monthNames = listOf(
            "Muharram", "Safar", "Rabi' al-Awwal", "Rabi' al-Thani",
            "Jumada al-Ula", "Jumada al-Thani", "Rajab", "Sha'ban",
            "Ramadan", "Shawwal", "Dhu al-Qi'dah", "Dhu al-Hijjah"
        )
        
        val monthIndex = lunarMonth % 12
        return "${lunarDay.coerceIn(1, 30)} ${monthNames.getOrElse(monthIndex) { "Unknown" }} ${lunarYear + 1} AH"
    }

    private fun formatTime(date: Date): String {
        val formatter = SimpleDateFormat("h:mm a", Locale.getDefault())
        return formatter.format(date)
    }
}
