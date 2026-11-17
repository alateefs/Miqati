package com.miqati.app

import android.Manifest
import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.graphics.BitmapFactory
import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.location.Geocoder
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.net.HttpURLConnection
import java.net.URL
import java.util.Calendar
import java.util.Locale

class MainActivity : FlutterActivity(), SensorEventListener {
    private val CHANNEL = "com.miqati.app/adhan_service"
    private var sensorManager: SensorManager? = null
    private var currentHeadingDeg: Double = -1.0
    private val accelValues = FloatArray(3)
    private val magValues = FloatArray(3)
    private var hasAccel = false
    private var hasMag = false
    private var lastLat: Float = 24.6877f
    private var lastLng: Float = 46.7218f
    private var streamMediaPlayer: MediaPlayer? = null
    private var isStreamPlaying: Boolean = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestRequiredPermissions()
        initCompassSensors()
    }

    override fun onResume() {
        super.onResume()
        initCompassSensors()
    }

    override fun onPause() {
        super.onPause()
        sensorManager?.unregisterListener(this)
    }

    private fun requestRequiredPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val perms = mutableListOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION
            )
            if (Build.VERSION.SDK_INT >= 33) {
                perms.add("android.permission.POST_NOTIFICATIONS")
            }
            val missing = perms.filter { checkSelfPermission(it) != PackageManager.PERMISSION_GRANTED }
            if (missing.isNotEmpty()) {
                requestPermissions(missing.toTypedArray(), 701)
            }
        }
    }

    private fun initCompassSensors() {
        try {
            sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
            sensorManager?.unregisterListener(this)
            val aSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
            val mSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)
            val rSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
            @Suppress("DEPRECATION")
            val oSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ORIENTATION)

            if (aSensor != null) sensorManager?.registerListener(this, aSensor, SensorManager.SENSOR_DELAY_UI)
            if (mSensor != null) sensorManager?.registerListener(this, mSensor, SensorManager.SENSOR_DELAY_UI)
            if (rSensor != null) sensorManager?.registerListener(this, rSensor, SensorManager.SENSOR_DELAY_UI)
            if (oSensor != null) sensorManager?.registerListener(this, oSensor, SensorManager.SENSOR_DELAY_UI)
        } catch (_: Exception) {}
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event == null) return
        var rawAzimuthDeg: Double? = null

        when (event.sensor.type) {
            Sensor.TYPE_ACCELEROMETER -> {
                val alpha = 0.85f
                accelValues[0] = alpha * accelValues[0] + (1 - alpha) * event.values[0]
                accelValues[1] = alpha * accelValues[1] + (1 - alpha) * event.values[1]
                accelValues[2] = alpha * accelValues[2] + (1 - alpha) * event.values[2]
                hasAccel = true
            }
            Sensor.TYPE_MAGNETIC_FIELD -> {
                val alpha = 0.85f
                magValues[0] = alpha * magValues[0] + (1 - alpha) * event.values[0]
                magValues[1] = alpha * magValues[1] + (1 - alpha) * event.values[1]
                magValues[2] = alpha * magValues[2] + (1 - alpha) * event.values[2]
                hasMag = true
            }
            Sensor.TYPE_ROTATION_VECTOR -> {
                val rotMatrix = FloatArray(9)
                SensorManager.getRotationMatrixFromVector(rotMatrix, event.values)
                val orientation = FloatArray(3)
                SensorManager.getOrientation(rotMatrix, orientation)
                rawAzimuthDeg = (Math.toDegrees(orientation[0].toDouble()) + 360.0) % 360.0
            }
            @Suppress("DEPRECATION")
            Sensor.TYPE_ORIENTATION -> {
                if (rawAzimuthDeg == null && !hasMag) {
                    rawAzimuthDeg = (event.values[0].toDouble() + 360.0) % 360.0
                }
            }
        }

        if (hasAccel && hasMag) {
            val r = FloatArray(9)
            val i = FloatArray(9)
            if (SensorManager.getRotationMatrix(r, i, accelValues, magValues)) {
                val orient = FloatArray(3)
                SensorManager.getOrientation(r, orient)
                rawAzimuthDeg = (Math.toDegrees(orient[0].toDouble()) + 360.0) % 360.0
            }
        }

        if (rawAzimuthDeg != null) {
            val geoField = GeomagneticField(lastLat, lastLng, 0f, System.currentTimeMillis())
            val trueDeg = (rawAzimuthDeg + geoField.declination + 360.0) % 360.0
            currentHeadingDeg = trueDeg
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialTab" -> {
                    result.success(intent?.getIntExtra("OPEN_TAB", 0) ?: 0)
                }
                "pinWidget" -> {
                    val kind = call.argument<String>("kind") ?: "prayers"
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val mgr = getSystemService(AppWidgetManager::class.java)
                        if (mgr != null && mgr.isRequestPinAppWidgetSupported) {
                            val cls = when (kind) {
                                "quran" -> MiqatiQuranWidgetProvider::class.java
                                "adhkar" -> MiqatiAdhkarWidgetProvider::class.java
                                else -> MiqatiPrayerWidgetProvider::class.java
                            }
                            val provider = ComponentName(applicationContext, cls)
                            val ok = mgr.requestPinAppWidget(provider, null, null)
                            result.success(ok)
                        } else {
                            result.success(false)
                        }
                    } else {
                        result.success(false)
                    }
                }
                "refreshWidgets" -> {
                    MiqatiWidgetUpdater.refreshAll(applicationContext)
                    result.success(true)
                }
                "saveState" -> {
                    val jsonStr = call.argument<String>("json") ?: "{}"
                    getSharedPreferences("miqati_app_memory_v8", Context.MODE_PRIVATE)
                        .edit()
                        .putString("state_json", jsonStr)
                        .apply()
                    result.success(true)
                }
                "saveDiskJson" -> {
                    val key = call.argument<String>("key") ?: "default"
                    val jsonStr = call.argument<String>("json") ?: ""
                    Thread {
                        try {
                            val dir = File(filesDir, "miqati_offline_cache")
                            if (!dir.exists()) dir.mkdirs()
                            val safe = key.replace(Regex("[^a-zA-Z0-9_-]"), "_")
                            File(dir, "$safe.json").writeText(jsonStr)
                            runOnUiThread { result.success(true) }
                        } catch (_: Exception) {
                            runOnUiThread { result.success(false) }
                        }
                    }.start()
                }
                "loadDiskJson" -> {
                    val key = call.argument<String>("key") ?: "default"
                    Thread {
                        try {
                            val dir = File(filesDir, "miqati_offline_cache")
                            val safe = key.replace(Regex("[^a-zA-Z0-9_-]"), "_")
                            val f = File(dir, "$safe.json")
                            val content = if (f.exists()) f.readText() else null
                            runOnUiThread { result.success(content) }
                        } catch (_: Exception) {
                            runOnUiThread { result.success(null) }
                        }
                    }.start()
                }
                "loadState" -> {
                    val jsonStr = getSharedPreferences("miqati_app_memory_v8", Context.MODE_PRIVATE)
                        .getString("state_json", null)
                    result.success(jsonStr)
                }
                "requestPermissions" -> {
                    requestRequiredPermissions()
                    val hasLoc = Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
                        checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
                        checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
                    val hasNotif = Build.VERSION.SDK_INT < 33 ||
                        checkSelfPermission("android.permission.POST_NOTIFICATIONS") == PackageManager.PERMISSION_GRANTED
                    result.success(mapOf("location" to hasLoc, "notifications" to hasNotif))
                }
                "openBatterySettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.fromParts("package", packageName, null)
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (_: Exception) {
                        result.success(false)
                    }
                }
                "getCompassHeading" -> {
                    result.success(currentHeadingDeg)
                }
                "getGpsLocation" -> {
                    fetchHardwareGpsLocation(result)
                }
                "getAudioStatus" -> {
                    result.success(mapOf(
                        "adhanPlaying" to AdhanForegroundService.isCurrentlyPlaying,
                        "streamPlaying" to isStreamPlaying
                    ))
                }
                "scheduleAlarms" -> {
                    val times = call.argument<Map<String, Int>>("times") ?: emptyMap()
                    val voiceAsset = call.argument<String>("voiceAsset") ?: "assets/audio/adhan_main.mp3"
                    val lang = call.argument<String>("lang") ?: "ar"
                    AdhanSchedulerHelper.saveAndScheduleAll(applicationContext, times, voiceAsset, lang)
                    MiqatiWidgetUpdater.refreshAll(applicationContext)
                    result.success(true)
                }
                "startAdhanNotification" -> {
                    val prayerName = call.argument<String>("prayerName") ?: "الصلاة"
                    val voiceAsset = call.argument<String>("voiceAsset") ?: "assets/audio/adhan_main.mp3"
                    val lang = call.argument<String>("lang") ?: "ar"
                    val isTest = call.argument<Boolean>("isTest") ?: false
                    AdhanSchedulerHelper.startAdhanService(applicationContext, prayerName, voiceAsset, lang, isTest)
                    result.success(true)
                }
                "stopAdhanNotification" -> {
                    stopStreamAudio()
                    val stopIntent = Intent(applicationContext, AdhanForegroundService::class.java).apply {
                        action = AdhanForegroundService.ACTION_STOP_ADHAN
                    }
                    applicationContext.startService(stopIntent)
                    result.success(true)
                }
                "showInstantNotification" -> {
                    val title = call.argument<String>("title") ?: "تنبيه ميقاتي"
                    val body = call.argument<String>("body") ?: ""
                    showSystemPushNotification(title, body)
                    result.success(true)
                }
                "playAudioUrl" -> {
                    val url = call.argument<String>("url") ?: ""
                    playRemoteOrAssetAudio(url, result)
                }
                "stopAudio" -> {
                    stopStreamAudio()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun fetchHardwareGpsLocation(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED &&
                checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED
            ) {
                requestRequiredPermissions()
                result.success(null)
                return
            }
            val lm = getSystemService(Context.LOCATION_SERVICE) as LocationManager
            val bestLoc: Location? = lm.getLastKnownLocation(LocationManager.GPS_PROVIDER)
                ?: lm.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)
                ?: lm.getLastKnownLocation(LocationManager.PASSIVE_PROVIDER)

            if (bestLoc != null) {
                lastLat = bestLoc.latitude.toFloat()
                lastLng = bestLoc.longitude.toFloat()
                val cityName = resolveCityName(bestLoc.latitude, bestLoc.longitude)
                val tzHours = java.util.TimeZone.getDefault().getOffset(System.currentTimeMillis()) / 3600000.0
                result.success(mapOf(
                    "lat" to bestLoc.latitude,
                    "lng" to bestLoc.longitude,
                    "tz" to tzHours,
                    "city" to cityName
                ))
                return
            }

            val provider = when {
                lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER) -> LocationManager.NETWORK_PROVIDER
                lm.isProviderEnabled(LocationManager.GPS_PROVIDER) -> LocationManager.GPS_PROVIDER
                else -> null
            }
            if (provider != null) {
                var replied = false
                @Suppress("DEPRECATION")
                lm.requestSingleUpdate(provider, object : LocationListener {
                    override fun onLocationChanged(loc: Location) {
                        if (replied) return
                        replied = true
                        lastLat = loc.latitude.toFloat()
                        lastLng = loc.longitude.toFloat()
                        val cName = resolveCityName(loc.latitude, loc.longitude)
                        val tzH = java.util.TimeZone.getDefault().getOffset(System.currentTimeMillis()) / 3600000.0
                        try {
                            result.success(mapOf(
                                "lat" to loc.latitude,
                                "lng" to loc.longitude,
                                "tz" to tzH,
                                "city" to cName
                            ))
                        } catch (_: Exception) {}
                    }
                    @Deprecated("Deprecated in Java")
                    override fun onStatusChanged(p: String?, s: Int, b: Bundle?) {}
                    override fun onProviderEnabled(p: String) {}
                    override fun onProviderDisabled(p: String) {}
                }, mainLooper)
            } else {
                result.success(null)
            }
        } catch (_: Exception) {
            result.success(null)
        }
    }

    private fun resolveCityName(lat: Double, lng: Double): String {
        return try {
            val geocoder = Geocoder(this, Locale.getDefault())
            @Suppress("DEPRECATION")
            val list = geocoder.getFromLocation(lat, lng, 1)
            if (!list.isNullOrEmpty()) {
                val addr = list[0]
                val city = addr.locality ?: addr.subAdminArea ?: addr.adminArea ?: "GPS"
                val country = addr.countryName ?: ""
                if (country.isNotEmpty()) "$city، $country" else city
            } else {
                ""
            }
        } catch (_: Exception) {
            ""
        }
    }

    private fun showSystemPushNotification(title: String, body: String) {
        val channelId = "miqati_push_alerts_channel_v8"
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val ch = NotificationChannel(channelId, "Miqati Alerts / إشعارات ميقاتي", NotificationManager.IMPORTANCE_HIGH).apply {
                enableVibration(true)
            }
            nm.createNotificationChannel(ch)
        }
        val openIntent = Intent(this, MainActivity::class.java)
        val piFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pi = PendingIntent.getActivity(this, 202, openIntent, piFlags)
        val logoResId = resources.getIdentifier("ic_miqati_logo", "drawable", packageName)
            .takeIf { it != 0 } ?: resources.getIdentifier("ic_launcher", "mipmap", packageName)
        val largeLogo = if (logoResId != 0) BitmapFactory.decodeResource(resources, logoResId) else null

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, channelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        builder
            .setSmallIcon(if (logoResId != 0) logoResId else android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(Notification.BigTextStyle().bigText(body))
            .setContentIntent(pi)
            .setAutoCancel(true)
        if (largeLogo != null) {
            builder.setLargeIcon(largeLogo)
        }
        nm.notify((System.currentTimeMillis() % 10000).toInt(), builder.build())
    }

    private fun playRemoteOrAssetAudio(urlOrAsset: String, result: MethodChannel.Result) {
        if (urlOrAsset.isBlank()) {
            result.success(false)
            return
        }
        stopStreamAudio()
        var replied = false
        fun replyOnce(ok: Boolean) {
            if (!replied) {
                replied = true
                runOnUiThread { result.success(ok) }
            }
        }

        if (urlOrAsset.startsWith("http")) {
            try {
                streamMediaPlayer = MediaPlayer().apply {
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                            .build()
                    )
                    setDataSource(urlOrAsset)
                    setOnPreparedListener { mp ->
                        isStreamPlaying = true
                        mp.start()
                        replyOnce(true)
                    }
                    setOnCompletionListener {
                        isStreamPlaying = false
                        stopStreamAudio()
                    }
                    setOnErrorListener { _, _, _ ->
                        isStreamPlaying = false
                        // Fallback: download to cacheDir and play locally
                        downloadAndPlayFallback(urlOrAsset, ::replyOnce)
                        true
                    }
                    prepareAsync()
                }
            } catch (_: Exception) {
                downloadAndPlayFallback(urlOrAsset, ::replyOnce)
            }
            return
        }

        Thread {
            try {
                val cacheFolder = File(cacheDir, "miqati_audio_cache")
                if (!cacheFolder.exists()) cacheFolder.mkdirs()
                val clean = urlOrAsset.removePrefix("/")
                val localFile = File(cacheFolder, "asset_" + clean.replace("/", "_"))
                assets.open("flutter_assets/$clean").use { inp ->
                    FileOutputStream(localFile).use { out -> inp.copyTo(out) }
                }
                runOnUiThread {
                    try {
                        streamMediaPlayer = MediaPlayer().apply {
                            setAudioAttributes(
                                AudioAttributes.Builder()
                                    .setUsage(AudioAttributes.USAGE_MEDIA)
                                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                                    .build()
                            )
                            setDataSource(localFile.absolutePath)
                            setOnCompletionListener {
                                isStreamPlaying = false
                                stopStreamAudio()
                            }
                            prepare()
                            start()
                        }
                        isStreamPlaying = true
                        replyOnce(true)
                    } catch (_: Exception) {
                        isStreamPlaying = false
                        replyOnce(false)
                    }
                }
            } catch (_: Exception) {
                isStreamPlaying = false
                replyOnce(false)
            }
        }.start()
    }

    private fun downloadAndPlayFallback(urlStr: String, replyOnce: (Boolean) -> Unit) {
        Thread {
            try {
                val cacheFolder = File(cacheDir, "miqati_audio_cache")
                if (!cacheFolder.exists()) cacheFolder.mkdirs()
                val safeName = "online_" + urlStr.hashCode().toString().replace("-", "m") + ".mp3"
                val localFile = File(cacheFolder, safeName)
                if (!localFile.exists() || localFile.length() < 512) {
                    val conn = URL(urlStr).openConnection() as HttpURLConnection
                    conn.setRequestProperty("User-Agent", "Mozilla/5.0")
                    conn.connectTimeout = 10000
                    conn.readTimeout = 15000
                    conn.instanceFollowRedirects = true
                    conn.inputStream.use { inp ->
                        FileOutputStream(localFile).use { out -> inp.copyTo(out) }
                    }
                }
                runOnUiThread {
                    try {
                        stopStreamAudio()
                        streamMediaPlayer = MediaPlayer().apply {
                            setAudioAttributes(
                                AudioAttributes.Builder()
                                    .setUsage(AudioAttributes.USAGE_MEDIA)
                                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                                    .build()
                            )
                            setDataSource(localFile.absolutePath)
                            setOnCompletionListener {
                                isStreamPlaying = false
                                stopStreamAudio()
                            }
                            prepare()
                            start()
                        }
                        isStreamPlaying = true
                        replyOnce(true)
                    } catch (_: Exception) {
                        isStreamPlaying = false
                        replyOnce(false)
                    }
                }
            } catch (_: Exception) {
                isStreamPlaying = false
                replyOnce(false)
            }
        }.start()
    }

    private fun stopStreamAudio() {
        isStreamPlaying = false
        try {
            streamMediaPlayer?.let {
                if (it.isPlaying) it.stop()
                it.release()
            }
        } catch (_: Exception) {}
        streamMediaPlayer = null
    }
}


object AdhanSchedulerHelper {
    private const val PREFS_NAME = "miqati_native_alarms"

    fun saveAndScheduleAll(context: Context, prayerMinutesMap: Map<String, Int>, voiceAsset: String, lang: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val editor = prefs.edit()
        editor.putString("voiceAsset", voiceAsset)
        editor.putString("appLang", lang)
        for ((name, mins) in prayerMinutesMap) {
            editor.putInt("prayer_$name", mins)
            scheduleSinglePrayer(context, name, mins, voiceAsset, lang)
        }
        editor.apply()
    }

    fun rescheduleFromPrefs(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val voiceAsset = prefs.getString("voiceAsset", "assets/audio/adhan_main.mp3") ?: "assets/audio/adhan_main.mp3"
        val lang = prefs.getString("appLang", "ar") ?: "ar"
        val prayers = listOf("الفجر", "الظهر", "العصر", "المغرب", "العشاء")
        for (name in prayers) {
            val mins = prefs.getInt("prayer_$name", -1)
            if (mins >= 0) {
                scheduleSinglePrayer(context, name, mins, voiceAsset, lang)
            }
        }
    }

    private fun scheduleSinglePrayer(context: Context, prayerName: String, totalMinutes: Int, voiceAsset: String, lang: String) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val cal = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, (totalMinutes / 60) % 24)
            set(Calendar.MINUTE, totalMinutes % 60)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            if (timeInMillis <= System.currentTimeMillis()) {
                add(Calendar.DAY_OF_YEAR, 1)
            }
        }

        val intent = Intent(context, AdhanAlarmReceiver::class.java).apply {
            action = "com.miqati.app.ACTION_ADHAN_ALARM"
            putExtra("PRAYER_NAME", prayerName)
            putExtra("VOICE_ASSET", voiceAsset)
            putExtra("APP_LANG", lang)
        }

        val piFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            prayerName.hashCode(),
            intent,
            piFlags
        )

        val openAppIntent = Intent(context, MainActivity::class.java)
        val showPending = PendingIntent.getActivity(context, 777, openAppIntent, piFlags)

        try {
            // setAlarmClock wakes Xiaomi / Doze devices reliably even when app is killed
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                alarmManager.setAlarmClock(AlarmManager.AlarmClockInfo(cal.timeInMillis, showPending), pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, cal.timeInMillis, pendingIntent)
            }
        } catch (_: SecurityException) {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, cal.timeInMillis, pendingIntent)
                } else {
                    alarmManager.set(AlarmManager.RTC_WAKEUP, cal.timeInMillis, pendingIntent)
                }
            } catch (_: Exception) {}
        }
    }

    fun startAdhanService(context: Context, prayerName: String, voiceAsset: String, lang: String, isTest: Boolean) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        if (!isTest) {
            // Deduplication lock: prevent double Adhan within 120 seconds for the same prayer
            val dayKey = Calendar.getInstance().get(Calendar.DAY_OF_YEAR)
            val triggerKey = "${prayerName}_$dayKey"
            val lastKey = prefs.getString("last_adhan_key", "")
            val lastTs = prefs.getLong("last_adhan_ts", 0L)
            val now = System.currentTimeMillis()
            if (lastKey == triggerKey && (now - lastTs) < 120_000L) {
                return
            }
            prefs.edit().putString("last_adhan_key", triggerKey).putLong("last_adhan_ts", now).apply()
        }

        val serviceIntent = Intent(context, AdhanForegroundService::class.java).apply {
            putExtra("PRAYER_NAME", prayerName)
            putExtra("VOICE_ASSET", voiceAsset)
            putExtra("APP_LANG", lang)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }
    }
}

class AdhanAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            "android.intent.action.LOCKED_BOOT_COMPLETED",
            "android.intent.action.QUICKBOOT_POWERON",
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED -> {
                AdhanSchedulerHelper.rescheduleFromPrefs(context)
            }
            "com.miqati.app.ACTION_ADHAN_ALARM" -> {
                val prayerName = intent.getStringExtra("PRAYER_NAME") ?: "الصلاة"
                val voiceAsset = intent.getStringExtra("VOICE_ASSET") ?: "assets/audio/adhan_main.mp3"
                val lang = intent.getStringExtra("APP_LANG") ?: "ar"
                AdhanSchedulerHelper.startAdhanService(context, prayerName, voiceAsset, lang, false)
                AdhanSchedulerHelper.rescheduleFromPrefs(context)
            }
        }
    }
}

class AdhanForegroundService : Service() {
    companion object {
        const val ACTION_STOP_ADHAN = "com.miqati.app.ACTION_STOP_ADHAN"
        const val CHANNEL_ID = "miqati_adhan_foreground_channel_v8"
        const val NOTIF_ID = 7701
        @Volatile
        var isCurrentlyPlaying: Boolean = false
    }

    private var mediaPlayer: MediaPlayer? = null

    private fun translatePrayerEn(arName: String): String {
        return when (arName) {
            "الفجر" -> "Fajr"
            "الشروق" -> "Sunrise"
            "الظهر" -> "Dhuhr"
            "العصر" -> "Asr"
            "المغرب" -> "Maghrib"
            "العشاء" -> "Isha"
            else -> arName
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP_ADHAN) {
            stopAudioAndSelf()
            return START_NOT_STICKY
        }

        val prayerName = intent?.getStringExtra("PRAYER_NAME") ?: "الصلاة"
        val voiceAsset = intent?.getStringExtra("VOICE_ASSET") ?: "assets/audio/adhan_main.mp3"
        val lang = intent?.getStringExtra("APP_LANG") ?: "ar"
        val isEn = lang == "en"

        createNotificationChannel()

        val piFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val stopIntent = Intent(this, AdhanForegroundService::class.java).apply {
            action = ACTION_STOP_ADHAN
        }
        val stopPendingIntent = PendingIntent.getService(this, 99, stopIntent, piFlags)

        val openAppIntent = Intent(this, MainActivity::class.java)
        val openPendingIntent = PendingIntent.getActivity(this, 100, openAppIntent, piFlags)

        val stopLabel = if (isEn) "⏹ Stop Adhan" else "⏹ إيقاف الأذان"
        val titleText = if (isEn) "Time for ${translatePrayerEn(prayerName)} Adhan" else "حان الآن موعد أذان $prayerName"
        val bodyText = if (isEn) "Come to prayer • Tap Stop to silence Adhan" else "حي على الصلاة • حي على الفلاح — اضغط إيقاف لإسكات الأذان"

        val logoResId = resources.getIdentifier("ic_miqati_logo", "drawable", packageName)
            .takeIf { it != 0 } ?: resources.getIdentifier("ic_launcher", "mipmap", packageName)
        val largeLogo = if (logoResId != 0) BitmapFactory.decodeResource(resources, logoResId) else null

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        val stopAction = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Notification.Action.Builder(
                android.graphics.drawable.Icon.createWithResource(this, android.R.drawable.ic_media_pause),
                stopLabel,
                stopPendingIntent
            ).build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Action.Builder(
                android.R.drawable.ic_media_pause,
                stopLabel,
                stopPendingIntent
            ).build()
        }

        builder
            .setSmallIcon(if (logoResId != 0) logoResId else android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(titleText)
            .setContentText(bodyText)
            .setContentIntent(openPendingIntent)
            .setDeleteIntent(stopPendingIntent)
            .addAction(stopAction)
            .setOngoing(true)
        if (largeLogo != null) {
            builder.setLargeIcon(largeLogo)
        }

        val notification = builder.build()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIF_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
        } else {
            startForeground(NOTIF_ID, notification)
        }

        isCurrentlyPlaying = true
        playAdhanAudioFromAssetOrTemp(voiceAsset)
        return START_STICKY
    }

    private fun playAdhanAudioFromAssetOrTemp(voiceAsset: String) {
        stopMediaPlayerOnly()
        try {
            val clean = voiceAsset.removePrefix("/")
            val tempFile = File(cacheDir, "active_adhan_sound.mp3")
            assets.open("flutter_assets/$clean").use { inp ->
                FileOutputStream(tempFile).use { out ->
                    inp.copyTo(out)
                }
            }
            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                )
                setDataSource(tempFile.absolutePath)
                setOnCompletionListener { stopAudioAndSelf() }
                prepare()
                start()
            }
        } catch (_: Exception) {
            try {
                val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                    ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                mediaPlayer = MediaPlayer.create(this, alarmUri)?.apply {
                    isLooping = false
                    setOnCompletionListener { stopAudioAndSelf() }
                    start()
                }
            } catch (_: Exception) {
                stopAudioAndSelf()
            }
        }
    }

    private fun stopMediaPlayerOnly() {
        try {
            mediaPlayer?.let {
                if (it.isPlaying) it.stop()
                it.release()
            }
        } catch (_: Exception) {}
        mediaPlayer = null
    }

    private fun stopAudioAndSelf() {
        isCurrentlyPlaying = false
        stopMediaPlayerOnly()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "تنبيهات الأذان ومواقيت الصلاة",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "إشعار الأذان الصوتي مع زر إيقاف الأذان المباشر"
                setSound(null, null)
                enableVibration(true)
            }
            val nm = getSystemService(NotificationManager::class.java)
            nm.createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        isCurrentlyPlaying = false
        stopMediaPlayerOnly()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
