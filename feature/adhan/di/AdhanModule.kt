package com.abdlateef.miqati.feature.adhan.di

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import com.abdlateef.miqati.feature.adhan.data.player.AudioPlayer
import com.abdlateef.miqati.feature.adhan.data.player.ExoAudioPlayer
import com.abdlateef.miqati.feature.adhan.data.repository.AdhanRepositoryImpl
import com.abdlateef.miqati.feature.adhan.domain.repository.AdhanRepository
import dagger.Binds
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class AdhanModule {

    @Binds
    @Singleton
    abstract fun bindAdhanRepository(
        impl: AdhanRepositoryImpl
    ): AdhanRepository

    @Binds
    @Singleton
    abstract fun bindAudioPlayer(
        impl: ExoAudioPlayer
    ): AudioPlayer

    companion object {
        @Provides
        @Singleton
        fun provideDataStore(
            @ApplicationContext context: Context
        ): DataStore<Preferences> {
            return context.createDataStore()
        }
    }
}
