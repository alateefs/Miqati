package com.abdlateef.miqati.feature.location.domain.usecase

import com.abdlateef.miqati.feature.location.domain.model.LocationData
import com.abdlateef.miqati.feature.location.domain.repository.LocationRepository
import javax.inject.Inject

class GetLocationUseCase @Inject constructor(
    private val repository: LocationRepository
) {
    suspend operator fun invoke(): Result<LocationData> {
        return repository.requestLocationUpdate()
    }
}

class GetSavedLocationUseCase @Inject constructor(
    private val repository: LocationRepository
) {
    suspend operator fun invoke(): LocationData? {
        return repository.getSavedLocation()
    }
}

class SaveManualLocationUseCase @Inject constructor(
    private val repository: LocationRepository
) {
    suspend operator fun invoke(latitude: Double, longitude: Double): Result<Unit> {
        return repository.saveManualLocation(latitude, longitude)
    }
}

class ClearManualLocationUseCase @Inject constructor(
    private val repository: LocationRepository
) {
    suspend operator fun invoke(): Result<Unit> {
        return repository.clearManualLocation()
    }
}

class ObserveLocationUseCase @Inject constructor(
    private val repository: LocationRepository
) {
    operator fun invoke() = repository.currentLocation
}
