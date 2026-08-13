package com.abdlateef.miqati.prayer.domain.usecase

import com.abdlateef.miqati.prayer.domain.model.PrayerTime
import com.abdlateef.miqati.prayer.domain.repository.PrayerRepository
import com.batoulapps.adhan.Coordinates
import com.batoulapps.adhan.DateComponents
import com.batoulapps.adhan.Madhab
import com.batoulapps.adhan.Method
import com.batoulapps.adhan.PrayerTimes
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.Calendar
import java.util.TimeZone
import kotlin.test.Test
import kotlin.test.assertTrue
import kotlin.test.assertEquals
import kotlin.test.assertNotNull

/**
 * Unit tests for CalculatePrayerTimesUseCase.
 * Tests pure domain logic without Android dependencies.
 */
class CalculatePrayerTimesUseCaseTest {

    private val mockRepository = object : PrayerRepository {
        override suspend fun getCalculationMethod(): Method = Method.MUSLIM_WORLD_LEAGUE
        override suspend fun getAsrMadhab(): Madhab = Madhab.SHAFI
        override suspend fun saveCalculationMethod(method: Method) {}
        override suspend fun saveAsrMadhab(madhab: Madhab) {}
    }

    private val useCase = CalculatePrayerTimesUseCase(mockRepository)

    @Test
    fun `calculate prayer times returns successful result with 6 prayers`() = kotlinx.coroutines.runBlocking {
        // Given
        val coordinates = Coordinates(21.4225, 39.8262) // Makkah
        val calendar = Calendar.getInstance().apply {
            set(2024, Calendar.JANUARY, 15)
        }

        // When
        val result = useCase(coordinates, calendar)

        // Then
        assertTrue(result.isSuccess)
        val prayerTimes = result.getOrNull()
        assertNotNull(prayerTimes)
        assertEquals(6, prayerTimes.size)
    }

    @Test
    fun `calculate prayer times contains all required prayers`() = kotlinx.coroutines.runBlocking {
        // Given
        val coordinates = Coordinates(21.4225, 39.8262) // Makkah
        
        // When
        val result = useCase(coordinates)

        // Then
        assertTrue(result.isSuccess)
        val prayerTimes = result.getOrNull()
        assertNotNull(prayerTimes)
        
        val prayerNames = prayerTimes.map { it.name }
        assertTrue(prayerNames.contains("Fajr"))
        assertTrue(prayerNames.contains("Sunrise"))
        assertTrue(prayerNames.contains("Dhuhr"))
        assertTrue(prayerNames.contains("Asr"))
        assertTrue(prayerNames.contains("Maghrib"))
        assertTrue(prayerNames.contains("Isha"))
    }

    @Test
    fun `calculate prayer times for different location`() = kotlinx.coroutines.runBlocking {
        // Given
        val coordinates = Coordinates(30.0444, 31.2357) // Cairo
        
        // When
        val result = useCase(coordinates)

        // Then
        assertTrue(result.isSuccess)
        val prayerTimes = result.getOrNull()
        assertNotNull(prayerTimes)
        assertEquals(6, prayerTimes.size)
    }

    @Test
    fun `prayer times are in chronological order`() = kotlinx.coroutines.runBlocking {
        // Given
        val coordinates = Coordinates(21.4225, 39.8262) // Makkah
        
        // When
        val result = useCase(coordinates)

        // Then
        assertTrue(result.isSuccess)
        val prayerTimes = result.getOrNull()
        assertNotNull(prayerTimes)
        
        // Check that times are in order (excluding sunrise which is between Fajr and Dhuhr)
        val fajrIndex = prayerTimes.indexOfFirst { it.name == "Fajr" }
        val dhuhrIndex = prayerTimes.indexOfFirst { it.name == "Dhuhr" }
        val asrIndex = prayerTimes.indexOfFirst { it.name == "Asr" }
        val maghribIndex = prayerTimes.indexOfFirst { it.name == "Maghrib" }
        val ishaIndex = prayerTimes.indexOfFirst { it.name == "Isha" }
        
        assertTrue(fajrIndex < dhuhrIndex)
        assertTrue(dhuhrIndex < asrIndex)
        assertTrue(asrIndex < maghribIndex)
        assertTrue(maghribIndex < ishaIndex)
    }
}
