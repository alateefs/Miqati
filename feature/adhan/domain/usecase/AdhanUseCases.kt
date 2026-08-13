package com.abdlateef.miqati.feature.adhan.domain.usecase

import com.abdlateef.miqati.feature.adhan.domain.model.AdhanConfig
import com.abdlateef.miqati.feature.adhan.domain.model.PrayerType
import com.abdlateef.miqati.feature.adhan.domain.repository.AdhanRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

class GetAdhanConfigUseCase @Inject constructor(
    private val repository: AdhanRepository
) {
    suspend operator fun invoke(): AdhanConfig {
        return repository.getAdhanConfig()
    }
}

class ObserveAdhanConfigUseCase @Inject constructor(
    private val repository: AdhanRepository
) {
    operator fun invoke(): Flow<AdhanConfig> {
        return repository.adhanConfig
    }
}

class SetPrayerAdhanEnabledUseCase @Inject constructor(
    private val repository: AdhanRepository
) {
    suspend operator fun invoke(prayer: PrayerType, enabled: Boolean): Result<Unit> {
        return repository.setPrayerEnabled(prayer, enabled)
    }
}

class SetGlobalAdhanEnabledUseCase @Inject constructor(
    private val repository: AdhanRepository
) {
    suspend operator fun invoke(enabled: Boolean): Result<Unit> {
        return repository.setGlobalEnabled(enabled)
    }
}

class PlayAdhanUseCase @Inject constructor(
    private val repository: AdhanRepository
) {
    suspend operator fun invoke(prayer: PrayerType): Result<Unit> {
        return repository.playAdhanForPrayer(prayer)
    }
}

class StopAdhanUseCase @Inject constructor(
    private val repository: AdhanRepository
) {
    suspend operator fun invoke(): Result<Unit> {
        return repository.stopAdhan()
    }
}
