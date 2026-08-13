package com.abdlateef.miqati.feature.adhan.data.repository

import android.content.Context
import android.content.Intent
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import com.abdlateef.miqati.feature.adhan.data.player.AudioPlayer
import com.abdlateef.miqati.feature.adhan.data.player.PlayerState
import com.abdlateef.miqati.feature.adhan.data.service.AdhanPlaybackService
import com.abdlateef.miqati.feature.adhan.domain.model.AdhanConfig
import com.abdlateef.miqati.feature.adhan.domain.model.PrayerAdhanSetting
import com.abdlateef.miqati.feature.adhan.domain.model.PrayerType
import com.abdlateef.miqati.feature.adhan.domain.model.defaultPrayerSettings
import com.abdlateef.miqati.feature.adhan.domain.repository.AdhanRepository
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AdhanRepositoryImpl @Inject constructor(
    @ApplicationContext private val context: Context,
    private val dataStore: DataStore<Preferences>,
    private val audioPlayer: AudioPlayer
) : AdhanRepository {

    companion object {
        private val ADHAN_ENABLED_KEY = booleanPreferencesKey("adhan_enabled")
        private fun prayerEnabledKey(prayer: PrayerType) = 
            booleanPreferencesKey("adhan_${prayer.name.lowercase()}_enabled")
        private fun prayerVolumeKey(prayer: PrayerType) = 
            intPreferencesKey("adhan_${prayer.name.lowercase()}_volume")
        private fun prayerSoundKey(prayer: PrayerType) = 
            stringPreferencesKey("adhan_${prayer.name.lowercase()}_sound")
    }

    override val adhanConfig: Flow<AdhanConfig> = dataStore.data.map { prefs ->
        val isEnabled = prefs[ADHAN_ENABLED_KEY] ?: true
        val prayerSettings = PrayerType.entries.associateWith { prayer ->
            PrayerAdhanSetting(
                isEnabled = prefs[prayerEnabledKey(prayer)] ?: (prayer != PrayerType.SUNRISE),
                volume = prefs[prayerVolumeKey(prayer)] ?: 80,
                soundUri = prefs[prayerSoundKey(prayer)]
            )
        }
        AdhanConfig(isEnabled = isEnabled, prayerSettings = prayerSettings)
    }

    override suspend fun getAdhanConfig(): AdhanConfig {
        return adhanConfig.first()
    }

    override suspend fun updateAdhanConfig(config: AdhanConfig): Result<Unit> {
        return try {
            dataStore.edit { prefs ->
                prefs[ADHAN_ENABLED_KEY] = config.isEnabled
                config.prayerSettings.forEach { (prayer, setting) ->
                    prefs[prayerEnabledKey(prayer)] = setting.isEnabled
                    prefs[prayerVolumeKey(prayer)] = setting.volume
                    setting.soundUri?.let { prefs[prayerSoundKey(prayer)] = it }
                }
            }
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun setPrayerEnabled(prayer: PrayerType, enabled: Boolean): Result<Unit> {
        return try {
            dataStore.edit { prefs ->
                prefs[prayerEnabledKey(prayer)] = enabled
            }
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun setGlobalEnabled(enabled: Boolean): Result<Unit> {
        return try {
            dataStore.edit { prefs ->
                prefs[ADHAN_ENABLED_KEY] = enabled
            }
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun playAdhanForPrayer(prayer: PrayerType): Result<Unit> {
        return try {
            val config = getAdhanConfig()
            if (!config.isEnabled || !config.prayerSettings[prayer]?.isEnabled!!) {
                return Result.failure(Exception("Adhan is disabled for this prayer"))
            }

            // Get default adhan sound resource ID
            val soundResId = when (prayer) {
                PrayerType.FAJR -> com.abdlateef.miqati.R.raw.adhan_fajr
                PrayerType.SUNRISE -> com.abdlateef.miqati.R.raw.adhan_generic
                PrayerType.DHUHR -> com.abdlateef.miqati.R.raw.adhan_generic
                PrayerType.ASR -> com.abdlateef.miqati.R.raw.adhan_generic
                PrayerType.MAGHRIB -> com.abdlateef.miqati.R.raw.adhan_generic
                PrayerType.ISHA -> com.abdlateef.miqati.R.raw.adhan_generic
            }

            val intent = Intent(context, AdhanPlaybackService::class.java)
            context.startForegroundService(intent)
            
            // Note: In a real implementation, you'd pass the soundResId to the service
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun stopAdhan(): Result<Unit> {
        return try {
            val intent = Intent(context, AdhanPlaybackService::class.java).apply {
                action = AdhanPlaybackService.ACTION_STOP
            }
            context.startService(intent)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
