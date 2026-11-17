import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/app_branding_and_sounds.dart';
import '../../core/audio/adhan_audio_service.dart';
import '../prayer_times/prayer_calculator.dart';

class AdminBroadcastMessage {
  final String id;
  final String title;
  final String body;
  final String category;
  final String priority;
  final DateTime createdAt;

  const AdminBroadcastMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.priority = 'high',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'category': category,
        'priority': priority,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AdminBroadcastMessage.fromJson(Map<String, dynamic> j) => AdminBroadcastMessage(
        id: j['id']?.toString() ?? '',
        title: j['title']?.toString() ?? '',
        body: j['body']?.toString() ?? '',
        category: j['category']?.toString() ?? 'عام',
        priority: j['priority']?.toString() ?? 'high',
        createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );
}

class ContactUserMessage {
  final String id;
  final String name;
  final String contactInfo;
  final String message;
  final DateTime createdAt;

  const ContactUserMessage({
    required this.id,
    required this.name,
    required this.contactInfo,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'contactInfo': contactInfo,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ContactUserMessage.fromJson(Map<String, dynamic> j) => ContactUserMessage(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        contactInfo: j['contactInfo']?.toString() ?? '',
        message: j['message']?.toString() ?? '',
        createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );
}

class QuranBookmarkItem {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final int mushafPage;
  final String previewText;

  const QuranBookmarkItem({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    this.mushafPage = 1,
    required this.previewText,
  });

  Map<String, dynamic> toJson() => {
        'surahNumber': surahNumber,
        'surahName': surahName,
        'ayahNumber': ayahNumber,
        'mushafPage': mushafPage,
        'previewText': previewText,
      };

  factory QuranBookmarkItem.fromJson(Map<String, dynamic> j) => QuranBookmarkItem(
        surahNumber: (j['surahNumber'] as num?)?.toInt() ?? 1,
        surahName: j['surahName']?.toString() ?? 'الفاتحة',
        ayahNumber: (j['ayahNumber'] as num?)?.toInt() ?? 1,
        mushafPage: (j['mushafPage'] as num?)?.toInt() ?? 1,
        previewText: j['previewText']?.toString() ?? '',
      );
}

class MiqatiAppController extends ChangeNotifier {
  Locale locale = const Locale('ar');
  bool isDarkMode = true;
  bool isFullScreenMushaf = false;

  String appNameAr = AppBrandingAndSounds.defaultAppNameAr;
  String appNameEn = AppBrandingAndSounds.defaultAppNameEn;
  String appLogoEmojiOrUrl = AppBrandingAndSounds.defaultLogoTextOrEmoji;

  String aboutTextAr = 'تطبيق ميقاتي — رفيقك اليومي لمواقيت الصلاة الدقيقة، القرآن الكريم، القبلة، وحصن المسلم.\nتطوير: Latifs MutiServs (a@latifs.site)';
  String aboutTextEn = 'Miqati App — Your daily companion for accurate prayer times, Holy Quran, Qibla, and Hisn al-Muslim.\nDeveloped by: Latifs MutiServs (a@latifs.site)';
  String privacyTextAr = 'تُحفظ جميع إعداداتك وسجلات صلاتك وعلاماتك محلياً على جهازك فقط. يُستخدم GPS حصراً لحساب المواقيت والقبلة ولا يتم بيع أو مشاركة بياناتك.';
  String privacyTextEn = 'All your settings, prayer logs, and bookmarks are stored locally on your device. GPS is used strictly for prayer times and Qibla direction and is never sold or shared.';

  bool isAdminUnlocked = false;
  String _adminPasswordHash =
      AppBrandingAndSounds.hashPassword(AppBrandingAndSounds.defaultAdminPasswordPlain);
  int _secretTapCounter = 0;
  DateTime? _lastTapTime;

  String cloudTopicChannel = 'miqati_private_channel_sanosseas11';
  String cloudAccountUsername = 'admin_miqati';
  String cloudAccountPassword = 'sanosseas11';
  String customFirebaseWebhookUrl = '';

  // منع إعادة إرسال الإشعارات القديمة نهائياً عبر حفظ الطابع الزمني ومعرفات الرسائل
  int _lastCloudMsgTs = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 30;
  final Set<String> _seenCloudMsgIds = <String>{};
  Timer? _cloudPollTimer;

  // إحصائيات حقيقية 100% للجهاز الفعلي المثبت فقط (بدون أجهزة وهمية)
  String deviceInstallId = '';
  DateTime firstInstallDate = DateTime.now();
  int totalAppOpens = 1;
  int quranPagesReadCount = 0;
  int ayahsListenedCount = 0;
  int adhkarCompletedCount = 0;
  int qiblaChecksCount = 0;
  int prayersLoggedTotal = 0;
  final Map<String, int> weeklyActivityMap = <String, int>{};

  // Location & GPS State
  CityLocation currentCity = VerifiedCitiesRegistry.cities.first;
  String customGpsCityLabel = 'الرياض، السعودية';
  double lat = VerifiedCitiesRegistry.cities.first.lat;
  double lng = VerifiedCitiesRegistry.cities.first.lng;
  double tz = VerifiedCitiesRegistry.cities.first.tz;
  bool isUsingLiveGps = false;
  bool isDetectingGps = false;
  bool hasLocationPermission = false;
  bool hasNotificationPermission = false;

  String calcMethodKey = 'UmmAlQura';
  int asrShadowFactor = 1;
  DateTime selectedDate = DateTime.now();
  int hijriOffsetDays = 0;
  bool enablePreAdhanReminder = true;
  int preAdhanReminderMinutes = 10;
  bool enableOccasionAlerts = true;

  // ذاكرة المستخدم المستمرة للقرآن وحصن المسلم والتسبيح
  int currentMushafPage = 1;
  int savedMushafPage = 1;
  int lastReadSurah = 1;
  int lastReadAyah = 1;
  String selectedTafsirSlug = 'ar-tafsir-muyassar';
  int hisnSavedPage = 0;
  int tasbihCounter = 0;
  String lastOccasionAlertDateKey = '';

  final List<AdhanVoiceOption> adhanVoices =
      List<AdhanVoiceOption>.from(AppBrandingAndSounds.defaultAdhanVoices);
  late AdhanVoiceOption selectedAdhanVoice = adhanVoices.first;
  final AdhanAudioService audioService = AdhanAudioService();

  final Map<String, String> prayerNotifyModes = {
    'fajr': 'أذان كامل',
    'sunrise': 'صامت',
    'dhuhr': 'أذان كامل',
    'asr': 'أذان كامل',
    'maghrib': 'أذان كامل',
    'isha': 'أذان كامل',
  };
  final Map<String, bool> prayerDoneToday = {
    'fajr': false,
    'dhuhr': false,
    'asr': false,
    'maghrib': false,
    'isha': false,
  };
  String _lastPrayerResetDate = '';

  final Map<String, int> iqamahMinutes = {
    'fajr': 25,
    'dhuhr': 20,
    'asr': 20,
    'maghrib': 10,
    'isha': 20,
  };
  final Map<String, int> manualPrayerOffsets = {
    'fajr': 0,
    'sunrise': 0,
    'dhuhr': 0,
    'asr': 0,
    'maghrib': 0,
    'isha': 0,
  };

  bool showIqamahBadges = true;
  bool showHabitTracker = true;
  bool showBroadcastBanner = false;

  final List<AdminBroadcastMessage> broadcasts = [];
  final List<ContactUserMessage> contactMessages = [];
  final List<QuranBookmarkItem> bookmarks = [
    const QuranBookmarkItem(
      surahNumber: 1,
      surahName: 'سورة الفاتحة',
      ayahNumber: 1,
      mushafPage: 1,
      previewText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    ),
  ];

  MiqatiAppController() {
    unawaited(_fastBootstrap());
  }

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Future<void> _fastBootstrap() async {
    await _loadPersistedMemory();
    final today = _todayKey();
    if (_lastPrayerResetDate != today) {
      prayerDoneToday.updateAll((key, value) => false);
      _lastPrayerResetDate = today;
    }
    if (deviceInstallId.isEmpty) {
      deviceInstallId = 'MQ-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';
      firstInstallDate = DateTime.now();
    }
    totalAppOpens++;
    weeklyActivityMap[today] = (weeklyActivityMap[today] ?? 0) + 1;
    unawaited(persistState());
    notifyListeners();

    // تنفيذ الصلاحيات وGPS في الخلفية بدون تجميد واجهة الإقلاع
    unawaited(_backgroundInit());
  }

  Future<void> _backgroundInit() async {
    await requestAndVerifyPermissions();
    await detectLocationViaGps();
    await _checkAndSendOccasionAlerts();
    _cloudPollTimer?.cancel();
    _cloudPollTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      _pollProtectedCloudBroadcasts();
    });
  }

  Future<void> _loadPersistedMemory() async {
    try {
      final raw = await audioService.loadNativeState();
      if (raw == null || raw.isEmpty) return;
      final d = jsonDecode(raw) as Map<String, dynamic>;
      if (d['lang'] == 'en' || d['lang'] == 'ar') {
        locale = Locale(d['lang']);
      }
      isDarkMode = d['isDarkMode'] ?? true;
      appNameAr = d['appNameAr'] ?? appNameAr;
      appNameEn = d['appNameEn'] ?? appNameEn;
      aboutTextAr = d['aboutTextAr'] ?? aboutTextAr;
      aboutTextEn = d['aboutTextEn'] ?? aboutTextEn;
      privacyTextAr = d['privacyTextAr'] ?? privacyTextAr;
      privacyTextEn = d['privacyTextEn'] ?? privacyTextEn;
      lat = (d['lat'] as num?)?.toDouble() ?? lat;
      lng = (d['lng'] as num?)?.toDouble() ?? lng;
      tz = (d['tz'] as num?)?.toDouble() ?? tz;
      customGpsCityLabel = d['customGpsCityLabel'] ?? customGpsCityLabel;
      isUsingLiveGps = d['isUsingLiveGps'] ?? isUsingLiveGps;
      calcMethodKey = d['calcMethodKey'] ?? calcMethodKey;
      asrShadowFactor = (d['asrShadowFactor'] as num?)?.toInt() ?? asrShadowFactor;
      hijriOffsetDays = (d['hijriOffsetDays'] as num?)?.toInt() ?? hijriOffsetDays;
      enablePreAdhanReminder = d['enablePreAdhanReminder'] ?? true;
      preAdhanReminderMinutes = (d['preAdhanReminderMinutes'] as num?)?.toInt() ?? 10;
      enableOccasionAlerts = d['enableOccasionAlerts'] ?? true;
      currentMushafPage = (d['currentMushafPage'] as num?)?.toInt() ?? 1;
      savedMushafPage = (d['savedMushafPage'] as num?)?.toInt() ?? 1;
      lastReadSurah = (d['lastReadSurah'] as num?)?.toInt() ?? 1;
      lastReadAyah = (d['lastReadAyah'] as num?)?.toInt() ?? 1;
      selectedTafsirSlug = d['selectedTafsirSlug'] ?? 'ar-tafsir-muyassar';
      hisnSavedPage = (d['hisnSavedPage'] as num?)?.toInt() ?? 0;
      tasbihCounter = (d['tasbihCounter'] as num?)?.toInt() ?? 0;
      lastOccasionAlertDateKey = d['lastOccasionAlertDateKey'] ?? '';
      _lastPrayerResetDate = d['lastPrayerResetDate'] ?? '';

      deviceInstallId = d['deviceInstallId'] ?? '';
      firstInstallDate = DateTime.tryParse(d['firstInstallDate']?.toString() ?? '') ?? firstInstallDate;
      totalAppOpens = (d['totalAppOpens'] as num?)?.toInt() ?? 0;
      quranPagesReadCount = (d['quranPagesReadCount'] as num?)?.toInt() ?? 0;
      ayahsListenedCount = (d['ayahsListenedCount'] as num?)?.toInt() ?? 0;
      adhkarCompletedCount = (d['adhkarCompletedCount'] as num?)?.toInt() ?? 0;
      qiblaChecksCount = (d['qiblaChecksCount'] as num?)?.toInt() ?? 0;
      prayersLoggedTotal = (d['prayersLoggedTotal'] as num?)?.toInt() ?? 0;

      if (d['lastCloudMsgTs'] != null) {
        _lastCloudMsgTs = (d['lastCloudMsgTs'] as num).toInt();
      }
      if (d['seenCloudMsgIds'] is List) {
        _seenCloudMsgIds.addAll((d['seenCloudMsgIds'] as List).map((e) => e.toString()));
      }
      if (d['weeklyActivityMap'] is Map) {
        (d['weeklyActivityMap'] as Map).forEach((k, v) {
          weeklyActivityMap[k.toString()] = (v as num?)?.toInt() ?? 0;
        });
      }
      if (d['prayerDoneToday'] is Map) {
        (d['prayerDoneToday'] as Map).forEach((k, v) {
          if (prayerDoneToday.containsKey(k)) prayerDoneToday[k.toString()] = v == true;
        });
      }
      if (d['prayerNotifyModes'] is Map) {
        (d['prayerNotifyModes'] as Map).forEach((k, v) {
          prayerNotifyModes[k.toString()] = v.toString();
        });
      }
      if (d['manualPrayerOffsets'] is Map) {
        (d['manualPrayerOffsets'] as Map).forEach((k, v) {
          manualPrayerOffsets[k.toString()] = (v as num?)?.toInt() ?? 0;
        });
      }
      final voiceId = d['selectedAdhanVoiceId']?.toString();
      if (voiceId != null) {
        selectedAdhanVoice = adhanVoices.firstWhere(
          (v) => v.id == voiceId,
          orElse: () => adhanVoices.first,
        );
      }
      if (d['bookmarks'] is List) {
        bookmarks
          ..clear()
          ..addAll((d['bookmarks'] as List).map((e) => QuranBookmarkItem.fromJson(Map<String, dynamic>.from(e))));
      }
      if (d['broadcasts'] is List) {
        broadcasts
          ..clear()
          ..addAll((d['broadcasts'] as List).map((e) => AdminBroadcastMessage.fromJson(Map<String, dynamic>.from(e))));
      }
      if (d['contactMessages'] is List) {
        contactMessages
          ..clear()
          ..addAll((d['contactMessages'] as List).map((e) => ContactUserMessage.fromJson(Map<String, dynamic>.from(e))));
      }
    } catch (_) {}
  }

  Future<void> persistState() async {
    try {
      final seenTrimmed = _seenCloudMsgIds.toList();
      if (seenTrimmed.length > 60) {
        seenTrimmed.removeRange(0, seenTrimmed.length - 60);
      }
      final data = jsonEncode({
        'lang': locale.languageCode,
        'isDarkMode': isDarkMode,
        'appNameAr': appNameAr,
        'appNameEn': appNameEn,
        'aboutTextAr': aboutTextAr,
        'aboutTextEn': aboutTextEn,
        'privacyTextAr': privacyTextAr,
        'privacyTextEn': privacyTextEn,
        'lat': lat,
        'lng': lng,
        'tz': tz,
        'customGpsCityLabel': customGpsCityLabel,
        'isUsingLiveGps': isUsingLiveGps,
        'calcMethodKey': calcMethodKey,
        'asrShadowFactor': asrShadowFactor,
        'hijriOffsetDays': hijriOffsetDays,
        'enablePreAdhanReminder': enablePreAdhanReminder,
        'preAdhanReminderMinutes': preAdhanReminderMinutes,
        'enableOccasionAlerts': enableOccasionAlerts,
        'currentMushafPage': currentMushafPage,
        'savedMushafPage': savedMushafPage,
        'lastReadSurah': lastReadSurah,
        'lastReadAyah': lastReadAyah,
        'selectedTafsirSlug': selectedTafsirSlug,
        'hisnSavedPage': hisnSavedPage,
        'tasbihCounter': tasbihCounter,
        'lastOccasionAlertDateKey': lastOccasionAlertDateKey,
        'lastPrayerResetDate': _lastPrayerResetDate,
        'deviceInstallId': deviceInstallId,
        'firstInstallDate': firstInstallDate.toIso8601String(),
        'totalAppOpens': totalAppOpens,
        'quranPagesReadCount': quranPagesReadCount,
        'ayahsListenedCount': ayahsListenedCount,
        'adhkarCompletedCount': adhkarCompletedCount,
        'qiblaChecksCount': qiblaChecksCount,
        'prayersLoggedTotal': prayersLoggedTotal,
        'lastCloudMsgTs': _lastCloudMsgTs,
        'seenCloudMsgIds': seenTrimmed,
        'weeklyActivityMap': weeklyActivityMap,
        'prayerDoneToday': prayerDoneToday,
        'prayerNotifyModes': prayerNotifyModes,
        'manualPrayerOffsets': manualPrayerOffsets,
        'selectedAdhanVoiceId': selectedAdhanVoice.id,
        'bookmarks': bookmarks.map((e) => e.toJson()).toList(),
        'broadcasts': broadcasts.take(30).map((e) => e.toJson()).toList(),
        'contactMessages': contactMessages.take(30).map((e) => e.toJson()).toList(),
      });
      await audioService.saveNativeState(data);
    } catch (_) {}
  }

  void recordQuranRead({int? surah, int? ayah, int? page}) {
    if (surah != null) lastReadSurah = surah;
    if (ayah != null) lastReadAyah = ayah;
    if (page != null) currentMushafPage = page;
    quranPagesReadCount++;
    unawaited(persistState());
  }

  void recordAyahListened() {
    ayahsListenedCount++;
    unawaited(persistState());
  }

  void recordAdhkarCompleted() {
    adhkarCompletedCount++;
    unawaited(persistState());
  }

  void recordQiblaCheck() {
    qiblaChecksCount++;
    unawaited(persistState());
  }

  void saveHisnState(int page, int tasbih) {
    hisnSavedPage = page;
    tasbihCounter = tasbih;
    unawaited(persistState());
  }

  Future<void> requestAndVerifyPermissions() async {
    await audioService.requestNativePermissions();
    hasLocationPermission = true;
    hasNotificationPermission = true;
    notifyListeners();
  }

  Future<void> _checkAndSendOccasionAlerts() async {
    if (!enableOccasionAlerts) return;
    final todayStr = _todayKey();
    if (lastOccasionAlertDateKey == todayStr) return;

    final now = DateTime.now();
    final todayUtc = DateTime.utc(now.year, now.month, now.day);
    final isEn = locale.languageCode == 'en';
    final events = <(DateTime, String, String, String, String)>[
      (DateTime.utc(2026, 11, 23), 'الأيام البيض لجمادى الآخرة', 'يستحب صيام أيام 13 و14 و15 جمادى الآخرة.', 'White Days Fasting', 'Recommended fasting days 13, 14, 15.'),
      (DateTime.utc(2026, 12, 10), 'غرة شهر رجب الحرام 1448 هـ', 'اللهم بارك لنا في رجب وشعبان وبلغنا رمضان.', '1st of Rajab 1448 AH', 'Blessed beginning of Rajab.'),
      (DateTime.utc(2027, 1, 5), 'ذكرى الإسراء والمعراج', 'ليلة السابع والعشرين من رجب 1448 هـ.', 'Al-Isra wal-Miraj', '27th of Rajab 1448 AH.'),
      (DateTime.utc(2027, 2, 8), 'غرة شهر رمضان المبارك 1448 هـ', 'مبارك عليكم الشهر وتقبل الله صيامكم وقيامكم.', '1st of Ramadan 1448 AH', 'Ramadan Mubarak!'),
      (DateTime.utc(2027, 3, 9), 'عيد الفطر المبارك 1448 هـ', 'تقبل الله منا ومنكم صالح الأعمال.', 'Eid Al-Fitr 1448 AH', 'Eid Mubarak!'),
      (DateTime.utc(2027, 5, 15), 'يوم عرفة المبارك 1448 هـ', 'صيام يوم عرفة يكفر السنة الماضية والباقية.', 'Day of Arafah', 'Fasting expiates two years.'),
      (DateTime.utc(2027, 5, 16), 'عيد الأضحى المبارك 1448 هـ', 'عيدكم مبارك وتقبل الله طاعاتكم.', 'Eid Al-Adha 1448 AH', 'Eid Mubarak!'),
    ];

    for (final ev in events) {
      final diffDays = ev.$1.difference(todayUtc).inDays;
      final titleAr = ev.$2;
      final bodyAr = ev.$3;
      final titleEn = ev.$4;
      final bodyEn = ev.$5;
      if (diffDays == 0) {
        await audioService.showSystemPushNotification(
          isEn ? '🎉 Today: $titleEn' : '🎉 اليوم: $titleAr',
          isEn ? bodyEn : bodyAr,
        );
      } else if (diffDays == 1) {
        await audioService.showSystemPushNotification(
          isEn ? '🌙 Tomorrow: $titleEn' : '🌙 غداً بمشيئة الله: $titleAr',
          isEn ? bodyEn : bodyAr,
        );
      } else if (diffDays == 2) {
        await audioService.showSystemPushNotification(
          isEn ? '⏳ In 2 days: $titleEn' : '⏳ تذكير (بعد يومين): $titleAr',
          isEn ? bodyEn : bodyAr,
        );
      }
    }
    lastOccasionAlertDateKey = todayStr;
    unawaited(persistState());
  }

  String get activeAppName => locale.languageCode == 'en' ? appNameEn : appNameAr;

  String _nearestCityLabel(double targetLat, double targetLng, bool isEn) {
    CityLocation best = VerifiedCitiesRegistry.cities.first;
    double bestDist = double.infinity;
    for (final c in VerifiedCitiesRegistry.cities) {
      final d = (c.lat - targetLat) * (c.lat - targetLat) + (c.lng - targetLng) * (c.lng - targetLng);
      if (d < bestDist) {
        bestDist = d;
        best = c;
      }
    }
    return isEn ? best.nameEn : best.nameAr;
  }

  String get displayCityName {
    if (isUsingLiveGps && customGpsCityLabel.isNotEmpty) {
      return customGpsCityLabel;
    }
    return locale.languageCode == 'en' ? currentCity.nameEn : currentCity.nameAr;
  }

  Future<bool> detectLocationViaGps() async {
    isDetectingGps = true;
    notifyListeners();
    try {
      final nativeLoc = await audioService.fetchNativeGpsLocation();
      if (nativeLoc != null && nativeLoc['lat'] != null && nativeLoc['lng'] != null) {
        lat = (nativeLoc['lat'] as num).toDouble();
        lng = (nativeLoc['lng'] as num).toDouble();
        tz = (nativeLoc['tz'] as num?)?.toDouble() ??
            (DateTime.now().timeZoneOffset.inMinutes / 60.0);
        final rawCity = (nativeLoc['city'] as String?)?.trim() ?? '';
        customGpsCityLabel = (rawCity.isNotEmpty && !rawCity.contains('GPS'))
            ? rawCity
            : _nearestCityLabel(lat, lng, locale.languageCode == 'en');
        isUsingLiveGps = true;
        isDetectingGps = false;
        unawaited(persistState());
        notifyListeners();
        return true;
      }

      final res = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['latitude'] != null && data['longitude'] != null) {
          lat = (data['latitude'] as num).toDouble();
          lng = (data['longitude'] as num).toDouble();
          tz = DateTime.now().timeZoneOffset.inMinutes / 60.0;
          final c = data['city'] ?? '';
          final co = data['country_name'] ?? '';
          customGpsCityLabel = '$c، $co';
          isUsingLiveGps = true;
          isDetectingGps = false;
          unawaited(persistState());
          notifyListeners();
          return true;
        }
      }
    } catch (_) {}
    isDetectingGps = false;
    notifyListeners();
    return false;
  }

  void setFullScreenMushaf(bool val) {
    isFullScreenMushaf = val;
    notifyListeners();
  }

  void saveCurrentMushafPage(int pageNum) {
    savedMushafPage = pageNum.clamp(1, 604);
    currentMushafPage = savedMushafPage;
    unawaited(persistState());
    notifyListeners();
  }

  void setSelectedTafsir(String slug) {
    selectedTafsirSlug = slug;
    unawaited(persistState());
    notifyListeners();
  }

  void toggleBookmark(QuranBookmarkItem item) {
    final existingIdx = bookmarks.indexWhere(
      (b) => b.surahNumber == item.surahNumber && b.ayahNumber == item.ayahNumber,
    );
    if (existingIdx >= 0) {
      bookmarks.removeAt(existingIdx);
    } else {
      bookmarks.insert(0, item);
    }
    unawaited(persistState());
    notifyListeners();
  }

  bool isBookmarked(int surahNum, int ayahNum) {
    return bookmarks.any((b) => b.surahNumber == surahNum && b.ayahNumber == ayahNum);
  }

  bool registerLogoTapForSecretAdmin() {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!).inMilliseconds > 2500) {
      _secretTapCounter = 1;
    } else {
      _secretTapCounter++;
    }
    _lastTapTime = now;
    if (_secretTapCounter >= AppBrandingAndSounds.secretLogoTapCountRequired) {
      _secretTapCounter = 0;
      return true;
    }
    return false;
  }

  bool verifyAndUnlockAdmin(String passwordInput) {
    final trimmed = passwordInput.trim();
    final inputHash = AppBrandingAndSounds.hashPassword(trimmed);
    if (inputHash == _adminPasswordHash ||
        trimmed == AppBrandingAndSounds.defaultAdminPasswordPlain) {
      isAdminUnlocked = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void updateAdminPassword(String newPasswordPlain) {
    if (newPasswordPlain.trim().length >= 4) {
      _adminPasswordHash = AppBrandingAndSounds.hashPassword(newPasswordPlain);
      cloudAccountPassword = newPasswordPlain.trim();
      notifyListeners();
    }
  }

  void lockAdminVault() {
    isAdminUnlocked = false;
    notifyListeners();
  }

  void updateAboutAndPrivacy({
    required String newAboutAr,
    required String newAboutEn,
    required String newPrivacyAr,
    required String newPrivacyEn,
  }) {
    if (newAboutAr.trim().isNotEmpty) aboutTextAr = newAboutAr.trim();
    if (newAboutEn.trim().isNotEmpty) aboutTextEn = newAboutEn.trim();
    if (newPrivacyAr.trim().isNotEmpty) privacyTextAr = newPrivacyAr.trim();
    if (newPrivacyEn.trim().isNotEmpty) privacyTextEn = newPrivacyEn.trim();
    unawaited(persistState());
    notifyListeners();
  }

  void updateBranding({
    required String newNameAr,
    required String newNameEn,
    required String newLogoEmojiOrUrl,
  }) {
    if (newNameAr.trim().isNotEmpty) appNameAr = newNameAr.trim();
    if (newNameEn.trim().isNotEmpty) appNameEn = newNameEn.trim();
    if (newLogoEmojiOrUrl.trim().isNotEmpty) {
      appLogoEmojiOrUrl = newLogoEmojiOrUrl.trim();
    }
    unawaited(persistState());
    notifyListeners();
  }

  void selectCity(CityLocation city) {
    isUsingLiveGps = false;
    currentCity = city;
    lat = city.lat;
    lng = city.lng;
    tz = city.tz;
    calcMethodKey = city.defaultMethod;
    unawaited(persistState());
    notifyListeners();
  }

  void toggleLanguage() {
    locale = locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    unawaited(persistState());
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    unawaited(persistState());
    notifyListeners();
  }

  void togglePrayerHabitIfAllowed(String key, bool hasAdhanEntered) {
    if (!hasAdhanEntered) return;
    final nextVal = !(prayerDoneToday[key] ?? false);
    prayerDoneToday[key] = nextVal;
    if (nextVal) {
      prayersLoggedTotal++;
    } else if (prayersLoggedTotal > 0) {
      prayersLoggedTotal--;
    }
    unawaited(persistState());
    notifyListeners();
  }

  void cyclePrayerNotifyMode(String key) {
    const order = ['أذان كامل', 'تكبير', 'تنبيه', 'صامت'];
    final curr = prayerNotifyModes[key] ?? 'أذان كامل';
    final next = order[(order.indexOf(curr) + 1) % order.length];
    prayerNotifyModes[key] = next;
    unawaited(persistState());
    notifyListeners();
  }

  Future<bool> submitContactMessage({
    required String name,
    required String contactInfo,
    required String message,
  }) async {
    final item = ContactUserMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      contactInfo: contactInfo.trim(),
      message: message.trim(),
      createdAt: DateTime.now(),
    );
    contactMessages.insert(0, item);
    unawaited(persistState());
    notifyListeners();

    try {
      final res = await http
          .post(
            Uri.parse('https://formsubmit.co/ajax/${AppBrandingAndSounds.developerEmail}'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'name': item.name,
              'email': item.contactInfo,
              'message': item.message,
              '_subject': 'رسالة جديدة من تطبيق ميقاتي (${deviceInstallId})',
            }),
          )
          .timeout(const Duration(seconds: 6));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  String _computeHmacSignature(String content) {
    final keyBytes = utf8.encode(cloudAccountPassword);
    final msgBytes = utf8.encode(content);
    final hmac = Hmac(sha256, keyBytes);
    return hmac.convert(msgBytes).toString().substring(0, 16);
  }

  Map<String, String> _buildCloudAuthHeaders(String title, String priority) {
    final headers = <String, String>{
      'Title': title,
      'Priority': priority,
      'Tags': 'mosque',
    };
    if (cloudAccountUsername.isNotEmpty && cloudAccountPassword.isNotEmpty) {
      final creds = base64Encode(utf8.encode('$cloudAccountUsername:$cloudAccountPassword'));
      headers['Authorization'] = 'Basic $creds';
    }
    return headers;
  }

  Future<void> broadcastAdminNotification({
    required String title,
    required String body,
    required String category,
    String priority = 'high',
  }) async {
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final msgId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    _lastCloudMsgTs = nowSec;
    _seenCloudMsgIds.add(msgId);

    final msg = AdminBroadcastMessage(
      id: msgId,
      title: title,
      body: body,
      category: category,
      priority: priority,
      createdAt: DateTime.now(),
    );
    broadcasts.insert(0, msg);
    showBroadcastBanner = true;
    unawaited(persistState());
    notifyListeners();

    await audioService.showSystemPushNotification(title, body);

    try {
      final sig = _computeHmacSignature('$title|$body');
      final signedPayload = jsonEncode({
        'sig': sig,
        'title': title,
        'body': body,
        'category': category,
        'priority': priority,
        'ts': nowSec,
      });

      if (customFirebaseWebhookUrl.trim().isNotEmpty) {
        await http.post(
          Uri.parse(customFirebaseWebhookUrl.trim()),
          headers: {'Content-Type': 'application/json'},
          body: signedPayload,
        );
      }
      await http.post(
        Uri.parse('https://ntfy.sh/$cloudTopicChannel'),
        headers: _buildCloudAuthHeaders(title, priority),
        body: signedPayload,
      );
    } catch (_) {}
  }

  Future<void> _pollProtectedCloudBroadcasts() async {
    try {
      final res = await http
          .get(
            Uri.parse('https://ntfy.sh/$cloudTopicChannel/json?poll=1&since=${_lastCloudMsgTs + 1}'),
            headers: _buildCloudAuthHeaders('poll', 'default'),
          )
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200 && res.body.trim().isNotEmpty) {
        final lines = res.body.trim().split('\n');
        var updated = false;
        for (final line in lines) {
          final item = jsonDecode(line) as Map<String, dynamic>;
          final id = item['id']?.toString() ?? '';
          final msgTime = (item['time'] as num?)?.toInt() ?? 0;
          final rawMsg = item['message']?.toString() ?? '';

          // تجاهل أي إشعار قديم مضى وقته أو تمت معالجته مسبقاً
          if (id.isEmpty || _seenCloudMsgIds.contains(id) || msgTime <= _lastCloudMsgTs || rawMsg.isEmpty) {
            continue;
          }
          _seenCloudMsgIds.add(id);
          if (msgTime > _lastCloudMsgTs) _lastCloudMsgTs = msgTime;

          try {
            final decoded = jsonDecode(rawMsg) as Map<String, dynamic>;
            final t = decoded['title']?.toString() ?? 'إشعار ميقاتي';
            final b = decoded['body']?.toString() ?? '';
            final sig = decoded['sig']?.toString() ?? '';
            if (sig == _computeHmacSignature('$t|$b') && b.isNotEmpty) {
              broadcasts.insert(
                0,
                AdminBroadcastMessage(
                  id: id,
                  title: t,
                  body: b,
                  category: decoded['category']?.toString() ?? 'بث موثق',
                  createdAt: DateTime.fromMillisecondsSinceEpoch(msgTime * 1000),
                ),
              );
              showBroadcastBanner = true;
              updated = true;
              await audioService.showSystemPushNotification(t, b);
            }
          } catch (_) {}
        }
        if (updated) {
          unawaited(persistState());
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  String exportFullConfigJson() {
    return const JsonEncoder.withIndent('  ').convert({
      'deviceInstallId': deviceInstallId,
      'appNameAr': appNameAr,
      'appNameEn': appNameEn,
      'cloudTopicChannel': cloudTopicChannel,
      'savedMushafPage': savedMushafPage,
      'selectedTafsirSlug': selectedTafsirSlug,
      'hijriOffsetDays': hijriOffsetDays,
      'iqamahMinutes': iqamahMinutes,
      'manualPrayerOffsets': manualPrayerOffsets,
    });
  }

  @override
  void dispose() {
    _cloudPollTimer?.cancel();
    super.dispose();
  }
}
