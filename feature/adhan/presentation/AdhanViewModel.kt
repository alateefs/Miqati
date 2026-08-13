package com.abdlateef.miqati.feature.adhan.presentation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.abdlateef.miqati.feature.adhan.domain.model.AdhanConfig
import com.abdlateef.miqati.feature.adhan.domain.model.PrayerType
import com.abdlateef.miqati.feature.adhan.domain.usecase.*
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

data class AdhanUiState(
    val config: AdhanConfig? = null,
    val isLoading: Boolean = false,
    val isPlaying: Boolean = false,
    val error: String? = null
)

@HiltViewModel
class AdhanViewModel @Inject constructor(
    private val getAdhanConfigUseCase: GetAdhanConfigUseCase,
    private val observeAdhanConfigUseCase: ObserveAdhanConfigUseCase,
    private val setPrayerAdhanEnabledUseCase: SetPrayerAdhanEnabledUseCase,
    private val setGlobalAdhanEnabledUseCase: SetGlobalAdhanEnabledUseCase,
    private val playAdhanUseCase: PlayAdhanUseCase,
    private val stopAdhanUseCase: StopAdhanUseCase
) : ViewModel() {

    val uiState: StateFlow<AdhanUiState> = observeAdhanConfigUseCase()
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = null
        )
        .let { flow ->
            kotlinx.coroutines.flow.combine(flow) { config ->
                AdhanUiState(config = config)
            }.stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5000),
                initialValue = AdhanUiState()
            )
        }

    fun toggleGlobalEnabled(enabled: Boolean) {
        viewModelScope.launch {
            setGlobalAdhanEnabledUseCase(enabled)
                .onFailure { error ->
                    // Handle error
                }
        }
    }

    fun togglePrayerEnabled(prayer: PrayerType, enabled: Boolean) {
        viewModelScope.launch {
            setPrayerAdhanEnabledUseCase(prayer, enabled)
                .onFailure { error ->
                    // Handle error
                }
        }
    }

    fun playAdhan(prayer: PrayerType) {
        viewModelScope.launch {
            playAdhanUseCase(prayer)
                .onFailure { error ->
                    // Handle error
                }
        }
    }

    fun stopAdhan() {
        viewModelScope.launch {
            stopAdhanUseCase()
                .onFailure { error ->
                    // Handle error
                }
        }
    }

    fun dismissError() {
        // Implement error dismissal
    }
}
