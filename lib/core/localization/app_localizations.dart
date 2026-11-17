import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(Locale('ar'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isAr => locale.languageCode == 'ar';

  static const Map<String, Map<String, String>> _values = {
    'ar': {
      'tab_prayers': 'الصلوات',
      'tab_quran': 'القرآن',
      'tab_qibla': 'القبلة',
      'tab_adhkar': 'الأذكار',
      'tab_calendar': 'التقويم',
      'tab_settings': 'الإعدادات',
      'next_prayer': 'الصلاة القادمة',
      'remaining': 'المتبقي على الأذان',
      'live_clock': 'الوقت الحالي',
      'fajr': 'الفجر',
      'sunrise': 'الشروق',
      'dhuhr': 'الظهر',
      'asr': 'العصر',
      'maghrib': 'المغرب',
      'isha': 'العشاء',
      'habit_tracker': 'سجل المحافظة على الصلوات الخمس',
      'prayer_locked': 'لم يحن وقت الصلاة بعد',
      'stop_adhan': '⏹ إيقاف الأذان',
      'adhan_playing_now': 'يُرفع الآن أذان',
      'iqamah_after': 'الإقامة بعد',
      'min_short': 'د',
      'qibla_title': 'بوصلة القبلة التلقائية الدقيقة',
      'qibla_bearing': 'زاوية القبلة',
      'device_heading': 'اتجاه هاتفك',
      'distance_to_makkah': 'المسافة إلى مكة',
      'coordinates': 'الإحداثيات',
      'km_unit': 'كم',
      'qibla_aligned': '✅ هاتفك متجه نحو القبلة المشرفة بدقة',
      'rotate_right': '↻ وجّه الهاتف لليمين بمقدار',
      'rotate_left': '↺ وجّه الهاتف لليسار بمقدار',
      'qibla_sensor_note': 'تعمل البوصلة تلقائياً عبر مستشعرات الهاتف ومجال الأرض المغناطيسي (معايرة بحركة ∞ عند الحاجة).',
      'gps_active': 'GPS تلقائي',
      'settings_title': 'الإعدادات المتقدمة',
      'contact_us': 'تواصل معنا',
      'about_privacy': 'حول التطبيق وسياسة الخصوصية',
      'secret_vault_title': 'خزينة الأدمن السرية',
      'enter_admin_password': 'أدخل كلمة السر',
      'unlock_admin': 'فتح لوحة الأدمن',
      'cancel': 'إلغاء',
    },
    'en': {
      'tab_prayers': 'Prayers',
      'tab_quran': 'Quran',
      'tab_qibla': 'Qibla',
      'tab_adhkar': 'Adhkar',
      'tab_calendar': 'Calendar',
      'tab_settings': 'Settings',
      'next_prayer': 'Next Prayer',
      'remaining': 'Time Remaining',
      'live_clock': 'Current Time',
      'fajr': 'Fajr',
      'sunrise': 'Sunrise',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
      'habit_tracker': 'Daily 5-Prayer Tracker',
      'prayer_locked': 'Prayer time has not entered yet',
      'stop_adhan': '⏹ Stop Adhan',
      'adhan_playing_now': 'Adhan Playing:',
      'iqamah_after': 'Iqamah in',
      'min_short': 'm',
      'qibla_title': 'Automatic Live Qibla Compass',
      'qibla_bearing': 'Qibla Bearing',
      'device_heading': 'Device Heading',
      'distance_to_makkah': 'Distance to Makkah',
      'coordinates': 'Coordinates',
      'km_unit': 'km',
      'qibla_aligned': '✅ Your phone is accurately aligned with the Qibla',
      'rotate_right': '↻ Turn your phone right by',
      'rotate_left': '↺ Turn your phone left by',
      'qibla_sensor_note': 'Compass updates automatically via hardware sensors & geomagnetic declination (wave in figure-8 to calibrate).',
      'gps_active': 'Auto GPS',
      'settings_title': 'Advanced Settings',
      'contact_us': 'Contact Us',
      'about_privacy': 'About & Privacy Policy',
      'secret_vault_title': 'Secret Admin Vault',
      'enter_admin_password': 'Enter Password',
      'unlock_admin': 'Unlock Admin',
      'cancel': 'Cancel',
    },
  };

  String tr(String key) {
    return _values[locale.languageCode]?[key] ?? _values['ar']![key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
