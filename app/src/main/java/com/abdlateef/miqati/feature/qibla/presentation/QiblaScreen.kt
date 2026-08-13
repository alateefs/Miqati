package com.abdlateef.miqati.feature.qibla.presentation

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.abdlateef.miqati.R
import kotlin.math.cos
import kotlin.math.sin

/**
 * Qibla Screen - Displays compass direction to Kaaba.
 * Uses device sensors for orientation with magnetic declination correction.
 */
@Composable
fun QiblaScreen(
    onNavigateBack: () -> Unit,
    viewModel: QiblaViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current

    // Sensor lifecycle management
    DisposableEffect(Unit) {
        val sensorManager = context.getSystemService(SensorManager::class.java)
        val rotationVectorSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        
        val sensorListener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent?) {
                event?.let { viewModel.onRotationVectorChanged(it.values) }
            }

            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
                viewModel.onAccuracyChanged(accuracy)
            }
        }

        rotationVectorSensor?.let { sensor ->
            sensorManager.registerListener(
                sensorListener,
                sensor,
                SensorManager.SENSOR_DELAY_GAME
            )
        }

        onDispose {
            sensorManager.unregisterListener(sensorListener)
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(stringResource(R.string.qibla_title)) },
                navigationIcon = {
                    androidx.compose.material3.IconButton(onClick = onNavigateBack) {
                        androidx.compose.material3.Icon(
                            imageVector = androidx.compose.material.icons.Icons.Default.ArrowBack,
                            contentDescription = "Back"
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer,
                    titleContentColor = MaterialTheme.colorScheme.onPrimaryContainer
                )
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // Compass display
            QiblaCompass(
                qiblaDirection = uiState.qiblaDirection,
                deviceDirection = uiState.deviceDirection,
                isCalibrated = uiState.isCalibrated,
                modifier = Modifier.size(300.dp)
            )

            Spacer(modifier = Modifier.height(24.dp))

            // Direction indicator
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Column(
                    modifier = Modifier
                        .padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = if (uiState.isCalibrated) {
                            stringResource(R.string.qibla_description)
                        } else {
                            stringResource(R.string.qibla_calibrating)
                        },
                        style = MaterialTheme.typography.bodyLarge,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )

                    Spacer(modifier = Modifier.height(8.dp))

                    Text(
                        text = "${uiState.qiblaDirection.toInt()}°",
                        style = MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.primary
                    )

                    if (!uiState.isCalibrated) {
                        Spacer(modifier = Modifier.height(8.dp))
                        
                        Text(
                            text = stringResource(R.string.qibla_move_figure_eight),
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.error
                        )
                    }
                }
            }

            // Accuracy indicator
            if (uiState.sensorAccuracy != null) {
                Spacer(modifier = Modifier.height(16.dp))
                
                Text(
                    text = "Sensor Accuracy: ${uiState.sensorAccuracy}",
                    style = MaterialTheme.typography.labelMedium,
                    color = when (uiState.sensorAccuracy) {
                        SensorManager.SENSOR_STATUS_ACCURACY_HIGH -> Color.Green
                        SensorManager.SENSOR_STATUS_ACCURACY_MEDIUM -> Color.Yellow
                        SensorManager.SENSOR_STATUS_ACCURACY_LOW -> Color.Red
                        else -> Color.Gray
                    }
                )
            }
        }
    }
}

/**
 * Qibla Compass visualization.
 */
@Composable
private fun QiblaCompass(
    qiblaDirection: Float,
    deviceDirection: Float,
    isCalibrated: Boolean,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier,
        contentAlignment = Alignment.Center
    ) {
        Canvas(
            modifier = Modifier
                .size(280.dp)
                .rotate(-deviceDirection)
        ) {
            val radius = size.minDimension / 2
            
            // Outer ring
            drawCircle(
                color = MaterialTheme.colorScheme.outline.copy(alpha = 0.3f),
                radius = radius,
                style = Stroke(width = 4.dp.toPx())
            )

            // Cardinal directions
            drawCardinalDirections(radius)

            // Degree markers
            drawDegreeMarkers(radius)

            // Qibla direction indicator
            if (isCalibrated) {
                drawQiblaIndicator(qiblaDirection, radius)
            }
        }

        // Center decoration
        Box(
            modifier = Modifier
                .size(60.dp)
                .align(Alignment.Center),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "Kaaba",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onPrimary,
                fontWeight = FontWeight.Medium
            )
        }
    }
}

/**
 * Draw cardinal directions (N, E, S, W).
 */
private fun DrawScope.drawCardinalDirections(radius: Float) {
    val textRadius = radius * 0.85f
    
    // North
    drawContext.canvas.nativeCanvas.apply {
        save()
        translate(size.width / 2, size.height / 2)
        rotate(-90f)
        drawText(
            "N",
            textRadius,
            0f,
            android.graphics.Paint().apply {
                color = Color.Red.hashCode()
                textSize = 40f
                textAlign = android.graphics.Paint.Align.CENTER
                isFakeBoldText = true
            }
        )
        restore()
    }

    // South
    drawContext.canvas.nativeCanvas.apply {
        save()
        translate(size.width / 2, size.height / 2)
        rotate(90f)
        drawText(
            "S",
            textRadius,
            0f,
            android.graphics.Paint().apply {
                color = Color.White.hashCode()
                textSize = 40f
                textAlign = android.graphics.Paint.Align.CENTER
            }
        )
        restore()
    }

    // East
    drawContext.canvas.nativeCanvas.apply {
        save()
        translate(size.width / 2, size.height / 2)
        drawText(
            "E",
            0f,
            textRadius,
            android.graphics.Paint().apply {
                color = Color.White.hashCode()
                textSize = 40f
                textAlign = android.graphics.Paint.Align.CENTER
            }
        )
        restore()
    }

    // West
    drawContext.canvas.nativeCanvas.apply {
        save()
        translate(size.width / 2, size.height / 2)
        drawText(
            "W",
            0f,
            -textRadius,
            android.graphics.Paint().apply {
                color = Color.White.hashCode()
                textSize = 40f
                textAlign = android.graphics.Paint.Align.CENTER
            }
        )
        restore()
    }
}

/**
 * Draw degree markers around the compass.
 */
private fun DrawScope.drawDegreeMarkers(radius: Float) {
    val centerOffset = Offset(size.width / 2, size.height / 2)
    
    for (angle in 0 until 360 step 10) {
        val radians = Math.toRadians(angle.toDouble())
        val isMajor = angle % 30 == 0
        
        val startOffset = Offset(
            x = centerOffset.x + (radius * 0.9f * cos(radians)).toFloat(),
            y = centerOffset.y + (radius * 0.9f * sin(radians)).toFloat()
        )
        
        val endOffset = Offset(
            x = centerOffset.x + (radius * if (isMajor) 0.95f else 0.92f) * cos(radians).toFloat(),
            y = centerOffset.y + (radius * if (isMajor) 0.95f else 0.92f) * sin(radians).toFloat()
        )

        drawLine(
            color = if (isMajor) {
                MaterialTheme.colorScheme.outline
            } else {
                MaterialTheme.colorScheme.outline.copy(alpha = 0.5f)
            },
            start = startOffset,
            end = endOffset,
            strokeWidth = if (isMajor) 2.dp.toPx() else 1.dp.toPx(),
            cap = StrokeCap.Round
        )
    }
}

/**
 * Draw Qibla direction indicator.
 */
private fun DrawScope.drawQiblaIndicator(qiblaDirection: Float, radius: Float) {
    val centerOffset = Offset(size.width / 2, size.height / 2)
    val radians = Math.toRadians(qiblaDirection.toDouble())
    
    // Arrow line
    val arrowEnd = Offset(
        x = centerOffset.x + (radius * 0.7f * cos(radians)).toFloat(),
        y = centerOffset.y + (radius * 0.7f * sin(radians)).toFloat()
    )

    drawLine(
        color = MaterialTheme.colorScheme.primary,
        start = centerOffset,
        end = arrowEnd,
        strokeWidth = 4.dp.toPx(),
        cap = StrokeCap.Round
    )

    // Arrow head
    val arrowHeadSize = 12.dp.toPx()
    val arrowAngle1 = radians - Math.PI / 6
    val arrowAngle2 = radians + Math.PI / 6

    val arrowPoint1 = Offset(
        x = arrowEnd.x - (arrowHeadSize * cos(arrowAngle1)).toFloat(),
        y = arrowEnd.y - (arrowHeadSize * sin(arrowAngle1)).toFloat()
    )

    val arrowPoint2 = Offset(
        x = arrowEnd.x - (arrowHeadSize * cos(arrowAngle2)).toFloat(),
        y = arrowEnd.y - (arrowHeadSize * sin(arrowAngle2)).toFloat()
    )

    drawLine(
        color = MaterialTheme.colorScheme.primary,
        start = arrowEnd,
        end = arrowPoint1,
        strokeWidth = 3.dp.toPx(),
        cap = StrokeCap.Round
    )

    drawLine(
        color = MaterialTheme.colorScheme.primary,
        start = arrowEnd,
        end = arrowPoint2,
        strokeWidth = 3.dp.toPx(),
        cap = StrokeCap.Round
    )
}
