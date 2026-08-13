package com.abdlateef.miqati.feature.location.data.repository

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.os.Looper
import androidx.core.content.ContextCompat
import com.abdlateef.miqati.feature.location.domain.model.LocationData
import com.abdlateef.miqati.feature.location.domain.model.LocationProvider
import com.abdlateef.miqati.feature.location.domain.repository.LocationRepository
import com.google.android.gms.location.*
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class LocationRepositoryImpl @Inject constructor(
    @ApplicationContext private val context: Context,
    private val fusedLocationClient: FusedLocationProviderClient
) : LocationRepository {

    private val _currentLocation = MutableStateFlow<LocationData?>(null)
    override val currentLocation: Flow<LocationData?> = _currentLocation.asStateFlow()

    private val locationRequest = LocationRequest.Builder(
        Priority.PRIORITY_HIGH_ACCURACY,
        10000
    ).apply {
        setMinUpdateIntervalMillis(5000)
        setWaitForAccurateLocation(true)
    }.build()

    override suspend fun getLastKnownLocation(): LocationData? {
        return try {
            if (!hasLocationPermission()) return null
            
            val location = fusedLocationClient.lastLocation.await()
            location?.toLocationData(LocationProvider.GPS)
        } catch (e: Exception) {
            null
        }
    }

    override suspend fun requestLocationUpdate(): Result<LocationData> {
        return try {
            if (!hasLocationPermission()) {
                return Result.failure(SecurityException("Location permission not granted"))
            }

            // Try to get last known location first
            val lastLocation = getLastKnownLocation()
            if (lastLocation != null) {
                _currentLocation.value = lastLocation
                return Result.success(lastLocation)
            }

            // Request fresh location
            callbackFlow {
                val locationCallback = object : LocationCallback() {
                    override fun onLocationResult(result: LocationResult) {
                        result.lastLocation?.let { location ->
                            val locationData = location.toLocationData(LocationProvider.GPS)
                            _currentLocation.value = locationData
                            trySend(locationData)
                            close()
                        }
                    }

                    override fun onLocationAvailability(availability: LocationAvailability) {
                        if (!availability.isLocationAvailable) {
                            trySend(Result.failure(Exception("Location not available")))
                            close()
                        }
                    }
                }

                fusedLocationClient.requestLocationUpdates(
                    locationRequest,
                    locationCallback,
                    Looper.getMainLooper()
                )

                awaitClose {
                    fusedLocationClient.removeLocationUpdates(locationCallback)
                }
            }.awaitFirstOrNull() ?: Result.failure(Exception("Failed to get location"))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun saveManualLocation(latitude: Double, longitude: Double): Result<Unit> {
        return try {
            val locationData = LocationData(
                latitude = latitude,
                longitude = longitude,
                provider = LocationProvider.MANUAL,
                timestamp = System.currentTimeMillis()
            )
            _currentLocation.value = locationData
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun clearManualLocation(): Result<Unit> {
        return try {
            _currentLocation.value = null
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun isUsingManualLocation(): Boolean {
        return _currentLocation.value?.provider == LocationProvider.MANUAL
    }

    override suspend fun getSavedLocation(): LocationData? {
        return _currentLocation.value
    }

    private fun hasLocationPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED ||
                ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                ) == PackageManager.PERMISSION_GRANTED
    }

    private fun Location.toLocationData(provider: LocationProvider): LocationData {
        return LocationData(
            latitude = latitude,
            longitude = longitude,
            altitude = altitude,
            accuracy = accuracy,
            provider = provider,
            timestamp = time
        )
    }
}
