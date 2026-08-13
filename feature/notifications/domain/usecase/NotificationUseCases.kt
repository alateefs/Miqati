package com.abdlateef.miqati.feature.notifications.domain.usecase

import com.abdlateef.miqati.feature.notifications.domain.model.NotificationConfig
import com.abdlateef.miqati.feature.notifications.domain.model.PrayerNotificationType
import com.abdlateef.miqati.feature.notifications.domain.repository.NotificationRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

class GetNotificationConfigUseCase @Inject constructor(
    private val repository: NotificationRepository
) {
    suspend operator fun invoke(): NotificationConfig {
        return repository.getNotificationConfig()
    }
}

class ObserveNotificationConfigUseCase @Inject constructor(
    private val repository: NotificationRepository
) {
    operator fun invoke(): Flow<NotificationConfig> {
        return repository.notificationConfig
    }
}

class SetPrayerNotificationEnabledUseCase @Inject constructor(
    private val repository: NotificationRepository
) {
    suspend operator fun invoke(prayer: PrayerNotificationType, enabled: Boolean): Result<Unit> {
        return repository.setPrayerNotificationEnabled(prayer, enabled)
    }
}

class SetGlobalNotificationEnabledUseCase @Inject constructor(
    private val repository: NotificationRepository
) {
    suspend operator fun invoke(enabled: Boolean): Result<Unit> {
        return repository.setGlobalEnabled(enabled)
    }
}

class SchedulePrayerNotificationsUseCase @Inject constructor(
    private val repository: NotificationRepository
) {
    suspend operator fun invoke(): Result<Unit> {
        return repository.schedulePrayerNotifications()
    }
}

class CancelAllNotificationsUseCase @Inject constructor(
    private val repository: NotificationRepository
) {
    suspend operator fun invoke(): Result<Unit> {
        return repository.cancelAllNotifications()
    }
}
