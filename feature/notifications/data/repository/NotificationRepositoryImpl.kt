package com.abdlateef.miqati.feature.notifications.data.repository

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import com.abdlateef.miqati.feature.notifications.data.scheduler.AlarmScheduler
import com.abdlateef.miqati.feature.notifications.domain.model.NotificationConfig
import com.abdlateef.miqati.feature.notifications.domain.model.PrayerNotificationSetting
import com.abdlateef.miqati.feature.notifications.domain.model.PrayerNotificationType
import com.abdlateef.miqati.feature.notifications.domain.model.defaultPrayerNotifications
import com.abdlateef.miqati.feature.notifications.domain.repository.NotificationRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class NotificationRepositoryImpl @Inject constructor(
    private val dataStore: DataStore<Preferences>,
    private val alarmScheduler: AlarmScheduler
) : NotificationRepository {

    companion object {
        private val NOTIFICATIONS_ENABLED_KEY = booleanPreferencesKey("notifications_enabled")
        private val USE_EXACT_ALARMS_KEY = booleanPreferencesKey("use_exact_alarms")
        
        private fun prayerEnabledKey(prayer: PrayerNotificationType) = 
            booleanPreferencesKey("notification_${prayer.name.lowercase()}_enabled")
        private fun prayerBeforeMinutesKey(prayer: PrayerNotificationType) = 
            intPreferencesKey("notification_${prayer.name.lowercase()}_before_minutes")
        private fun prayerVibrateKey(prayer: PrayerNotificationType) = 
            booleanPreferencesKey("notification_${prayer.name.lowercase()}_vibrate")
        private fun prayerSoundKey(prayer: PrayerNotificationType) = 
            booleanPreferencesKey("notification_${prayer.name.lowercase()}_sound")
    }

    override val notificationConfig: Flow<NotificationConfig> = dataStore.data.map { prefs ->
        val isEnabled = prefs[NOTIFICATIONS_ENABLED_KEY] ?: true
        val useExactAlarms = prefs[USE_EXACT_ALARMS_KEY] ?: true
        val prayerNotifications = PrayerNotificationType.entries.associateWith { prayer ->
            PrayerNotificationSetting(
                isEnabled = prefs[prayerEnabledKey(prayer)] ?: true,
                notifyBeforeMinutes = prefs[prayerBeforeMinutesKey(prayer)] ?: 0,
                vibrate = prefs[prayerVibrateKey(prayer)] ?: true,
                sound = prefs[prayerSoundKey(prayer)] ?: true
            )
        }
        NotificationConfig(
            isEnabled = isEnabled,
            useExactAlarms = useExactAlarms,
            prayerNotifications = prayerNotifications
        )
    }

    override suspend fun getNotificationConfig(): NotificationConfig {
        return notificationConfig.first()
    }

    override suspend fun updateNotificationConfig(config: NotificationConfig): Result<Unit> {
        return try {
            dataStore.edit { prefs ->
                prefs[NOTIFICATIONS_ENABLED_KEY] = config.isEnabled
                prefs[USE_EXACT_ALARMS_KEY] = config.useExactAlarms
                config.prayerNotifications.forEach { (prayer, setting) ->
                    prefs[prayerEnabledKey(prayer)] = setting.isEnabled
                    prefs[prayerBeforeMinutesKey(prayer)] = setting.notifyBeforeMinutes
                    prefs[prayerVibrateKey(prayer)] = setting.vibrate
                    prefs[prayerSoundKey(prayer)] = setting.sound
                }
            }
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun setPrayerNotificationEnabled(
        prayer: PrayerNotificationType, 
        enabled: Boolean
    ): Result<Unit> {
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
                prefs[NOTIFICATIONS_ENABLED_KEY] = enabled
            }
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun schedulePrayerNotifications(): Result<Unit> {
        return try {
            // Implementation requires prayer times data
            // This would iterate through today's prayer times and schedule alarms
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun cancelAllNotifications(): Result<Unit> {
        return try {
            alarmScheduler.cancelAllNotifications()
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
