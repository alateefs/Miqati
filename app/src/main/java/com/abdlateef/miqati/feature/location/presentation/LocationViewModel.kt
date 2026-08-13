package com.abdlateef.miqati.feature.location.presentation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.abdlateef.miqati.feature.location.domain.model.LocationData
import com.abdlateef.miqati.feature.location.domain.usecase.*
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

data class LocationUiState(
    val location: LocationData? = null,
    val isLoading: Boolean = false,
    val error: String? = null,
    val isManualLocation: Boolean = false
)

@HiltViewModel
class LocationViewModel @Inject constructor(
    private val getLocationUseCase: GetLocationUseCase,
    private val getSavedLocationUseCase: GetSavedLocationUseCase,
    private val saveManualLocationUseCase: SaveManualLocationUseCase,
    private val clearManualLocationUseCase: ClearManualLocationUseCase,
    private val observeLocationUseCase: ObserveLocationUseCase
) : ViewModel() {

    private val _uiState = StateFlow(LocationUiState())
    val uiState: StateFlow<LocationUiState> = observeLocationUseCase()
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = null
        )
        .let { flow ->
            // Combine with StateFlow for additional UI state
            kotlinx.coroutines.flow.combine(flow, _uiState) { location, state ->
                state.copy(
                    location = location,
                    isManualLocation = location?.provider?.name == "MANUAL"
                )
            }.stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5000),
                initialValue = LocationUiState()
            )
        }

    fun requestLocation() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            getLocationUseCase()
                .onSuccess { location ->
                    _uiState.value = _uiState.value.copy(
                        location = location,
                        isLoading = false
                    )
                }
                .onFailure { error ->
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        error = error.message ?: "Failed to get location"
                    )
                }
        }
    }

    fun setManualLocation(latitude: Double, longitude: Double) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            saveManualLocationUseCase(latitude, longitude)
                .onSuccess {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        isManualLocation = true
                    )
                }
                .onFailure { error ->
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        error = error.message ?: "Failed to save location"
                    )
                }
        }
    }

    fun clearManualLocation() {
        viewModelScope.launch {
            clearManualLocationUseCase()
                .onSuccess {
                    _uiState.value = _uiState.value.copy(isManualLocation = false)
                }
                .onFailure { error ->
                    _uiState.value = _uiState.value.copy(
                        error = error.message ?: "Failed to clear location"
                    )
                }
        }
    }

    fun dismissError() {
        _uiState.value = _uiState.value.copy(error = null)
    }
}
