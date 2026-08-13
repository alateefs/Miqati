package com.abdlateef.miqati.feature.home.presentation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarToday
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.WbSunny
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.abdlateef.miqati.R
import com.abdlateef.miqati.core.common.DateUtils
import com.abdlateef.miqati.feature.prayer.domain.model.PrayerName
import java.util.Date

/**
 * Data class for tool items in the grid.
 */
data class ToolItem(
    val icon: ImageVector,
    val label: String,
    val onClick: () -> Unit
)

/**
 * Home Screen - Main entry point of the app.
 * Displays next prayer countdown, today's schedule, and Islamic tools grid.
 */
@Composable
fun HomeScreen(
    onNavigateToQibla: () -> Unit,
    onNavigateToSettings: () -> Unit,
    onNavigateToPrayerTimes: () -> Unit,
    onNavigateToQuran: () -> Unit,
    onNavigateToAzkar: () -> Unit,
    onNavigateToCalendar: () -> Unit,
    viewModel: HomeViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(stringResource(R.string.app_name)) },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer,
                    titleContentColor = MaterialTheme.colorScheme.onPrimaryContainer
                ),
                actions = {
                    Icon(
                        imageVector = Icons.Default.Settings,
                        contentDescription = stringResource(R.string.nav_settings),
                        modifier = Modifier
                            .padding(end = 16.dp)
                            .size(24.dp)
                            .onClick { onNavigateToSettings() }
                    )
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            // Next Prayer Card with gradient background
            NextPrayerCard(
                nextPrayer = uiState.nextPrayer,
                countdown = uiState.countdown,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp)
            )

            // Today's Gregorian and Hijri dates
            DateCard(
                gregorianDate = uiState.gregorianDate,
                hijriDate = uiState.hijriDate,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp)
                    .padding(bottom = 16.dp)
            )

            // Prayer times list (clickable to go to full schedule)
            PrayerSchedulePreview(
                prayers = uiState.todayPrayers,
                onPrayerClick = onNavigateToPrayerTimes,
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
            )

            // Islamic Tools Grid
            IslamicToolsGrid(
                onNavigateToQibla = onNavigateToQibla,
                onNavigateToQuran = onNavigateToQuran,
                onNavigateToAzkar = onNavigateToAzkar,
                onNavigateToCalendar = onNavigateToCalendar,
                onNavigateToSettings = onNavigateToSettings,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(280.dp)
            )
        }
    }
}

/**
 * Next Prayer Card with live countdown.
 */
@Composable
private fun NextPrayerCard(
    nextPrayer: PrayerName?,
    countdown: String,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    Brush.horizontalGradient(
                        colors = listOf(
                            MaterialTheme.colorScheme.primary,
                            MaterialTheme.colorScheme.tertiary
                        )
                    )
                )
                .padding(24.dp)
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(
                    text = stringResource(R.string.home_next_prayer),
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onPrimary.copy(alpha = 0.8f)
                )

                Spacer(modifier = Modifier.height(8.dp))

                Text(
                    text = nextPrayer?.name?.lowercase()?.replaceFirstChar { it.uppercase() }
                        ?: "--",
                    style = MaterialTheme.typography.headlineLarge,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onPrimary
                )

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    text = countdown,
                    style = MaterialTheme.typography.titleMedium,
                    color = MaterialTheme.colorScheme.onPrimary.copy(alpha = 0.9f)
                )
            }
        }
    }
}

/**
 * Date card showing both Gregorian and Hijri dates.
 */
@Composable
private fun DateCard(
    gregorianDate: String,
    hijriDate: String,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = gregorianDate,
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            Spacer(modifier = Modifier.height(4.dp))

            Text(
                text = hijriDate,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.primary
            )
        }
    }
}

/**
 * Preview of today's prayer times.
 */
@Composable
private fun PrayerSchedulePreview(
    prayers: List<Pair<PrayerName, String>>,
    onPrayerClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier.padding(horizontal = 16.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = stringResource(R.string.home_today_prayers),
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.SemiBold
            )

            Text(
                text = "View All",
                style = MaterialTheme.typography.labelLarge,
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier.onClick { onPrayerClick() }
            )
        }

        Spacer(modifier = Modifier.height(12.dp))

        prayers.forEach { (prayer, time) ->
            PrayerTimeRow(
                prayerName = prayer,
                time = time,
                isNext = false,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp)
            )
        }
    }
}

/**
 * Single prayer time row.
 */
@Composable
private fun PrayerTimeRow(
    prayerName: PrayerName,
    time: String,
    isNext: Boolean,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier,
        colors = CardDefaults.cardColors(
            containerColor = if (isNext) {
                MaterialTheme.colorScheme.primaryContainer
            } else {
                MaterialTheme.colorScheme.surface
            }
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = when (prayerName) {
                    PrayerName.FAJR -> stringResource(R.string.prayer_fajr)
                    PrayerName.SUNRISE -> stringResource(R.string.prayer_sunrise)
                    PrayerName.DHUHR -> stringResource(R.string.prayer_dhuhr)
                    PrayerName.ASR -> stringResource(R.string.prayer_asr)
                    PrayerName.MAGHRIB -> stringResource(R.string.prayer_maghrib)
                    PrayerName.ISHA -> stringResource(R.string.prayer_isha)
                },
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurface
            )

            Text(
                text = time,
                style = MaterialTheme.typography.bodyLarge,
                fontWeight = FontWeight.Medium,
                color = if (isNext) {
                    MaterialTheme.colorScheme.primary
                } else {
                    MaterialTheme.colorScheme.onSurface
                }
            )
        }
    }
}

/**
 * Islamic Tools Grid.
 */
@Composable
private fun IslamicToolsGrid(
    onNavigateToQibla: () -> Unit,
    onNavigateToQuran: () -> Unit,
    onNavigateToAzkar: () -> Unit,
    onNavigateToCalendar: () -> Unit,
    onNavigateToSettings: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier.padding(horizontal = 16.dp)
    ) {
        Text(
            text = stringResource(R.string.home_islamic_tools),
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.SemiBold,
            modifier = Modifier.padding(bottom = 12.dp)
        )

        val tools = listOf(
            ToolItem(Icons.Default.LocationOn, stringResource(R.string.nav_qibla), onNavigateToQibla),
            ToolItem(Icons.Default.WbSunny, stringResource(R.string.placeholder_quran), onNavigateToQuran),
            ToolItem(Icons.Default.Notifications, stringResource(R.string.placeholder_azkar), onNavigateToAzkar),
            ToolItem(Icons.Default.CalendarToday, stringResource(R.string.placeholder_calendar), onNavigateToCalendar),
            ToolItem(Icons.Default.Settings, stringResource(R.string.nav_settings), onNavigateToSettings)
        )

        LazyVerticalGrid(
            columns = GridCells.Fixed(3),
            contentPadding = PaddingValues(4.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(tools) { tool ->
                ToolGridItem(
                    icon = tool.icon,
                    label = tool.label,
                    onClick = tool.onClick
                )
            }
        }
    }
}

/**
 * Single tool grid item.
 */
@Composable
private fun ToolGridItem(
    icon: ImageVector,
    label: String,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .width(100.dp)
            .height(110.dp),
        onClick = onClick,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(8.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = label,
                modifier = Modifier.size(32.dp),
                tint = MaterialTheme.colorScheme.primary
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = label,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                maxLines = 2
            )
        }
    }
}

/**
 * Simple click modifier extension.
 */
private fun Modifier.onClick(action: () -> Unit): Modifier =
    this.then(
        Modifier.clickable(
            onClick = action
        )
    )
