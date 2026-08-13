package com.abdlateef.miqati.core.designsystem

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

/**
 * Light color scheme for Miqati theme.
 * Emerald primary with Gold accent colors.
 */
private val LightColorScheme = lightColorScheme(
    primary = Color(0xFF10B981),
    onPrimary = Color.White,
    primaryContainer = Color(0xFFA7F3D0),
    onPrimaryContainer = Color(0xFF064E3B),
    secondary = Color(0xFFF59E0B),
    onSecondary = Color.White,
    secondaryContainer = Color(0xFFFDE68A),
    onSecondaryContainer = Color(0xFF78350F),
    tertiary = Color(0xFF3B82F6),
    onTertiary = Color.White,
    background = Color(0xFFFAFAF9),
    onBackground = Color(0xFF1C1917),
    surface = Color.White,
    onSurface = Color(0xFF1C1917),
    surfaceVariant = Color(0xFFF5F5F4),
    onSurfaceVariant = Color(0xFF78716C),
    error = Color(0xFFEF4444),
    onError = Color.White,
    outline = Color(0xFFA8A29E),
    outlineVariant = Color(0xFFD6D3D1)
)

/**
 * Dark color scheme for Miqati theme.
 */
private val DarkColorScheme = darkColorScheme(
    primary = Color(0xFF34D399),
    onPrimary = Color(0xFF064E3B),
    primaryContainer = Color(0xFF064E3B),
    onPrimaryContainer = Color(0xFFA7F3D0),
    secondary = Color(0xFFFBBF24),
    onSecondary = Color(0xFF78350F),
    secondaryContainer = Color(0xFF78350F),
    onSecondaryContainer = Color(0xFFFDE68A),
    tertiary = Color(0xFF60A5FA),
    onTertiary = Color(0xFF1E3A8A),
    background = Color(0xFF1C1917),
    onBackground = Color(0xFFFAFAF9),
    surface = Color(0xFF292524),
    onSurface = Color(0xFFFAFAF9),
    surfaceVariant = Color(0xFF44403C),
    onSurfaceVariant = Color(0xFFA8A29E),
    error = Color(0xFFF87171),
    onError = Color(0xFF7F1D1D),
    outline = Color(0xFF57534E),
    outlineVariant = Color(0xFF44403C)
)

/**
 * Miqati Theme - Centralized theme configuration.
 * Supports light/dark mode automatically based on system settings.
 * RTL-ready from day one.
 */
@Composable
fun MiqatiTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    MaterialTheme(
        colorScheme = colorScheme,
        typography = MiqatiTypography,
        content = content
    )
}
