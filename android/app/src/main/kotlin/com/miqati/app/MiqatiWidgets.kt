package com.miqati.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import org.json.JSONObject
import java.util.Calendar

object MiqatiWidgetUpdater {
    fun refreshAll(context: Context) {
        val mgr = AppWidgetManager.getInstance(context)
        val pIds = mgr.getAppWidgetIds(ComponentName(context, MiqatiPrayerWidgetProvider::class.java))
        if (pIds.isNotEmpty()) MiqatiPrayerWidgetProvider.updateWidgets(context, mgr, pIds)

        val qIds = mgr.getAppWidgetIds(ComponentName(context, MiqatiQuranWidgetProvider::class.java))
        if (qIds.isNotEmpty()) MiqatiQuranWidgetProvider.updateWidgets(context, mgr, qIds)

        val aIds = mgr.getAppWidgetIds(ComponentName(context, MiqatiAdhkarWidgetProvider::class.java))
        if (aIds.isNotEmpty()) MiqatiAdhkarWidgetProvider.updateWidgets(context, mgr, aIds)
    }

    fun openTabPendingIntent(context: Context, tabIndex: Int, reqCode: Int): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            putExtra("OPEN_TAB", tabIndex)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val piFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        return PendingIntent.getActivity(context, reqCode, intent, piFlags)
    }
}

class MiqatiPrayerWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        updateWidgets(context, appWidgetManager, appWidgetIds)
    }

    companion object {
        private fun fmtTime(totalMins: Int): String {
            if (totalMins < 0) return "--:--"
            val norm = ((totalMins % 1440) + 1440) % 1440
            val h24 = norm / 60
            val m = norm % 60
            val h12 = if (h24 % 12 == 0) 12 else h24 % 12
            return String.format("%02d:%02d", h12, m)
        }

        fun updateWidgets(context: Context, mgr: AppWidgetManager, ids: IntArray) {
            val prefs = context.getSharedPreferences("miqati_native_alarms", Context.MODE_PRIVATE)
            val stateStr = context.getSharedPreferences("miqati_app_memory_v8", Context.MODE_PRIVATE)
                .getString("state_json", null)
            var city = "الرياض"
            if (stateStr != null) {
                try {
                    val obj = JSONObject(stateStr)
                    city = obj.optString("customGpsCityLabel", "الرياض")
                } catch (_: Exception) {}
            }

            val f = prefs.getInt("prayer_الفجر", 287)
            val d = prefs.getInt("prayer_الظهر", 698)
            val a = prefs.getInt("prayer_العصر", 886)
            val m = prefs.getInt("prayer_المغرب", 1028)
            val i = prefs.getInt("prayer_العشاء", 1118)

            val cal = Calendar.getInstance()
            val nowMins = cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE)
            val nextLabel = when {
                nowMins < f -> "القادمة: الفجر"
                nowMins < d -> "القادمة: الظهر"
                nowMins < a -> "القادمة: العصر"
                nowMins < m -> "القادمة: المغرب"
                nowMins < i -> "القادمة: العشاء"
                else -> "القادمة: الفجر"
            }

            val pi = MiqatiWidgetUpdater.openTabPendingIntent(context, 0, 801)
            for (id in ids) {
                val rv = RemoteViews(context.packageName, R.layout.widget_prayers)
                rv.setTextViewText(R.id.wp_city, "ميقاتي • $city")
                rv.setTextViewText(R.id.wp_next, nextLabel)
                rv.setTextViewText(R.id.wp_fajr, "الفجر\n${fmtTime(f)}")
                rv.setTextViewText(R.id.wp_dhuhr, "الظهر\n${fmtTime(d)}")
                rv.setTextViewText(R.id.wp_asr, "العصر\n${fmtTime(a)}")
                rv.setTextViewText(R.id.wp_maghrib, "المغرب\n${fmtTime(m)}")
                rv.setTextViewText(R.id.wp_isha, "العشاء\n${fmtTime(i)}")
                rv.setOnClickPendingIntent(R.id.widget_prayers_root, pi)
                mgr.updateAppWidget(id, rv)
            }
        }
    }
}

class MiqatiQuranWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        updateWidgets(context, appWidgetManager, appWidgetIds)
    }

    companion object {
        private val verses = listOf(
            "﴿إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا﴾",
            "﴿أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾",
            "﴿فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ﴾",
            "﴿وَرَتِّلِ الْقُرْآنَ تَرْتِيلًا﴾",
            "﴿إِنَّ مَعَ الْعُسْرِ يُسْرًا﴾"
        )

        fun updateWidgets(context: Context, mgr: AppWidgetManager, ids: IntArray) {
            val stateStr = context.getSharedPreferences("miqati_app_memory_v8", Context.MODE_PRIVATE)
                .getString("state_json", null)
            var savedPage = 1
            if (stateStr != null) {
                try {
                    savedPage = JSONObject(stateStr).optInt("savedMushafPage", 1)
                } catch (_: Exception) {}
            }
            val dayIdx = Calendar.getInstance().get(Calendar.DAY_OF_YEAR) % verses.size
            val pi = MiqatiWidgetUpdater.openTabPendingIntent(context, 1, 802)

            for (id in ids) {
                val rv = RemoteViews(context.packageName, R.layout.widget_quran)
                rv.setTextViewText(R.id.wq_page, "صفحة $savedPage")
                rv.setTextViewText(R.id.wq_ayah, verses[dayIdx])
                rv.setOnClickPendingIntent(R.id.widget_quran_root, pi)
                mgr.updateAppWidget(id, rv)
            }
        }
    }
}

class MiqatiAdhkarWidgetProvider : AppWidgetProvider() {
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == "com.miqati.app.ACTION_WIDGET_TASBIH") {
            val prefs = context.getSharedPreferences("miqati_widget_tasbih", Context.MODE_PRIVATE)
            val curr = prefs.getInt("count", 0) + 1
            prefs.edit().putInt("count", curr).apply()
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(ComponentName(context, MiqatiAdhkarWidgetProvider::class.java))
            updateWidgets(context, mgr, ids)
        }
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        updateWidgets(context, appWidgetManager, appWidgetIds)
    }

    companion object {
        private val adhkarList = listOf(
            "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ",
            "لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ",
            "اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبَيِّنَا مُحَمَّدٍ",
            "أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ",
            "حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ"
        )

        fun updateWidgets(context: Context, mgr: AppWidgetManager, ids: IntArray) {
            val wCount = context.getSharedPreferences("miqati_widget_tasbih", Context.MODE_PRIVATE).getInt("count", 0)
            val piOpen = MiqatiWidgetUpdater.openTabPendingIntent(context, 3, 803)
            val tasbihIntent = Intent(context, MiqatiAdhkarWidgetProvider::class.java).apply {
                action = "com.miqati.app.ACTION_WIDGET_TASBIH"
            }
            val piFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val piTasbih = PendingIntent.getBroadcast(context, 804, tasbihIntent, piFlags)
            val dhikrText = adhkarList[wCount % adhkarList.size]

            for (id in ids) {
                val rv = RemoteViews(context.packageName, R.layout.widget_adhkar)
                rv.setTextViewText(R.id.wa_tasbih_btn, "+ سبّح ($wCount)")
                rv.setTextViewText(R.id.wa_dhikr, dhikrText)
                rv.setOnClickPendingIntent(R.id.widget_adhkar_root, piOpen)
                rv.setOnClickPendingIntent(R.id.wa_tasbih_btn, piTasbih)
                mgr.updateAppWidget(id, rv)
            }
        }
    }
}
