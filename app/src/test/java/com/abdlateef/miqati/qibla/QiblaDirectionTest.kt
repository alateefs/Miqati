package com.abdlateef.miqati.qibla

import org.junit.Assert.*
import org.junit.Test

/**
 * Unit tests for Qibla direction calculation.
 * Tests accuracy of bearing calculations from various locations.
 */
class QiblaDirectionTest {

    private val meccaCoordinates = Pair(21.4225, 39.8262)
    
    @Test
    fun `test Qibla from Cairo Egypt`() {
        val cairo = Pair(30.0444, 31.2357)
        val bearing = calculateQiblaBearing(cairo, meccaCoordinates)
        
        // Cairo Qibla should be approximately 135 degrees (Southeast)
        assertTrue("Qibla from Cairo should be between 130-140 degrees", 
            bearing in 130..140)
    }
    
    @Test
    fun `test Qibla from London UK`() {
        val london = Pair(51.5074, -0.1278)
        val bearing = calculateQiblaBearing(london, meccaCoordinates)
        
        // London Qibla should be approximately 118 degrees (East-Southeast)
        assertTrue("Qibla from London should be between 115-125 degrees", 
            bearing in 115..125)
    }
    
    @Test
    fun `test Qibla from New York USA`() {
        val newYork = Pair(40.7128, -74.0060)
        val bearing = calculateQiblaBearing(newYork, meccaCoordinates)
        
        // New York Qibla should be approximately 58 degrees (Northeast)
        assertTrue("Qibla from New York should be between 55-65 degrees", 
            bearing in 55..65)
    }
    
    @Test
    fun `test Qibla from Tokyo Japan`() {
        val tokyo = Pair(35.6762, 139.6503)
        val bearing = calculateQiblaBearing(tokyo, meccaCoordinates)
        
        // Tokyo Qibla should be approximately 293 degrees (West-Northwest)
        assertTrue("Qibla from Tokyo should be between 290-300 degrees", 
            bearing in 290..300)
    }
    
    @Test
    fun `test Qibla from Sydney Australia`() {
        val sydney = Pair(-33.8688, 151.2093)
        val bearing = calculateQiblaBearing(sydney, meccaCoordinates)
        
        // Sydney Qibla should be approximately 277 degrees (West)
        assertTrue("Qibla from Sydney should be between 270-285 degrees", 
            bearing in 270..285)
    }
    
    @Test
    fun `test Qibla from Mecca itself`() {
        val bearing = calculateQiblaBearing(meccaCoordinates, meccaCoordinates)
        
        // From Mecca, direction is undefined but should not crash
        assertTrue("Bearing should be between 0-360 degrees", 
            bearing in 0..360)
    }
    
    /**
     * Calculate Qibla bearing using great circle formula
     */
    private fun calculateQiblaBearing(from: Pair<Double, Double>, to: Pair<Double, Double>): Double {
        val lat1 = Math.toRadians(from.first)
        val lon1 = Math.toRadians(from.second)
        val lat2 = Math.toRadians(to.first)
        val lon2 = Math.toRadians(to.second)
        
        val deltaLon = lon2 - lon1
        
        val y = kotlin.math.sin(deltaLon) * kotlin.math.cos(lat2)
        val x = kotlin.math.cos(lat1) * kotlin.math.sin(lat2) - 
                kotlin.math.sin(lat1) * kotlin.math.cos(lat2) * kotlin.math.cos(deltaLon)
        
        var bearing = Math.toDegrees(kotlin.math.atan2(y, x))
        bearing = (bearing + 360) % 360
        
        return bearing
    }
}
