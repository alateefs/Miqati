# Miqati - Professional Islamic Prayer & Worship App

![Miqati Banner](docs/images/banner.png)

[![Platform](https://img.shields.io/badge/Platform-Android-green.svg)](https://developer.android.com/)
[![Kotlin](https://img.shields.io/badge/Kotlin-1.9.0-purple.svg)](https://kotlinlang.org/)
[![Compose](https://img.shields.io/badge/Compose-1.5.0-blue.svg)](https://developer.android.com/jetpack/compose)
[![Min SDK](https://img.shields.io/badge/Min%20SDK-26-orange.svg)](https://developer.android.com/guide/topics/manifest/uses-sdk-element)
[![Target SDK](https://img.shields.io/badge/Target%20SDK-34-brightgreen.svg)](https://developer.android.com/guide/topics/manifest/uses-sdk-element)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **Miqati** is a production-grade, offline-first Islamic application designed for accuracy, privacy, elegance, and long-term scalability. Built with modern Android technologies, it provides precise prayer times, Qibla direction, Adhan notifications, and more—completely without internet, ads, or tracking.

---

## 📑 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [System Requirements](#system-requirements)
- [Installation](#installation)
- [Building the Project](#building-the-project)
- [Usage Guide](#usage-guide)
- [Project Structure](#project-structure)
- [Design System](#design-system)
- [Localization & RTL](#localization--rtl)
- [Testing Strategy](#testing-strategy)
- [Development Guidelines](#development-guidelines)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

---

## Overview

**Miqati** (ميقاتي) is a comprehensive Islamic utility app built exclusively for Android. It focuses on delivering core worship features with precision and reliability while maintaining complete user privacy. The app works entirely offline after initial setup, requiring no internet connection, paid APIs, analytics, or backend services.

### Core Principles

- **Offline-First**: All core features work without internet connectivity
- **Privacy-Centric**: Zero data collection, no analytics, no tracking
- **Accuracy**: Precise prayer calculations using astronomical algorithms
- **Elegance**: Modern, minimal UI following Material Design 3 guidelines
- **Scalability**: Clean architecture ready for future Islamic modules
- **Accessibility**: RTL-ready, screen-reader friendly, high contrast support

---

## Key Features

### ✅ Current Features

#### 🕌 Prayer Times
- Accurate offline calculation using the `adhan` library
- Multiple calculation methods (MWL, ISNA, Egypt, Makkah, etc.)
- Juristic rules for Asr (Shafi'i, Hanafi)
- High-latitude adjustments
- Automatic timezone detection
- Gregorian and Hijri date display

#### 📍 Location Services
- Automatic GPS location detection
- Manual coordinate input option
- Persistent location storage using DataStore
- Graceful handling of permission denials
- Offline map integration with OSMDroid (planned)

#### 🧭 Qibla Compass
- True North correction using geomagnetic field data
- Sensor fusion (Rotation Vector + Accelerometer + Magnetometer)
- Magnetic declination adjustment
- Smooth, accurate compass UI with visual indicators
- Works offline after initial calibration

#### 🔔 Adhan & Notifications
- Per-prayer Adhan toggle settings
- Global Adhan enable/disable switch
- Audio preview and stop functionality
- Media3 ExoPlayer integration for high-quality playback
- Foreground service for reliable notification delivery
- Exact alarm scheduling with Android 12+ fallback
- Boot receiver to restore alarms after device restart

#### 🏠 Home Screen
- Prominent next-prayer card with live countdown
- Clean prayer schedule rows
- Islamic tools grid (Qibla, Quran, Azkar, Calendar, Settings, Adhan)
- Gradient background with modern aesthetic
- Real-time updates without unnecessary recompositions

#### ⚙️ Settings
- Centralized preferences management
- Calculation method selection
- Location mode configuration (GPS vs Manual)
- Adhan settings per prayer
- Notification preferences
- Appearance settings (Light/Dark theme)
- About section with app info

### 🔮 Planned Features

- **Quran Module**: Full Quran text with audio recitation
- **Azkar & Duas**: Comprehensive supplication library
- **Islamic Calendar**: Events, holidays, and important dates
- **Hadith Collection**: Authentic hadith with search functionality
- **Mosque Finder**: Nearby mosques with offline maps
- **Widget Support**: Home screen widgets for quick access
- **Multi-City Support**: Track prayer times for multiple locations
- **Donation Integration**: Optional in-app donations for sustainability

---

## Architecture

Miqati follows **Clean Architecture** principles combined with **Feature-Based Modularization** and **MVVM** pattern. This ensures separation of concerns, testability, and maintainability.

### Architectural Layers

```
┌─────────────────────────────────────────┐
│          Presentation Layer             │
│  (Jetpack Compose UI, ViewModels)       │
├─────────────────────────────────────────┤
│            Domain Layer                 │
│  (Use Cases, Repository Interfaces,     │
│   Pure Kotlin Models)                   │
├─────────────────────────────────────────┤
│             Data Layer                  │
│  (Repository Implementations,           │
│   DataStore, Android APIs,              │
│   External Libraries)                   │
└─────────────────────────────────────────┘
```

### Key Architectural Decisions

1. **Strict Separation**: UI never contains business logic or direct Android framework calls
2. **Pure Domain**: Domain layer contains only pure Kotlin code with no Android dependencies
3. **Dependency Injection**: Hilt provides all dependencies; no service locators
4. **State Management**: StateFlow + ViewModel; UI observes state, never triggers side effects directly
5. **Error Handling**: Result<T> wrapper for error-prone operations
6. **Null Safety**: Enforced throughout; no `!!` unless absolutely justified

### Module Structure

```
app/
├── core/                    # Shared components
│   ├── designsystem/        # Theme, colors, typography
│   ├── navigation/          # Navigation graph
│   ├── common/              # Utils, extensions
│   └── di/                  # App-level DI
├── feature/
│   ├── home/                # Main screen
│   ├── prayer/              # Prayer calculation
│   ├── location/            # GPS & manual location
│   ├── qibla/               # Compass functionality
│   ├── adhan/               # Audio playback
│   ├── notifications/       # Alarm scheduling
│   ├── settings/            # Preferences
│   └── placeholder/         # Future modules
└── ui/                      # Shared UI components
```

---

## Tech Stack

### Core Technologies

| Category | Technology | Version |
|----------|------------|---------|
| Language | Kotlin | 1.9.0 |
| UI Toolkit | Jetpack Compose | 1.5.0 |
| Design System | Material 3 | 1.1.0 |
| DI Framework | Hilt | 2.48 |
| Async Operations | Coroutines + Flow | 1.7.0 |
| State Management | StateFlow | 1.7.0 |
| Navigation | Jetpack Navigation Compose | 2.7.0 |
| Local Storage | DataStore Preferences | 1.0.0 |
| Audio Playback | Media3 ExoPlayer | 1.1.0 |
| Location Services | FusedLocationProvider | 21.0.0 |
| Maps (Offline) | OSMDroid | 6.1.16 |
| Sensors | Rotation Vector + GeomagneticField | Native |
| Prayer Calculation | adhan (batoulapps) | 1.2.1 |
| Alarms | AlarmManager + BroadcastReceiver | Native |

### Build Tools

- **Gradle**: 8.0
- **AGP (Android Gradle Plugin)**: 8.1.0
- **Min SDK**: 26 (Android 8.0)
- **Target SDK**: 34 (Android 14)
- **Compile SDK**: 34

### Testing Frameworks

- **Unit Tests**: JUnit 4, Mockito, Turbine
- **UI Tests**: Compose Testing Manifest, Espresso
- **Integration Tests**: Hilt Testing, Room Testing

---

## System Requirements

### Development Environment

- **Android Studio**: Flamingo (2022.2.1) or newer
- **JDK**: 17 or higher
- **Gradle**: 8.0+
- **Kotlin Plugin**: 1.9.0+

### Device Requirements

- **Minimum Android Version**: API 26 (Android 8.0 Oreo)
- **Recommended Android Version**: API 34 (Android 14)
- **RAM**: 2GB minimum, 4GB recommended
- **Storage**: 50MB free space
- **Sensors**: 
  - GPS/Location services (for automatic location)
  - Magnetometer (for Qibla compass)
  - Accelerometer (for sensor fusion)

### Required Permissions

```xml
<!-- Location -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Audio -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />

<!-- Notifications -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />

<!-- Boot -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

<!-- Wake Lock (for Adhan playback) -->
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

---

## Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/alateefs/miqati.git
cd miqati
```

### Step 2: Open in Android Studio

1. Launch Android Studio
2. Select **File → Open**
3. Navigate to the cloned `miqati` directory
4. Click **OK** to open the project

### Step 3: Sync Dependencies

Android Studio will automatically sync Gradle dependencies. Wait for the sync to complete successfully.

### Step 4: Configure Build Variants

- **Debug**: For development and testing
- **Release**: For production builds (requires signing configuration)

### Step 5: Run on Device/Emulator

1. Connect an Android device or start an emulator
2. Ensure the device meets minimum requirements (API 26+)
3. Click **Run** (▶️) in Android Studio
4. Select your target device

---

## Building the Project

### Debug Build

```bash
./gradlew assembleDebug
```

Output: `app/build/outputs/apk/debug/app-debug.apk`

### Release Build

1. **Configure Signing** (create `keystore.properties`):

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=<your-key-alias>
storeFile=<path-to-keystore>
```

2. **Build Release APK**:

```bash
./gradlew assembleRelease
```

Output: `app/build/outputs/apk/release/app-release.apk`

### Build Bundle (for Play Store)

```bash
./gradlew bundleRelease
```

Output: `app/build/outputs/bundle/release/app-release.aab`

### Run Tests

```bash
# Unit tests
./gradlew test

# Instrumented tests
./gradlew connectedAndroidTest

# All tests
./gradlew check
```

### Code Quality Checks

```bash
# Detekt (static analysis)
./gradlew detekt

# ktlint (code formatting)
./gradlew ktlintCheck

# Lint checks
./gradlew lint
```

---

## Usage Guide

### First Launch Setup

1. **Grant Permissions**:
   - Location permission (for automatic prayer time calculation)
   - Notification permission (for Adhan alerts)
   - Allow exact alarms (for precise timing)

2. **Set Location**:
   - **Automatic**: Tap "Use Current Location" to fetch GPS coordinates
   - **Manual**: Enter latitude/longitude manually if GPS is unavailable

3. **Configure Preferences**:
   - Select preferred calculation method
   - Choose Asr juristic rule
   - Enable/disable Adhan for each prayer
   - Set notification preferences

### Home Screen

The home screen displays:

- **Next Prayer Card**: Shows the upcoming prayer with a live countdown timer
- **Prayer Schedule**: List of all five daily prayers with their times
- **Islamic Tools Grid**: Quick access to Qibla, Quran, Azkar, Calendar, Settings, and Adhan controls

### Qibla Compass

1. Navigate to the Qibla screen
2. Hold your device flat and calibrate if prompted
3. Rotate until the indicator aligns with the Qibla direction
4. The app automatically corrects for magnetic declination

### Adhan Settings

1. Go to Settings → Adhan
2. Toggle Adhan on/off globally
3. Enable/disable Adhan for individual prayers
4. Preview Adhan audio
5. Adjust volume and playback settings

### Notifications

- **Exact Alarms**: Used when supported (Android 12+ with special permission)
- **Inexact Alarms**: Fallback for devices without exact alarm permission
- **Boot Receiver**: Automatically restores alarms after device restart

---

## Project Structure

```
miqati/
├── .github/                       # GitHub workflows and templates
│   ├── workflows/
│   │   ├── ci.yml                 # Continuous Integration
│   │   └── release.yml            # Release automation
│   └── PULL_REQUEST_TEMPLATE.md
├── app/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/alateefs/miqati/
│   │   │   │   ├── MiqatiApplication.kt
│   │   │   │   ├── MainActivity.kt
│   │   │   │   ├── core/
│   │   │   │   │   ├── designsystem/
│   │   │   │   │   │   ├── MiqatiTheme.kt
│   │   │   │   │   │   ├── Color.kt
│   │   │   │   │   │   ├── Typography.kt
│   │   │   │   │   │   ├── Dimensions.kt
│   │   │   │   │   │   └── Theme.kt
│   │   │   │   │   ├── navigation/
│   │   │   │   │   │   ├── NavGraph.kt
│   │   │   │   │   │   └── Screen.kt
│   │   │   │   │   ├── common/
│   │   │   │   │   │   ├── Extensions.kt
│   │   │   │   │   │   ├── Constants.kt
│   │   │   │   │   │   └── Result.kt
│   │   │   │   │   └── di/
│   │   │   │   │       ├── AppModule.kt
│   │   │   │   │       └── CoroutineModule.kt
│   │   │   │   └── feature/
│   │   │   │       ├── home/
│   │   │   │       │   ├── presentation/
│   │   │   │       │   │   ├── HomeScreen.kt
│   │   │   │       │   │   ├── HomeViewModel.kt
│   │   │   │       │   │   └── HomeUiState.kt
│   │   │   │       │   ├── domain/
│   │   │   │       │   │   ├── repository/
│   │   │   │       │   │   ├── usecase/
│   │   │   │       │   │   └── model/
│   │   │   │       │   └── data/
│   │   │   │       ├── prayer/
│   │   │   │       │   ├── presentation/
│   │   │   │       │   ├── domain/
│   │   │   │       │   └── data/
│   │   │   │       ├── location/
│   │   │   │       │   ├── presentation/
│   │   │   │       │   ├── domain/
│   │   │   │       │   └── data/
│   │   │   │       ├── qibla/
│   │   │   │       │   ├── presentation/
│   │   │   │       │   ├── domain/
│   │   │   │       │   └── data/
│   │   │   │       ├── adhan/
│   │   │   │       │   ├── presentation/
│   │   │   │       │   ├── domain/
│   │   │   │       │   └── data/
│   │   │   │       ├── notifications/
│   │   │   │       │   ├── presentation/
│   │   │   │       │   ├── domain/
│   │   │   │       │   └── data/
│   │   │   │       ├── settings/
│   │   │   │       │   ├── presentation/
│   │   │   │       │   ├── domain/
│   │   │   │       │   └── data/
│   │   │   │       └── placeholder/
│   │   │   │           └── presentation/
│   │   │   ├── res/
│   │   │   │   ├── values/
│   │   │   │   │   ├── strings.xml
│   │   │   │   │   ├── colors.xml
│   │   │   │   │   └── themes.xml
│   │   │   │   ├── values-ar/
│   │   │   │   │   └── strings.xml
│   │   │   │   ├── drawable/
│   │   │   │   ├── mipmap/
│   │   │   │   └── raw/
│   │   │   │       └── adhan/
│   │   │   └── AndroidManifest.xml
│   │   ├── test/
│   │   │   └── java/com/alateefs/miqati/
│   │   │       ├── ExampleUnitTest.kt
│   │   │       └── feature/
│   │   └── androidTest/
│   │       └── java/com/alateefs/miqati/
│   │           └── ExampleInstrumentedTest.kt
│   └── build.gradle.kts
├── gradle/
│   ├── wrapper/
│   │   └── gradle-wrapper.properties
│   └── libs.versions.toml
├── docs/
│   ├── images/
│   ├── architecture.md
│   └── contributing.md
├── scripts/
│   ├── generate_apk.sh
│   └── run_tests.sh
├── .gitignore
├── LICENSE
├── README.md
└── settings.gradle.kts
```

---

## Design System

### Color Palette

Miqati uses a carefully selected color scheme inspired by Islamic art and modern design principles.

```kotlin
// Primary Colors
val EmeraldPrimary = Color(0xFF0D9488)      // Deep emerald green
val EmeraldLight = Color(0xFF14B8A6)        // Lighter emerald
val EmeraldDark = Color(0xFF0F766E)         // Darker emerald

// Accent Colors
val GoldAccent = Color(0xFFFBBF24)          // Warm gold
val GoldLight = Color(0xFFFCD34D)           // Light gold
val GoldDark = Color(0xFFF59E0B)            // Dark gold

// Neutral Colors
val NeutralBackground = Color(0xFFF8F9FA)   // Off-white background
val NeutralSurface = Color(0xFFFFFFFF)      // Pure white surface
val NeutralText = Color(0xFF1F2937)         // Dark gray text
val NeutralTextSecondary = Color(0xFF6B7280)// Medium gray text

// Status Colors
val Success = Color(0xFF10B981)             // Green success
val Warning = Color(0xFFF59E0B)             // Amber warning
val Error = Color(0xFFEF4444)               // Red error
val Info = Color(0xFF3B82F6)                // Blue info
```

### Typography

```kotlin
val MiqatiTypography = Typography(
    displayLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Bold,
        fontSize = 32.sp,
        lineHeight = 40.sp
    ),
    headlineMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.SemiBold,
        fontSize = 24.sp,
        lineHeight = 32.sp
    ),
    titleLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Medium,
        fontSize = 20.sp,
        lineHeight = 28.sp
    ),
    bodyLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp,
        lineHeight = 24.sp
    ),
    labelMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp
    )
)
```

### Spacing & Dimensions

```kotlin
object Dimensions {
    val spacingXxs = 4.dp
    val spacingXs = 8.dp
    val spacingSm = 12.dp
    val spacingMd = 16.dp
    val spacingLg = 24.dp
    val spacingXl = 32.dp
    val spacingXxl = 48.dp
    
    val cornerRadiusSm = 8.dp
    val cornerRadiusMd = 12.dp
    val cornerRadiusLg = 16.dp
    val cornerRadiusXl = 24.dp
    
    val iconSizeSm = 24.dp
    val iconSizeMd = 32.dp
    val iconSizeLg = 48.dp
}
```

### Components

All UI components follow Material 3 guidelines with customizations:

- **Cards**: Elevated cards with subtle shadows
- **Buttons**: Filled, outlined, and text variants
- **TopAppBar**: Consistent across all screens
- **BottomNavigation**: For primary navigation (if needed)
- **Dialogs**: Standardized dialog components
- **Loading States**: Shimmer effects and progress indicators

---

## Localization & RTL

### Supported Languages

- **English** (Default)
- **Arabic** (Full RTL support)
- *More languages planned*

### RTL Implementation

Miqati is built with RTL (Right-to-Left) support from day one:

```kotlin
// Use start/end instead of left/right
Modifier.padding(start = 16.dp, end = 16.dp)

// Use horizontal alignment
Alignment.CenterHorizontally

// Avoid hardcoded directions
// ❌ Modifier.padding(left = 16.dp)
// ✅ Modifier.padding(start = 16.dp)
```

### String Resources

All user-facing strings are externalized:

```xml
<!-- res/values/strings.xml -->
<string name="app_name">Miqati</string>
<string name="next_prayer">Next Prayer</string>
<string name="time_remaining">%1$s remaining</string>

<!-- res/values-ar/strings.xml -->
<string name="app_name">ميقاتي</string>
<string name="next_prayer">الصلاة القادمة</string>
<string name="time_remaining">متبقي %1$s</string>
```

### Date & Time Formatting

The app uses locale-aware formatting:

```kotlin
// Automatic locale detection
val formattedDate = DateFormat.getDateFormat(context).format(date)
val formattedTime = DateFormat.getTimeFormat(context).format(time)

// Hijri calendar support (planned)
val hijriDate = UmmAlQuraCalendar().apply { time = date }
```

---

## Testing Strategy

### Test Coverage Goals

| Layer | Target Coverage |
|-------|----------------|
| Domain | 80%+ |
| Data | 70%+ |
| Presentation | 60%+ |
| Overall | 70%+ |

### Unit Tests

Test business logic, use cases, and utilities:

```kotlin
@Test
fun `calculate prayer times returns valid result`() = runTest {
    // Given
    val coordinates = Coordinates(latitude = 21.4225, longitude = 39.8262)
    val date = LocalDate(2024, 1, 15)
    
    // When
    val result = prayerCalculator.calculate(coordinates, date)
    
    // Then
    assertTrue(result.isSuccess)
    assertNotNull(result.getOrNull())
}
```

### Widget Tests

Test critical UI flows:

```kotlin
@Test
fun homeScreen_displaysNextPrayerCountdown() {
    composeTestRule.setContent {
        MiqatiTheme {
            HomeScreen(viewModel = fakeViewModel)
        }
    }
    
    composeTestRule
        .onNodeWithText("Next Prayer")
        .assertExists()
}
```

### Integration Tests

Test component interactions:

```kotlin
@HiltAndroidTest
class PrayerRepositoryIntegrationTest {
    
    @get:Rule
    val hiltRule = HiltAndroidRule(this)
    
    @Inject
    lateinit var repository: PrayerRepository
    
    @Test
    fun repository_returnsPrayerTimesSuccessfully() = runTest {
        // Test implementation
    }
}
```

### Running Tests

```bash
# Run all unit tests
./gradlew test

# Run tests for specific module
./gradlew :feature:prayer:test

# Run instrumented tests
./gradlew connectedAndroidTest

# Generate coverage report
./gradlew jacocoTestReport
```

---

## Development Guidelines

### Code Style

Follow official Kotlin and Android coding conventions:

- **Naming**: Clear, descriptive names for classes, functions, and variables
- **Formatting**: Consistent indentation (4 spaces), line length (120 chars max)
- **Null Safety**: Avoid `!!`; use safe calls (`?.`) and Elvis operator (`?:`)
- **Comments**: Only for non-obvious technical decisions
- **File Size**: Keep files small and focused (< 500 lines)

### Architecture Principles

1. **Single Responsibility**: Each class should have one reason to change
2. **Dependency Inversion**: Depend on abstractions, not concretions
3. **Immutability**: Prefer `val` over `var`, use data classes
4. **Separation of Concerns**: UI, business logic, and data access are separate
5. **Testability**: Write testable code with clear interfaces

### Git Workflow

```bash
# Feature branch naming
feature/add-qibla-compass
fix/prayer-calculation-bug
refactor/home-screen-performance
docs/update-readme

# Commit message format
feat: add Qibla compass with magnetic correction
fix: resolve timezone issue in prayer calculation
docs: update installation instructions
test: add unit tests for prayer repository
```

### Code Review Checklist

- [ ] Code follows style guidelines
- [ ] No hardcoded strings or dimensions
- [ ] Proper error handling implemented
- [ ] Null safety enforced
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No unnecessary dependencies
- [ ] Performance considerations addressed

### Performance Best Practices

- **Composables**: Use `remember`, `derivedStateOf`, and key parameters
- **Lists**: Use `LazyColumn`/`LazyRow` instead of `Column`/`Row` with scrolling
- **Images**: Load images efficiently with Coil or similar
- **State**: Minimize state hoisting, use `StateFlow` for reactive updates
- **Coroutines**: Use appropriate dispatchers (IO, Default, Main)

---

## Roadmap

### Version 1.1 (Q2 2026)

- [ ] Multiple calculation methods UI
- [ ] Custom Adhan audio selection
- [ ] Additional reminder types (Witr, Tahajjud)
- [ ] Full Hijri calendar integration
- [ ] Improved location accuracy

### Version 1.2 (Q3 2026)

- [ ] Quran module (text + audio)
- [ ] Azkar and Dua library
- [ ] Home screen widgets
- [ ] Multi-city prayer times
- [ ] Mosque finder with offline maps

### Version 1.3 (Q4 2026)

- [ ] Hadith collection with search
- [ ] Group prayer coordination
- [ ] Daily reading reminders
- [ ] Donation integration
- [ ] Support for Android API 21-25

### Version 2.0 (2027)

- [ ] Wear OS support
- [ ] Android Auto integration
- [ ] Voice commands
- [ ] Advanced customization options
- [ ] Community features (optional, privacy-focused)

---

## Contributing

We welcome contributions from the community! Here's how you can help:

### Ways to Contribute

1. **Bug Reports**: Report bugs via GitHub Issues
2. **Feature Requests**: Suggest new features with detailed descriptions
3. **Code Contributions**: Submit pull requests with fixes or features
4. **Documentation**: Improve documentation, translations, or examples
5. **Testing**: Test beta versions and provide feedback
6. **Design**: Contribute UI/UX improvements

### Contribution Process

1. **Fork** the repository
2. **Create a branch**: `git checkout -b feature/amazing-feature`
3. **Make changes**: Implement your feature or fix
4. **Test thoroughly**: Ensure all tests pass
5. **Commit**: `git commit -m 'feat: add amazing feature'`
6. **Push**: `git push origin feature/amazing-feature`
7. **Open Pull Request**: Describe your changes clearly

### Pull Request Guidelines

- Follow the project's code style
- Include tests for new functionality
- Update documentation as needed
- Keep PRs focused and small
- Reference related issues

### Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Collaborate openly
- Prioritize user privacy and security

---

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2026 Abdulateef

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Acknowledgments

### Libraries & Tools

- [Adhan](https://github.com/batoulapps/adhan) - Prayer times calculation library by Batoul Apps
- [Jetpack Compose](https://developer.android.com/jetpack/compose) - Modern UI toolkit
- [Hilt](https://dagger.dev/hilt/) - Dependency injection
- [Media3](https://developer.android.com/media/media3) - Media playback
- [OSMDroid](https://github.com/osmdroid/osmdroid) - Offline maps

### Inspiration

- Material Design 3 guidelines
- Islamic art and geometry patterns
- Existing open-source Islamic apps
- Community feedback and suggestions

### Contributors

Special thanks to all contributors who have helped make Miqati better:

- [Your Name] - Initial work
- [Contributor 1] - Qibla compass implementation
- [Contributor 2] - Arabic translation
- [Contributor 3] - UI/UX improvements

---

## Contact & Support

- **GitHub**: [@alateefs](https://github.com/alateefs)
- **Email**: [sanossee@gmail.com](mailto:sanossee@gmail.com)
- **Website**: [miqati.app](https://miqati.app) (planned)

### Support the Project

If you find Miqati useful, consider supporting the project:

- ⭐ Star the repository
- 🐛 Report bugs and suggest features
- 💻 Contribute code or documentation
- 📢 Share with your community
- 💰 Optional donations (future feature)

---

<p align="center">
  <strong>Made with ❤️ for the Muslim Ummah</strong>
</p>

<p align="center">
  <sub>Built with modern Android technologies • Privacy-first • Offline-capable</sub>
</p>

<p align="center">
  © 2026 Miqati. All rights reserved.
</p>
