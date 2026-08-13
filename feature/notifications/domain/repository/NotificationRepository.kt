package com.abdlateef.miqati.feature.notifications.domain.repository

import com.abdlateef.miqati.feature.notifications.domain.model.NotificationConfig
import com.abdlateef.miqati.feature.notifications.domain.model.PrayerNotificationType
import kotlinx.coroutines.flow.Flow

interface NotificationRepository {
    val notificationConfig: Flow<NotificationConfig>
    
    suspend fun getNotificationConfig(): NotificationConfig
    suspend fun updateNotificationConfig(config: NotificationConfig): Result<Unit>
    suspend fun setPrayerNotificationEnabled(prayer: PrayerNotificationType, enabled: Boolean): Result<Unit>
    suspend fun setGlobalEnabled(enabled: Boolean): Result<Unit>
    suspend fun schedulePrayerNotifications(): Result<Unit>
    suspend fun cancelAllNotifications(): Result<Unit>
}
