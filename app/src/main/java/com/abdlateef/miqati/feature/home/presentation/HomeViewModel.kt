package com.abdlateef.miqati.feature.home.presentation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.abdlateef.miqati.core.common.DateUtils
import com.abdlateef.miqati.feature.prayer.domain.model.PrayerName
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import javax.inject.Inject

/**
 * UI State for Home Screen.
 */
data class HomeUiState(
    val nextPrayer: PrayerName? = null,
    val countdown: String = "--:--:--",
    val gregorianDate: String = "",
    val hijriDate: String = "",
    val todayPrayers: List<Pair<PrayerName, String>> = emptyList(),
    val isLoading: Boolean = true,
    val error: String? = null
)

/**
 * ViewModel for Home Screen.
 * Manages UI state and handles business logic.
 */
@HiltViewModel
class HomeViewModel @Inject constructor() : ViewModel() {

    private val _uiState = MutableStateFlow(HomeUiState())
    
    @OptIn(FlowPreview::class)
    val uiState: StateFlow<HomeUiState> = combine(
        _uiState,
        kotlinx.coroutines.flow.flow {
            while (true) {
                emit(Date())
                kotlinx.coroutines.delay(1000)
            }
        }
    ) { state, currentTime ->
        state.copy(
            countdown = calculateCountdown(state.nextPrayer, currentTime),
            gregorianDate = updateGregorianDate(currentTime),
            hijriDate = updateHijriDate(currentTime)
        )
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = HomeUiState()
    )

    init {
        loadTodayPrayerTimes()
        startCountdownTimer()
    }

    private fun loadTodayPrayerTimes() {
        viewModelScope.launch {
            // Simulate loading prayer times
            // In production, this would call a use case
            _uiState.update { currentState ->
                val mockPrayers = getMockPrayerTimes()
                val nextPrayer = determineNextPrayer(mockPrayers)
                
                currentState.copy(
                    todayPrayers = mockPrayers.map { it.first to formatTime(it.second) },
                    nextPrayer = nextPrayer,
                    isLoading = false
                )
            }
        }
    }

    private fun startCountdownTimer() {
        viewModelScope.launch {
            while (true) {
                kotlinx.coroutines.delay(1000)
                val currentTime = Date()
                val currentState = _uiState.value
                val nextPrayerTime = getNextPrayerTime(currentState.nextPrayer, currentTime)
                
                val countdown = if (nextPrayerTime != null) {
                    val diff = nextPrayerTime.time - currentTime.time
                    formatCountdown(diff)
                } else {
                    "--:--:--"
                }
                
                _uiState.update { it.copy(countdown = countdown) }
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

    private fun getNextPrayerTime(nextPrayer: PrayerName?, now: Date): Date? {
        if (nextPrayer == null) return null
        
        val mockPrayers = getMockPrayerTimes()
        return mockPrayers.find { it.first == nextPrayer }?.second
    }

    private fun calculateCountdown(nextPrayer: PrayerName?, currentTime: Date): String {
        val nextPrayerTime = getNextPrayerTime(nextPrayer, currentTime)
        return if (nextPrayerTime != null) {
            val diff = nextPrayerTime.time - currentTime.time
            formatCountdown(diff)
        } else {
            "--:--:--"
        }
    }

    private fun formatCountdown(millis: Long): String {
        if (millis < 0) return "--:--:--"
        
        val hours = (millis / (1000 * 60 * 60)).toInt()
        val minutes = ((millis % (1000 * 60 * 60)) / (1000 * 60)).toInt()
        val seconds = ((millis % (1000 * 60)) / 1000).toInt()
        
        return String.format(Locale.getDefault(), "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private fun updateGregorianDate(date: Date): String {
        val formatter = SimpleDateFormat("EEEE, MMMM dd, yyyy", Locale.getDefault())
        return formatter.format(date)
    }

    private fun updateHijriDate(date: Date): String {
        // Simplified Hijri date calculation
        val calendar = Calendar.getInstance().apply { time = date }
        val daysSinceEpoch = (calendar.timeInMillis - Calendar.getInstance().apply { set(622, Calendar.JULY, 16) }.timeInMillis) / (1000 * 60 * 60 * 24)
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
