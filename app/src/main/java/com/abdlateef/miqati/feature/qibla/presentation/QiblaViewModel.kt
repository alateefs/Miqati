package com.abdlateef.miqati.feature.qibla.presentation

import android.hardware.SensorManager
import android.location.Location
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import javax.inject.Inject
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * UI State for Qibla Screen.
 */
data class QiblaUiState(
    val qiblaDirection: Float = 0f,
    val deviceDirection: Float = 0f,
    val isCalibrated: Boolean = false,
    val sensorAccuracy: Int? = null,
    val distanceToKaaba: Double? = null,
    val error: String? = null
)

/**
 * ViewModel for Qibla Screen.
 * Handles sensor data and calculates Qibla direction with magnetic declination correction.
 */
@HiltViewModel
class QiblaViewModel @Inject constructor() : ViewModel() {

    private val _uiState = MutableStateFlow(QiblaUiState())
    val uiState: StateFlow<QiblaUiState> = _uiState.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = QiblaUiState()
    )

    // Kaaba coordinates (Mecca)
    private val kaabaLatitude = 21.4225
    private val kaabaLongitude = 39.8262

    // Current location (should be injected from repository in production)
    private var currentLatitude: Double = 0.0
    private var currentLongitude: Double = 0.0

    /**
     * Process rotation vector sensor data to get device orientation.
     */
    fun onRotationVectorChanged(rotationVector: FloatArray) {
        if (rotationVector.size < 4) return

        // Convert rotation vector to rotation matrix
        val rotationMatrix = FloatArray(9)
        SensorManager.getRotationMatrixFromVector(rotationMatrix, rotationVector)

        // Get orientation angles
        val orientationAngles = FloatArray(3)
        SensorManager.getOrientation(rotationMatrix, orientationAngles)

        // Convert azimuth (device direction) to degrees
        val azimuthDegrees = Math.toDegrees(orientationAngles[0].toDouble()).toFloat()
        val normalizedAzimuth = (azimuthDegrees + 360) % 360

        // Calculate magnetic declination and adjust
        val declination = calculateMagneticDeclination(currentLatitude, currentLongitude)
        val trueNorthDirection = (normalizedAzimuth + declination + 360) % 360

        // Calculate Qibla direction from current location
        val qiblaBearing = calculateQiblaBearing(
            currentLatitude,
            currentLongitude,
            kaabaLatitude,
            kaabaLongitude
        )

        _uiState.update { state ->
            state.copy(
                deviceDirection = trueNorthDirection,
                qiblaDirection = qiblaBearing,
                isCalibrated = true,
                distanceToKaaba = calculateDistanceToKaaba(currentLatitude, currentLongitude)
            )
        }
    }

    /**
     * Handle sensor accuracy changes.
     */
    fun onAccuracyChanged(accuracy: Int) {
        _uiState.update { state ->
            state.copy(
                sensorAccuracy = accuracy,
                isCalibrated = accuracy == SensorManager.SENSOR_STATUS_ACCURACY_HIGH
            )
        }
    }

    /**
     * Set current location for Qibla calculation.
     */
    fun setLocation(latitude: Double, longitude: Double) {
        currentLatitude = latitude
        currentLongitude = longitude
        
        // Recalculate distance when location changes
        val distance = calculateDistanceToKaaba(latitude, longitude)
        _uiState.update { state ->
            state.copy(distanceToKaaba = distance)
        }
    }

    /**
     * Calculate Qibla bearing using the great circle formula.
     * Returns bearing in degrees from North (0-360).
     */
    private fun calculateQiblaBearing(
        lat1: Double,
        lon1: Double,
        lat2: Double,
        lon2: Double
    ): Float {
        val lat1Rad = Math.toRadians(lat1)
        val lat2Rad = Math.toRadians(lat2)
        val deltaLonRad = Math.toRadians(lon2 - lon1)

        val y = sin(deltaLonRad) * cos(lat2Rad)
        val x = cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(deltaLonRad)

        val bearingRad = atan2(y, x)
        var bearingDeg = Math.toDegrees(bearingRad).toFloat()

        // Normalize to 0-360
        bearingDeg = (bearingDeg + 360) % 360

        return bearingDeg
    }

    /**
     * Calculate magnetic declination (approximation).
     * In production, use World Magnetic Model (WMM) for accurate values.
     */
    private fun calculateMagneticDeclination(latitude: Double, longitude: Double): Float {
        // Simplified approximation
        // Real implementation should use WMM or IGRF models
        val declination = when {
            longitude < -30 -> 10f
            longitude < 0 -> 5f
            longitude < 30 -> 0f
            longitude < 60 -> -5f
            longitude < 90 -> -10f
            else -> -15f
        }
        
        // Adjust based on latitude
        val latAdjustment = (latitude / 90) * 5f
        
        return declination + latAdjustment
    }

    /**
     * Calculate distance to Kaaba using Haversine formula.
     * Returns distance in kilometers.
     */
    private fun calculateDistanceToKaaba(lat1: Double, lon1: Double): Double {
        return haversineDistance(lat1, lon1, kaabaLatitude, kaabaLongitude)
    }

    /**
     * Haversine formula for calculating great-circle distance.
     */
    private fun haversineDistance(
        lat1: Double,
        lon1: Double,
        lat2: Double,
        lon2: Double
    ): Double {
        val earthRadiusKm = 6371.0

        val dLat = Math.toRadians(lat2 - lat1)
        val dLon = Math.toRadians(lon2 - lon1)

        val a = sin(dLat / 2).pow(2) +
                cos(Math.toRadians(lat1)) * cos(Math.toRadians(lat2)) *
                sin(dLon / 2).pow(2)

        val c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return earthRadiusKm * c
    }

    private fun Double.pow(exponent: Int): Double {
        return Math.pow(this, exponent.toDouble())
    }
}
