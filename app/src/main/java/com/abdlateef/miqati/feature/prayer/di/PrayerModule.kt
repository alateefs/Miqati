package com.abdlateef.miqati.feature.prayer.di

import com.abdlateef.miqati.feature.prayer.data.repository.PrayerRepositoryImpl
import com.abdlateef.miqati.feature.prayer.domain.repository.PrayerRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class PrayerModule {

    @Binds
    @Singleton
    abstract fun bindPrayerRepository(
        prayerRepositoryImpl: PrayerRepositoryImpl
    ): PrayerRepository
}
