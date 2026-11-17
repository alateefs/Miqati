import 'dart:convert';
import 'package:crypto/crypto.dart';

class AdhanVoiceOption {
  final String id;
  final String nameAr;
  final String nameEn;
  final String pathOrUrl;

  const AdhanVoiceOption({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.pathOrUrl,
  });

  String label(bool isAr) => isAr ? nameAr : nameEn;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'pathOrUrl': pathOrUrl,
      };
}

class SunniTafsirOption {
  final String slug;
  final String nameAr;
  final String nameEn;
  final String authorAr;

  const SunniTafsirOption({
    required this.slug,
    required this.nameAr,
    required this.nameEn,
    required this.authorAr,
  });
}

class AppBrandingAndSounds {
  static String defaultAppNameAr = 'ميقاتي';
  static String defaultAppNameEn = 'Miqati';
  static String defaultLogoTextOrEmoji = '🕌';
  static String defaultLogoAsset = 'assets/logo/app_logo.png';
  static String developerEmail = 'a@latifs.site';

  static const int secretLogoTapCountRequired = 5;
  static const String secretSearchTriggerCode = '#777#';
  static const String defaultAdminPasswordPlain = 'sanosseas11';

  static String hashPassword(String input) {
    return sha256.convert(utf8.encode(input.trim())).toString();
  }

  // أسماء ودّية نظيفة بدون إظهار مسارات الملفات أو الصيغ للمستخدم
  static final List<AdhanVoiceOption> defaultAdhanVoices = <AdhanVoiceOption>[
    const AdhanVoiceOption(
      id: 'adhan_main',
      nameAr: 'الأذان الرئيسي الكلاسيكي',
      nameEn: 'Classic Main Adhan',
      pathOrUrl: 'assets/audio/adhan_main.mp3',
    ),
    const AdhanVoiceOption(
      id: 'adhan_makkah',
      nameAr: 'أذان الحرم المكي الشريف',
      nameEn: 'Makkah Grand Mosque Adhan',
      pathOrUrl: 'assets/audio/adhan_makkah.mp3',
    ),
    const AdhanVoiceOption(
      id: 'adhan_madinah',
      nameAr: 'أذان المسجد النبوي الشريف',
      nameEn: 'Madinah Prophet Mosque Adhan',
      pathOrUrl: 'assets/audio/adhan_madinah.mp3',
    ),
    const AdhanVoiceOption(
      id: 'adhan_fajr',
      nameAr: 'أذان الفجر الهادئ',
      nameEn: 'Fajr Peaceful Adhan',
      pathOrUrl: 'assets/audio/adhan_fajr.mp3',
    ),
    const AdhanVoiceOption(
      id: 'takbir',
      nameAr: 'تكبيرات الإحرام والعيد',
      nameEn: 'Eid & Prayer Takbirat',
      pathOrUrl: 'assets/audio/takbir.mp3',
    ),
  ];

  // تفاسير أهل السنة والجماعة المعتمدة
  static const List<SunniTafsirOption> sunniTafsirs = [
    SunniTafsirOption(
      slug: 'ar-tafsir-muyassar',
      nameAr: 'التفسير الميسر',
      nameEn: 'Al-Tafsir Al-Muyassar',
      authorAr: 'مجمع الملك فهد لطباعة المصحف الشريف',
    ),
    SunniTafsirOption(
      slug: 'ar-tafsir-ibn-kathir',
      nameAr: 'تفسير ابن كثير',
      nameEn: 'Tafsir Ibn Kathir',
      authorAr: 'الحافظ عماد الدين بن كثير',
    ),
    SunniTafsirOption(
      slug: 'ar-tafseer-al-saddi',
      nameAr: 'تفسير السعدي',
      nameEn: 'Tafsir Al-Saadi',
      authorAr: 'الشيخ عبد الرحمن بن ناصر السعدي',
    ),
    SunniTafsirOption(
      slug: 'ar-tafsir-al-tabari',
      nameAr: 'تفسير الطبري',
      nameEn: 'Tafsir Al-Tabari',
      authorAr: 'الإمام محمد بن جرير الطبري',
    ),
    SunniTafsirOption(
      slug: 'ar-tafseer-al-qurtubi',
      nameAr: 'تفسير القرطبي',
      nameEn: 'Tafsir Al-Qurtubi',
      authorAr: 'الإمام شمس الدين القرطبي',
    ),
    SunniTafsirOption(
      slug: 'ar-tafseer-al-baghawi',
      nameAr: 'تفسير البغوي',
      nameEn: 'Tafsir Al-Baghawi',
      authorAr: 'الإمام محيي السنة البغوي',
    ),
  ];

  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;
  static const String openQuranApiBase = 'https://api.alquran.cloud/v1';
}
