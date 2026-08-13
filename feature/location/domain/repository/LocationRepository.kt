package com.abdlateef.miqati.feature.location.domain.repository

import com.abdlateef.miqati.feature.location.domain.model.LocationData
import kotlinx.coroutines.flow.Flow

interface LocationRepository {
    val currentLocation: Flow<LocationData?>
    
    suspend fun getLastKnownLocation(): LocationData?
    suspend fun requestLocationUpdate(): Result<LocationData>
    suspend fun saveManualLocation(latitude: Double, longitude: Double): Result<Unit>
    suspend fun clearManualLocation(): Result<Unit>
    suspend fun isUsingManualLocation(): Boolean
    suspend fun getSavedLocation(): LocationData?
}
