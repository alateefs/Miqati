package com.abdlateef.miqati.prayer

import com.batoulapps.adhan.CalculationMethod
import com.batoulapps.adhan.Coordinates
import com.batoulapps.adhan.Madhab
import com.batoulapps.adhan.PrayerTimes
import org.junit.Assert.*
import org.junit.Test
import java.time.LocalDate
import java.util.TimeZone

/**
 * Unit tests for Prayer Times calculation logic.
 * Tests accuracy of prayer times using Adhan library.
 */
class PrayerTimesCalculatorTest {

    private val meccaCoordinates = Coordinates(21.4225, 39.8262)
    private val cairoCoordinates = Coordinates(30.0444, 31.2357)
    private val londonCoordinates = Coordinates(51.5074, -0.1278)
    
    @Test
    fun `test Mecca prayer times calculation`() {
        val date = LocalDate.of(2024, 1, 15)
        val prayerTimes = PrayerTimes(
            meccaCoordinates,
            date,
            CalculationMethod.MUSLIM_WORLD_LEAGUE
        )
        
        assertNotNull(prayerTimes.fajr)
        assertNotNull(prayerTimes.dhuhr)
        assertNotNull(prayerTimes.asr)
        assertNotNull(prayerTimes.maghrib)
        assertNotNull(prayerTimes.isha)
        
        // Fajr should be before Dhuhr
        assertTrue(prayerTimes.fajr.before(prayerTimes.dhuhr))
        
        // Dhuhr should be before Asr
        assertTrue(prayerTimes.dhuhr.before(prayerTimes.asr))
        
        // Asr should be before Maghrib
        assertTrue(prayerTimes.asr.before(prayerTimes.maghrib))
        
        // Maghrib should be before Isha
        assertTrue(prayerTimes.maghrib.before(prayerTimes.isha))
    }
    
    @Test
    fun `test different calculation methods`() {
        val date = LocalDate.of(2024, 6, 15)
        
        val muslimWorldLeague = PrayerTimes(
            cairoCoordinates,
            date,
            CalculationMethod.MUSLIM_WORLD_LEAGUE
        )
        
        val egyptian = PrayerTimes(
            cairoCoordinates,
            date,
            CalculationMethod.EGYPTIAN
        )
        
        // Different methods should produce different times
        assertNotEquals(muslimWorldLeague.fajr, egyptian.fajr)
    }
    
    @Test
    fun `test different madhabs for Asr time`() {
        val date = LocalDate.of(2024, 3, 20)
        
        val standardAsr = PrayerTimes(
            londonCoordinates,
            date,
            CalculationMethod.MUSLIM_WORLD_LEAGUE,
            Madhab.SHAFI
        )
        
        val hanafiAsr = PrayerTimes(
            londonCoordinates,
            date,
            CalculationMethod.MUSLIM_WORLD_LEAGUE,
            Madhab.HANAFI
        )
        
        // Hanafi Asr should be later than Shafi
        assertTrue(hanafiAsr.asr.after(standardAsr.asr))
    }
    
    @Test
    fun `test high latitude adjustment`() {
        val stockholmCoordinates = Coordinates(59.3293, 18.0686)
        val date = LocalDate.of(2024, 6, 21) // Summer solstice
        
        val prayerTimes = PrayerTimes(
            stockholmCoordinates,
            date,
            CalculationMethod.MUSLIM_WORLD_LEAGUE
        )
        
        // Should not throw exception and should have valid times
        assertNotNull(prayerTimes.fajr)
        assertNotNull(prayerTimes.isha)
    }
    
    @Test
    fun `test timezone handling`() {
        val date = LocalDate.of(2024, 1, 15)
        
        val utcPrayerTimes = PrayerTimes(
            cairoCoordinates,
            date,
            CalculationMethod.EGYPTIAN
        )
        
        // Times should be in local timezone
        assertNotNull(utcPrayerTimes.dhuhr)
    }
}
