import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_branding_and_sounds.dart';
import '../../core/audio/adhan_audio_service.dart';

class QuranVerseItem {
  final int surahNumber;
  final String surahNameAr;
  final int ayahNumber;
  final int globalAyahNumber;
  final int pageNumber;
  final String uthmani;
  final String translationEn;
  final String tafsirAr;

  const QuranVerseItem({
    required this.surahNumber,
    this.surahNameAr = '',
    required this.ayahNumber,
    this.globalAyahNumber = 1,
    this.pageNumber = 1,
    required this.uthmani,
    required this.translationEn,
    required this.tafsirAr,
  });
}

class QuranReciterOption {
  final String id;
  final String nameAr;
  final String everyAyahFolder;
  final String alquranEdition;
  final String mp3QuranServerBase;

  const QuranReciterOption({
    required this.id,
    required this.nameAr,
    required this.everyAyahFolder,
    required this.alquranEdition,
    required this.mp3QuranServerBase,
  });

  String ayahAudioUrl(int surah, int ayah, {int globalAyah = 0}) {
    if (globalAyah > 0) {
      return 'https://cdn.islamic.network/quran/audio/128/$alquranEdition/$globalAyah.mp3';
    }
    final s3 = surah.toString().padLeft(3, '0');
    final a3 = ayah.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/$everyAyahFolder/$s3$a3.mp3';
  }

  String ayahFallbackUrl(int surah, int ayah) {
    final s3 = surah.toString().padLeft(3, '0');
    final a3 = ayah.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/$everyAyahFolder/$s3$a3.mp3';
  }

  String surahAudioUrl(int surah) {
    final s3 = surah.toString().padLeft(3, '0');
    return '$mp3QuranServerBase/$s3.mp3';
  }
}

class QuranOpenSourceService {
  static final Map<String, List<QuranVerseItem>> _surahCache = {};
  static final Map<int, (String, int, List<QuranVerseItem>)> _pageCache = {};
  static bool isFullQuranOfflineReady = false;
  static final Map<int, String> _enSahihMap = <int, String>{};

  static const List<QuranReciterOption> reciters = [
    QuranReciterOption(
      id: 'alafasy',
      nameAr: 'مشاري راشد العفاسي',
      everyAyahFolder: 'Alafasy_128kbps',
      alquranEdition: 'ar.alafasy',
      mp3QuranServerBase: 'https://server8.mp3quran.net/afs',
    ),
    QuranReciterOption(
      id: 'husary',
      nameAr: 'محمود خليل الحصري',
      everyAyahFolder: 'Husary_128kbps',
      alquranEdition: 'ar.husary',
      mp3QuranServerBase: 'https://server13.mp3quran.net/husr',
    ),
    QuranReciterOption(
      id: 'abdulbasit',
      nameAr: 'عبد الباسط عبد الصمد',
      everyAyahFolder: 'Abdul_Basit_Murattal_192kbps',
      alquranEdition: 'ar.abdulbasitmurattal',
      mp3QuranServerBase: 'https://server7.mp3quran.net/basit',
    ),
    QuranReciterOption(
      id: 'minshawi',
      nameAr: 'محمد صديق المنشاوي',
      everyAyahFolder: 'Minshawy_Murattal_128kbps',
      alquranEdition: 'ar.minshawi',
      mp3QuranServerBase: 'https://server10.mp3quran.net/minsh',
    ),
  ];

  static const List<String> all114SurahNamesAr = [
    'الفاتحة', 'البقرة', 'آل عمران', 'النساء', 'المائدة', 'الأنعام', 'الأعراف', 'الأنفال', 'التوبة', 'يونس',
    'هود', 'يوسف', 'الرعد', 'إبراهيم', 'الحجر', 'النحل', 'الإسراء', 'الكهف', 'مريم', 'طه',
    'الأنبياء', 'الحج', 'المؤمنون', 'النور', 'الفرقان', 'الشعراء', 'النمل', 'القصص', 'العنكبوت', 'الروم',
    'لقمان', 'السجدة', 'الأحزاب', 'سبأ', 'فاطر', 'يس', 'الصافات', 'ص', 'الزمر', 'غافر',
    'فصلت', 'الشورى', 'الزخرف', 'الدخان', 'الجاثية', 'الأحقاف', 'محمد', 'الفتح', 'الحجرات', 'ق',
    'الذاريات', 'الطور', 'النجم', 'القمر', 'الرحمن', 'الواقعة', 'الحديد', 'المجادلة', 'الحشر', 'الممتحنة',
    'الصف', 'الجمعة', 'المنافقون', 'التغابن', 'الطلاق', 'التحريم', 'الملك', 'القلم', 'الحاقة', 'المعارج',
    'نوح', 'الجن', 'المزمل', 'المدثر', 'القيامة', 'الإنسان', 'المرسلات', 'النبأ', 'النازعات', 'عبس',
    'التكوير', 'الانفطار', 'المطففين', 'الانشقاق', 'البروج', 'الطارق', 'الأعلى', 'الغاشية', 'الفجر', 'البلد',
    'الشمس', 'الليل', 'الضحى', 'الشرح', 'التين', 'العلق', 'القدر', 'البينة', 'الزلزلة', 'العاديات',
    'القارعة', 'التكاثر', 'العصر', 'الهمزة', 'الفيل', 'قريش', 'الماعون', 'الكوثر', 'الكافرون', 'النصر',
    'المسد', 'الإخلاص', 'الفلق', 'الناس',
  ];

  static const List<String> all114SurahNamesEn = [
    'Al-Fatihah', 'Al-Baqarah', 'Aal-E-Imran', 'An-Nisa', 'Al-Maidah', 'Al-Anam', 'Al-Araf', 'Al-Anfal', 'At-Tawbah', 'Yunus',
    'Hud', 'Yusuf', 'Ar-Rad', 'Ibrahim', 'Al-Hijr', 'An-Nahl', 'Al-Isra', 'Al-Kahf', 'Maryam', 'Ta-Ha',
    'Al-Anbiya', 'Al-Hajj', 'Al-Muminun', 'An-Nur', 'Al-Furqan', 'Ash-Shuara', 'An-Naml', 'Al-Qasas', 'Al-Ankabut', 'Ar-Rum',
    'Luqman', 'As-Sajdah', 'Al-Ahzab', 'Saba', 'Fatir', 'Ya-Sin', 'As-Saffat', 'Sad', 'Az-Zumar', 'Ghafir',
    'Fussilat', 'Ash-Shura', 'Az-Zukhruf', 'Ad-Dukhan', 'Al-Jathiyah', 'Al-Ahqaf', 'Muhammad', 'Al-Fath', 'Al-Hujurat', 'Qaf',
    'Adh-Dhariyat', 'At-Tur', 'An-Najm', 'Al-Qamar', 'Ar-Rahman', 'Al-Waqiah', 'Al-Hadid', 'Al-Mujadila', 'Al-Hashr', 'Al-Mumtahanah',
    'As-Saff', 'Al-Jumuah', 'Al-Munafiqun', 'At-Taghabun', 'At-Talaq', 'At-Tahrim', 'Al-Mulk', 'Al-Qalam', 'Al-Haqqah', 'Al-Maarij',
    'Nuh', 'Al-Jinn', 'Al-Muzzammil', 'Al-Muddaththir', 'Al-Qiyamah', 'Al-Insan', 'Al-Mursalat', 'An-Naba', 'An-Naziat', 'Abasa',
    'At-Takwir', 'Al-Infitar', 'Al-Mutaffifin', 'Al-Inshiqaq', 'Al-Buruj', 'At-Tariq', 'Al-Ala', 'Al-Ghashiyah', 'Al-Fajr', 'Al-Balad',
    'Ash-Shams', 'Al-Layl', 'Ad-Duhaa', 'Ash-Sharh', 'At-Tin', 'Al-Alaq', 'Al-Qadr', 'Al-Bayyinah', 'Az-Zalzalah', 'Al-Adiyat',
    'Al-Qariah', 'At-Takathur', 'Al-Asr', 'Al-Humazah', 'Al-Fil', 'Quraysh', 'Al-Maun', 'Al-Kawthar', 'Al-Kafirun', 'An-Nasr',
    'Al-Masad', 'Al-Ikhlas', 'Al-Falaq', 'An-Nas',
  ];

  static String normalizeArabic(String input) {
    return input
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .trim();
  }

  static List<int> searchMatchingSurahs(String query) {
    final q = normalizeArabic(query).toLowerCase();
    if (q.isEmpty) return List.generate(114, (i) => i + 1);
    final res = <int>[];
    for (var i = 0; i < 114; i++) {
      final ar = normalizeArabic(all114SurahNamesAr[i]);
      final en = all114SurahNamesEn[i].toLowerCase();
      if (ar.contains(q) || en.contains(q) || '${i + 1}' == q) {
        res.add(i + 1);
      }
    }
    return res;
  }

  static final Map<int, List<QuranVerseItem>> offlineCache = {
    1: const [
      QuranVerseItem(surahNumber: 1, surahNameAr: 'سورة الفاتحة', ayahNumber: 1, globalAyahNumber: 1, pageNumber: 1, uthmani: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', translationEn: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.', tafsirAr: 'أبتدئ قراءة القرآن باسم الله مستعيناً به، والرحمن ذو الرحمة العامة، والرحيم ذو الرحمة الخاصة بالمؤمنين.'),
      QuranVerseItem(surahNumber: 1, surahNameAr: 'سورة الفاتحة', ayahNumber: 2, globalAyahNumber: 2, pageNumber: 1, uthmani: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', translationEn: '[All] praise is [due] to Allah, Lord of the worlds -', tafsirAr: 'الثناء الكامل لله وحده، مالك كل المخلوقات ومدبر شؤونهم.'),
      QuranVerseItem(surahNumber: 1, surahNameAr: 'سورة الفاتحة', ayahNumber: 3, globalAyahNumber: 3, pageNumber: 1, uthmani: 'الرَّحْمَٰنِ الرَّحِيمِ', translationEn: 'The Entirely Merciful, the Especially Merciful,', tafsirAr: 'الرحمن بجميع خلقه، الرحيم بالمؤمنين في الدنيا والآخرة.'),
      QuranVerseItem(surahNumber: 1, surahNameAr: 'سورة الفاتحة', ayahNumber: 4, globalAyahNumber: 4, pageNumber: 1, uthmani: 'مَالِكِ يَوْمِ الدِّينِ', translationEn: 'Sovereign of the Day of Recompense.', tafsirAr: 'هو وحده المتصرف في يوم الحساب والجزاء.'),
      QuranVerseItem(surahNumber: 1, surahNameAr: 'سورة الفاتحة', ayahNumber: 5, globalAyahNumber: 5, pageNumber: 1, uthmani: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ', translationEn: 'It is You we worship and You we ask for help.', tafsirAr: 'نخصك وحدك بالعبادة ونستعين بك وحدك في جميع أمورنا.'),
      QuranVerseItem(surahNumber: 1, surahNameAr: 'سورة الفاتحة', ayahNumber: 6, globalAyahNumber: 6, pageNumber: 1, uthmani: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ', translationEn: 'Guide us to the straight path -', tafsirAr: 'دلّنا وأرشدنا وثبتنا على الطريق الواضح الموصل لمرضاتك.'),
      QuranVerseItem(surahNumber: 1, surahNameAr: 'سورة الفاتحة', ayahNumber: 7, globalAyahNumber: 7, pageNumber: 1, uthmani: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ', translationEn: 'The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.', tafsirAr: 'طريق الذين أنعمت عليهم من النبيين والصديقين والشهداء والصالحين.'),
    ],
  };

  void _indexFullQuranJson(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      final surahs = (decoded['data']['surahs'] as List<dynamic>?) ?? [];
      final pageMap = <int, List<QuranVerseItem>>{};
      for (final s in surahs) {
        final sNum = (s['number'] as num).toInt();
        final sName = s['name']?.toString() ?? 'سورة ${all114SurahNamesAr[sNum - 1]}';
        final ayahs = (s['ayahs'] as List<dynamic>?) ?? [];
        final sItems = <QuranVerseItem>[];
        for (final a in ayahs) {
          final pNum = (a['page'] as num?)?.toInt() ?? 1;
          final item = QuranVerseItem(
            surahNumber: sNum,
            surahNameAr: sName,
            ayahNumber: (a['numberInSurah'] as num).toInt(),
            globalAyahNumber: (a['number'] as num?)?.toInt() ?? 1,
            pageNumber: pNum,
            uthmani: a['text']?.toString() ?? '',
            translationEn: _enSahihMap[(a['number'] as num?)?.toInt() ?? 0] ?? '',
            tafsirAr: 'اضغط لاختيار التفسير أو تشغيل التلاوة.',
          );
          sItems.add(item);
          pageMap.putIfAbsent(pNum, () => []).add(item);
        }
        _surahCache['${sNum}_offline'] = sItems;
      }
      pageMap.forEach((p, list) {
        if (list.isNotEmpty) {
          _pageCache[p] = (list.first.surahNameAr, list.first.surahNumber, list);
        }
      });
      if (_pageCache.length >= 600) {
        isFullQuranOfflineReady = true;
      }
    } catch (_) {}
  }

  Future<bool> ensureFullQuranOfflineCached(AdhanAudioService disk) async {
    if (isFullQuranOfflineReady) return true;
    final existing = await disk.loadDiskJson('full_quran_uthmani_v8');
    if (existing != null && existing.length > 50000) {
      _indexFullQuranJson(existing);
      if (isFullQuranOfflineReady) return true;
    }
    try {
      final res = await http
          .get(Uri.parse('${AppBrandingAndSounds.openQuranApiBase}/quran/quran-uthmani'))
          .timeout(const Duration(seconds: 25));
      if (res.statusCode == 200 && res.body.length > 50000) {
        await disk.saveDiskJson('full_quran_uthmani_v8', res.body);
        _indexFullQuranJson(res.body);
        return isFullQuranOfflineReady;
      }
    } catch (_) {}
    return false;
  }

  Future<void> ensureEnglishSahihCached(AdhanAudioService? disk) async {
    if (_enSahihMap.length >= 6000) return;
    if (disk != null) {
      final cachedEn = await disk.loadDiskJson('full_quran_en_sahih_v8');
      if (cachedEn != null && cachedEn.length > 50000) {
        _indexEnglishJson(cachedEn);
        if (_enSahihMap.length >= 6000) return;
      }
    }
    try {
      final res = await http
          .get(Uri.parse('${AppBrandingAndSounds.openQuranApiBase}/quran/en.sahih'))
          .timeout(const Duration(seconds: 25));
      if (res.statusCode == 200 && res.body.length > 50000) {
        if (disk != null) await disk.saveDiskJson('full_quran_en_sahih_v8', res.body);
        _indexEnglishJson(res.body);
      }
    } catch (_) {}
  }

  void _indexEnglishJson(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      final surahs = (decoded['data']['surahs'] as List<dynamic>?) ?? [];
      for (final s in surahs) {
        final ayahs = (s['ayahs'] as List<dynamic>?) ?? [];
        for (final a in ayahs) {
          final gNum = (a['number'] as num?)?.toInt() ?? 0;
          final txt = a['text']?.toString() ?? '';
          if (gNum > 0 && txt.isNotEmpty) _enSahihMap[gNum] = txt;
        }
      }
      // Backfill already-indexed surahs & pages
      _surahCache.updateAll((key, list) => list
          .map((v) => QuranVerseItem(
                surahNumber: v.surahNumber,
                surahNameAr: v.surahNameAr,
                ayahNumber: v.ayahNumber,
                globalAyahNumber: v.globalAyahNumber,
                pageNumber: v.pageNumber,
                uthmani: v.uthmani,
                translationEn: v.translationEn.isNotEmpty ? v.translationEn : (_enSahihMap[v.globalAyahNumber] ?? ''),
                tafsirAr: v.tafsirAr,
              ))
          .toList());
      _pageCache.updateAll((p, tuple) => (
            tuple.$1,
            tuple.$2,
            tuple.$3
                .map((v) => QuranVerseItem(
                      surahNumber: v.surahNumber,
                      surahNameAr: v.surahNameAr,
                      ayahNumber: v.ayahNumber,
                      globalAyahNumber: v.globalAyahNumber,
                      pageNumber: v.pageNumber,
                      uthmani: v.uthmani,
                      translationEn: v.translationEn.isNotEmpty ? v.translationEn : (_enSahihMap[v.globalAyahNumber] ?? ''),
                      tafsirAr: v.tafsirAr,
                    ))
                .toList(),
          ));
    } catch (_) {}
  }

  (String, int, List<QuranVerseItem>)? getCachedMushafPage(int pageNumber) => _pageCache[pageNumber];

  Future<Map<int, String>> _fetchSunniTafsirMap(int surahNumber, String tafsirSlug, AdhanAudioService? disk) async {
    final cacheKey = 'tafsir_${tafsirSlug}_$surahNumber';
    if (disk != null) {
      final local = await disk.loadDiskJson(cacheKey);
      if (local != null && local.isNotEmpty) {
        try {
          final parsed = jsonDecode(local) as Map<String, dynamic>;
          return parsed.map((k, v) => MapEntry(int.parse(k), v.toString()));
        } catch (_) {}
      }
    }
    final map = <int, String>{};
    try {
      final url = Uri.parse('https://cdn.jsdelivr.net/gh/spa5k/tafsir_api@main/tafsir/$tafsirSlug/$surahNumber.json');
      final res = await http.get(url).timeout(const Duration(seconds: 7));
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        final ayahs = (j['ayahs'] as List?) ?? [];
        for (final a in ayahs) {
          final ayahNum = (a['ayah'] as num?)?.toInt() ?? 0;
          final txt = a['text']?.toString().trim() ?? '';
          if (ayahNum > 0 && txt.isNotEmpty) map[ayahNum] = txt;
        }
        if (disk != null && map.isNotEmpty) {
          await disk.saveDiskJson(cacheKey, jsonEncode(map.map((k, v) => MapEntry('$k', v))));
        }
      }
    } catch (_) {}
    return map;
  }

  Future<List<QuranVerseItem>> getSurahVerses(
    int surahNumber, {
    String tafsirSlug = 'ar-tafsir-muyassar',
    AdhanAudioService? disk,
  }) async {
    final cacheKey = '${surahNumber}_$tafsirSlug';
    if (_surahCache.containsKey(cacheKey)) {
      return _surahCache[cacheKey]!;
    }
    // إذا كان المصحف الكامل مخزناً محلياً، اقرأه فوراً بدون انتظار الإنترنت
    await ensureEnglishSahihCached(disk);
    final offlineFull = _surahCache['${surahNumber}_offline'];
    if (offlineFull != null && offlineFull.isNotEmpty) {
      final sunniMap = await _fetchSunniTafsirMap(surahNumber, tafsirSlug, disk);
      if (sunniMap.isNotEmpty) {
        final enriched = offlineFull
            .map((v) => QuranVerseItem(
                  surahNumber: v.surahNumber,
                  surahNameAr: v.surahNameAr,
                  ayahNumber: v.ayahNumber,
                  globalAyahNumber: v.globalAyahNumber,
                  pageNumber: v.pageNumber,
                  uthmani: v.uthmani,
                  translationEn: v.translationEn.isNotEmpty ? v.translationEn : (_enSahihMap[v.globalAyahNumber] ?? ''),
                  tafsirAr: sunniMap[v.ayahNumber] ?? v.tafsirAr,
                ))
            .toList();
        _surahCache[cacheKey] = enriched;
        return enriched;
      }
      return offlineFull;
    }

    try {
      final url = Uri.parse('${AppBrandingAndSounds.openQuranApiBase}/surah/$surahNumber/editions/quran-uthmani,en.sahih,ar.muyassar');
      final resFuture = http.get(url).timeout(const Duration(seconds: 10));
      final tafsirFuture = tafsirSlug == 'ar-tafsir-muyassar'
          ? Future.value(<int, String>{})
          : _fetchSunniTafsirMap(surahNumber, tafsirSlug, disk);

      final res = await resFuture;
      final sunniMap = await tafsirFuture;

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final editions = decoded['data'] as List<dynamic>;
        final arAyahs = editions[0]['ayahs'] as List<dynamic>;
        final enAyahs = editions[1]['ayahs'] as List<dynamic>;
        final tfAyahs = editions[2]['ayahs'] as List<dynamic>;
        final sName = 'سورة ${all114SurahNamesAr[surahNumber - 1]}';

        final items = <QuranVerseItem>[];
        for (var i = 0; i < arAyahs.length; i++) {
          final aNum = (arAyahs[i]['numberInSurah'] as num).toInt();
          final fallbackTf = tfAyahs[i]['text'].toString();
          items.add(
            QuranVerseItem(
              surahNumber: surahNumber,
              surahNameAr: sName,
              ayahNumber: aNum,
              globalAyahNumber: (arAyahs[i]['number'] as num?)?.toInt() ?? 1,
              pageNumber: (arAyahs[i]['page'] as num?)?.toInt() ?? 1,
              uthmani: arAyahs[i]['text'].toString(),
              translationEn: enAyahs[i]['text'].toString(),
              tafsirAr: sunniMap[aNum] ?? fallbackTf,
            ),
          );
        }
        _surahCache[cacheKey] = items;
        return items;
      }
    } catch (_) {}
    return offlineCache[surahNumber] ?? offlineCache[1]!;
  }

  Future<(String, int, List<QuranVerseItem>)> getMushafPage(
    int pageNumber, {
    String tafsirSlug = 'ar-tafsir-muyassar',
    AdhanAudioService? disk,
  }) async {
    final targetPage = pageNumber.clamp(1, 604);
    if (_pageCache.containsKey(targetPage)) {
      return _pageCache[targetPage]!;
    }
    try {
      final url = Uri.parse('${AppBrandingAndSounds.openQuranApiBase}/page/$targetPage/quran-uthmani');
      final res = await http.get(url).timeout(const Duration(seconds: 9));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final ayahs = (decoded['data']['ayahs'] as List<dynamic>?) ?? [];
        if (ayahs.isNotEmpty) {
          final firstSurahNum = (ayahs.first['surah']['number'] as num?)?.toInt() ?? 1;
          final sunniMap = await _fetchSunniTafsirMap(firstSurahNum, tafsirSlug, disk);
          final items = ayahs.map((a) {
            final sNum = (a['surah']['number'] as num?)?.toInt() ?? 1;
            final aNum = (a['numberInSurah'] as num?)?.toInt() ?? 1;
            final sName = a['surah']['name']?.toString() ?? 'سورة ${all114SurahNamesAr[sNum - 1]}';
            return QuranVerseItem(
              surahNumber: sNum,
              surahNameAr: sName,
              ayahNumber: aNum,
              globalAyahNumber: (a['number'] as num?)?.toInt() ?? 1,
              pageNumber: targetPage,
              uthmani: a['text']?.toString() ?? '',
              translationEn: '',
              tafsirAr: sunniMap[aNum] ?? 'اضغط على الآية لعرض التفسير المختار والاستماع إليها.',
            );
          }).toList();
          final header = items.first.surahNameAr;
          final tuple = (header, firstSurahNum, items);
          _pageCache[targetPage] = tuple;
          return tuple;
        }
      }
    } catch (_) {}
    return ('سورة الفاتحة', 1, offlineCache[1]!);
  }
}
