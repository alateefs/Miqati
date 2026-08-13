package com.abdlateef.miqati.feature.adhan.domain.repository

import com.abdlateef.miqati.feature.adhan.domain.model.AdhanConfig
import com.abdlateef.miqati.feature.adhan.domain.model.PrayerType
import kotlinx.coroutines.flow.Flow

interface AdhanRepository {
    val adhanConfig: Flow<AdhanConfig>
    
    suspend fun getAdhanConfig(): AdhanConfig
    suspend fun updateAdhanConfig(config: AdhanConfig): Result<Unit>
    suspend fun setPrayerEnabled(prayer: PrayerType, enabled: Boolean): Result<Unit>
    suspend fun setGlobalEnabled(enabled: Boolean): Result<Unit>
    suspend fun playAdhanForPrayer(prayer: PrayerType): Result<Unit>
    suspend fun stopAdhan(): Result<Unit>
}
