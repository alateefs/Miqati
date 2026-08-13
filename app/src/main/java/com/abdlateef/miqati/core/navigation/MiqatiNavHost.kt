package com.abdlateef.miqati.core.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import com.abdlateef.miqati.feature.home.presentation.HomeScreen
import com.abdlateef.miqati.feature.prayer.presentation.PrayerTimesScreen
import com.abdlateef.miqati.feature.qibla.presentation.QiblaScreen
import com.abdlateef.miqati.feature.settings.presentation.SettingsScreen
import com.abdlateef.miqati.feature.placeholder.presentation.PlaceholderScreen

/**
 * Navigation routes for the app.
 * Using sealed class for type-safe navigation.
 */
sealed class Screen(val route: String) {
    data object Home : Screen("home")
    data object PrayerTimes : Screen("prayer_times")
    data object Qibla : Screen("qibla")
    data object Settings : Screen("settings")
    data object Quran : Screen("quran")
    data object Azkar : Screen("azkar")
    data object Calendar : Screen("calendar")
    data object Hadith : Screen("hadith")
}

/**
 * Main navigation host for Miqati app.
 * Sets up navigation between all feature screens.
 */
@Composable
fun MiqatiNavHost(
    navController: NavHostController = androidx.navigation.compose.rememberNavController()
) {
    NavHost(
        navController = navController,
        startDestination = Screen.Home.route
    ) {
        composable(Screen.Home.route) {
            HomeScreen(
                onNavigateToQibla = { navController.navigate(Screen.Qibla.route) },
                onNavigateToSettings = { navController.navigate(Screen.Settings.route) },
                onNavigateToPrayerTimes = { navController.navigate(Screen.PrayerTimes.route) },
                onNavigateToQuran = { navController.navigate(Screen.Quran.route) },
                onNavigateToAzkar = { navController.navigate(Screen.Azkar.route) },
                onNavigateToCalendar = { navController.navigate(Screen.Calendar.route) }
            )
        }

        composable(Screen.PrayerTimes.route) {
            PrayerTimesScreen(
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable(Screen.Qibla.route) {
            QiblaScreen(
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable(Screen.Settings.route) {
            SettingsScreen(
                onNavigateBack = { navController.popBackStack() }
            )
        }

        // Placeholder screens for future features
        composable(Screen.Quran.route) {
            PlaceholderScreen(
                title = "Quran",
                message = "Quran module coming soon",
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable(Screen.Azkar.route) {
            PlaceholderScreen(
                title = "Azkar",
                message = "Azkar module coming soon",
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable(Screen.Calendar.route) {
            PlaceholderScreen(
                title = "Islamic Calendar",
                message = "Calendar module coming soon",
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable(Screen.Hadith.route) {
            PlaceholderScreen(
                title = "Hadith",
                message = "Hadith module coming soon",
                onNavigateBack = { navController.popBackStack() }
            )
        }
    }
}
