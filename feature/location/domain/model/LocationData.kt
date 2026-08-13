package com.abdlateef.miqati.feature.location.domain.model

data class LocationData(
    val latitude: Double,
    val longitude: Double,
    val altitude: Double = 0.0,
    val accuracy: Float = 0f,
    val provider: LocationProvider = LocationProvider.GPS,
    val timestamp: Long = System.currentTimeMillis()
)

enum class LocationProvider {
    GPS,
    NETWORK,
    PASSIVE,
    MANUAL
}
