package com.abdlateef.miqati.feature.settings.presentation

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowForwardIos
import androidx.compose.material.icons.filled.AudioFile
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Palette
import androidx.compose.material.icons.filled.Info
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Divider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.abdlateef.miqati.R

/**
 * Settings Screen - Centralized preferences management.
 */
@Composable
fun SettingsScreen(
    onNavigateBack: () -> Unit,
    onCalculationMethodClick: () -> Unit = {},
    onAsrMethodClick: () -> Unit = {},
    onHighLatitudeClick: () -> Unit = {},
    onLocationModeClick: () -> Unit = {},
    onAdhanSettingsClick: () -> Unit = {},
    onNotificationSettingsClick: () -> Unit = {},
    onAppearanceClick: () -> Unit = {},
    onAboutClick: () -> Unit = {}
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(stringResource(R.string.settings_title)) },
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
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            verticalArrangement = Arrangement.spacedBy(8.dp),
            contentPadding = paddingValues
        ) {
            // Prayer Calculation Section
            item {
                SettingsSectionTitle(title = "Prayer Calculation")
            }

            item {
                SettingsItem(
                    icon = Icons.Default.CalendarMonth,
                    title = stringResource(R.string.settings_calculation_method),
                    subtitle = "Muslim World League",
                    onClick = onCalculationMethodClick
                )
            }

            item {
                SettingsItem(
                    icon = Icons.Default.CalendarMonth,
                    title = stringResource(R.string.settings_asr_method),
                    subtitle = "Standard (Shafi'i)",
                    onClick = onAsrMethodClick
                )
            }

            item {
                SettingsItem(
                    icon = Icons.Default.CalendarMonth,
                    title = stringResource(R.string.settings_high_latitude),
                    subtitle = "Middle of the Night",
                    onClick = onHighLatitudeClick
                )
            }

            item {
                Spacer(modifier = Modifier.height(16.dp))
            }

            // Location Section
            item {
                SettingsSectionTitle(title = "Location")
            }

            item {
                SettingsItem(
                    icon = Icons.Default.LocationOn,
                    title = stringResource(R.string.settings_location_mode),
                    subtitle = "Automatic (GPS)",
                    onClick = onLocationModeClick
                )
            }

            item {
                Spacer(modifier = Modifier.height(16.dp))
            }

            // Notifications & Adhan Section
            item {
                SettingsSectionTitle(title = "Notifications & Adhan")
            }

            item {
                SettingsItem(
                    icon = Icons.Default.AudioFile,
                    title = stringResource(R.string.settings_adhan_settings),
                    subtitle = "Configure prayer alerts",
                    onClick = onAdhanSettingsClick
                )
            }

            item {
                SettingsItem(
                    icon = Icons.Default.Notifications,
                    title = stringResource(R.string.settings_notification_settings),
                    subtitle = "Manage notifications",
                    onClick = onNotificationSettingsClick
                )
            }

            item {
                Spacer(modifier = Modifier.height(16.dp))
            }

            // Appearance Section
            item {
                SettingsSectionTitle(title = "Appearance")
            }

            item {
                SettingsItem(
                    icon = Icons.Default.Palette,
                    title = stringResource(R.string.settings_appearance),
                    subtitle = "Theme and colors",
                    onClick = onAppearanceClick
                )
            }

            item {
                Spacer(modifier = Modifier.height(16.dp))
            }

            // About Section
            item {
                SettingsSectionTitle(title = "About")
            }

            item {
                SettingsItem(
                    icon = Icons.Default.Info,
                    title = stringResource(R.string.settings_about),
                    subtitle = "Version 1.0.0",
                    onClick = onAboutClick
                )
            }

            item {
                Spacer(modifier = Modifier.height(32.dp))
            }
        }
    }
}

/**
 * Settings section title.
 */
@Composable
private fun SettingsSectionTitle(title: String) {
    Text(
        text = title,
        style = MaterialTheme.typography.titleSmall,
        color = MaterialTheme.colorScheme.primary,
        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
    )
}

/**
 * Individual settings item.
 */
@Composable
private fun SettingsItem(
    icon: ImageVector,
    title: String,
    subtitle: String,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
            .clickable(onClick = onClick),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                modifier = Modifier.weight(1f),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.padding(end = 16.dp)
                )

                Column {
                    Text(
                        text = title,
                        style = MaterialTheme.typography.bodyLarge,
                        color = MaterialTheme.colorScheme.onSurface
                    )

                    Spacer(modifier = Modifier.height(2.dp))

                    Text(
                        text = subtitle,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            Icon(
                imageVector = Icons.Default.ArrowForwardIos,
                contentDescription = "Navigate",
                tint = MaterialTheme.colorScheme.outline,
                modifier = Modifier.padding(start = 16.dp)
            )
        }
    }
}
