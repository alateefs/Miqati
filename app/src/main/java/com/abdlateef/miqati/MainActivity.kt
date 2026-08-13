package com.abdlateef.miqati

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import com.abdlateef.miqati.core.designsystem.MiqatiTheme
import com.abdlateef.miqati.core.navigation.MiqatiNavHost
import dagger.hilt.android.AndroidEntryPoint

/**
 * Main Activity for Miqati application.
 * Entry point for the app, sets up Compose and navigation.
 */
@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MiqatiTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    MiqatiNavHost()
                }
            }
        }
    }
}
