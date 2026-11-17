#!/usr/bin/env python3
import glob
import os
import re
import shutil

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
manifest_path = os.path.join(ROOT, "android/app/src/main/AndroidManifest.xml")

if os.path.exists(manifest_path):
    m = open(manifest_path, "r", encoding="utf-8").read()
    perms = (
        '    <uses-permission android:name="android.permission.INTERNET" />\n'
        '    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />\n'
        '    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />\n'
        '    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />\n'
        '    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />\n'
        '    <uses-permission android:name="android.permission.USE_EXACT_ALARM" />\n'
        '    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />\n'
        '    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />\n'
        '    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />\n'
        '    <uses-permission android:name="android.permission.WAKE_LOCK" />\n'
        '    <uses-permission android:name="android.permission.VIBRATE" />\n'
    )
    if "SCHEDULE_EXACT_ALARM" not in m:
        m = m.replace("<application", perms + "\n    <application", 1)
    m = re.sub(r'android:label="[^"]*"', 'android:label="Miqati • ميقاتي"', m)
    components = (
        '        <receiver\n'
        '            android:name=".AdhanAlarmReceiver"\n'
        '            android:enabled="true"\n'
        '            android:exported="true">\n'
        '            <intent-filter>\n'
        '                <action android:name="com.miqati.app.ACTION_ADHAN_ALARM" />\n'
        '                <action android:name="android.intent.action.BOOT_COMPLETED" />\n'
        '                <action android:name="android.intent.action.LOCKED_BOOT_COMPLETED" />\n'
        '                <action android:name="android.intent.action.QUICKBOOT_POWERON" />\n'
        '                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />\n'
        '                <action android:name="android.intent.action.TIME_SET" />\n'
        '                <action android:name="android.intent.action.TIMEZONE_CHANGED" />\n'
        '            </intent-filter>\n'
        '        </receiver>\n'
        '        <service\n'
        '            android:name=".AdhanForegroundService"\n'
        '            android:enabled="true"\n'
        '            android:exported="false"\n'
        '            android:foregroundServiceType="mediaPlayback" />\n'
        '    </application>'
    )
    if "AdhanForegroundService" not in m:
        m = m.replace("</application>", components, 1)

    widget_receivers = (
        '        <receiver android:name=".MiqatiPrayerWidgetProvider" android:exported="true" android:label="ميقاتي — مواقيت الصلاة">\n'
        '            <intent-filter><action android:name="android.appwidget.action.APPWIDGET_UPDATE" /></intent-filter>\n'
        '            <meta-data android:name="android.appwidget.provider" android:resource="@xml/widget_prayers_info" />\n'
        '        </receiver>\n'
        '        <receiver android:name=".MiqatiQuranWidgetProvider" android:exported="true" android:label="ميقاتي — آية اليوم والقرآن">\n'
        '            <intent-filter><action android:name="android.appwidget.action.APPWIDGET_UPDATE" /></intent-filter>\n'
        '            <meta-data android:name="android.appwidget.provider" android:resource="@xml/widget_quran_info" />\n'
        '        </receiver>\n'
        '        <receiver android:name=".MiqatiAdhkarWidgetProvider" android:exported="true" android:label="ميقاتي — الأذكار والتسبيح">\n'
        '            <intent-filter>\n'
        '                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />\n'
        '                <action android:name="com.miqati.app.ACTION_WIDGET_TASBIH" />\n'
        '            </intent-filter>\n'
        '            <meta-data android:name="android.appwidget.provider" android:resource="@xml/widget_adhkar_info" />\n'
        '        </receiver>\n'
        '    </application>'
    )
    if "MiqatiPrayerWidgetProvider" not in m:
        m = m.replace("</application>", widget_receivers, 1)

    open(manifest_path, "w", encoding="utf-8").write(m)
    print("[✓] Injected permissions and Adhan background service into AndroidManifest.xml")

kt_files = (
    glob.glob(os.path.join(ROOT, "android/app/src/main/kotlin/**/MainActivity.kt"), recursive=True)
    + glob.glob(os.path.join(ROOT, "android/app/src/main/java/**/MainActivity.kt"), recursive=True)
)
if kt_files:
    kt_path = kt_files[0]
    kt_content = open(kt_path, "r", encoding="utf-8").read()
    pkg_match = re.search(r"^package\s+([\w.]+)", kt_content, re.M)
    pkg_name = pkg_match.group(1) if pkg_match else "com.miqati.app"
    template_kt = open(os.path.join(ROOT, "tools/MainActivity_template.kt"), "r", encoding="utf-8").read()
    final_kt = re.sub(r"^package\s+[\w.]+", f"package {pkg_name}", template_kt, count=1, flags=re.M)
    open(kt_path, "w", encoding="utf-8").write(final_kt)
    print(f"[✓] Injected native sensors, GPS, audio, persistence & notifications into {kt_path} ({pkg_name})")

logo_file = os.path.join(ROOT, "assets/logo/app_logo.png")
if os.path.exists(logo_file):
    anydpi_dir = os.path.join(ROOT, "android/app/src/main/res/mipmap-anydpi-v26")
    if os.path.exists(anydpi_dir):
        shutil.rmtree(anydpi_dir, ignore_errors=True)
    for folder in ["mipmap-mdpi", "mipmap-hdpi", "mipmap-xhdpi", "mipmap-xxhdpi", "mipmap-xxxhdpi"]:
        dest_dir = os.path.join(ROOT, "android/app/src/main/res", folder)
        os.makedirs(dest_dir, exist_ok=True)
        shutil.copy2(logo_file, os.path.join(dest_dir, "ic_launcher.png"))
        shutil.copy2(logo_file, os.path.join(dest_dir, "ic_launcher_round.png"))
    drawable_dir = os.path.join(ROOT, "android/app/src/main/res/drawable")
    os.makedirs(drawable_dir, exist_ok=True)
    shutil.copy2(logo_file, os.path.join(drawable_dir, "ic_miqati_logo.png"))
    print("[✓] Replaced all Android launcher & notification icons with assets/logo/app_logo.png")


# Inject MiqatiWidgets.kt alongside MainActivity.kt
if kt_files:
    kt_dir = os.path.dirname(kt_files[0])
    w_tpl = os.path.join(ROOT, "tools/MiqatiWidgets_template.kt")
    if os.path.exists(w_tpl):
        w_src = open(w_tpl, "r", encoding="utf-8").read()
        w_final = re.sub(r"^package\s+[\w.]+", f"package {pkg_name}", w_src, count=1, flags=re.M)
        open(os.path.join(kt_dir, "MiqatiWidgets.kt"), "w", encoding="utf-8").write(w_final)
        print("[✓] Injected Home Screen Widgets (Prayers, Quran, Adhkar) into", kt_dir)
