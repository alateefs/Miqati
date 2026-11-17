import 'dart:math';
import '../../config/app_branding_and_sounds.dart';

class CityLocation {
  final String id;
  final String nameAr;
  final String nameEn;
  final double lat;
  final double lng;
  final double tz;
  final String defaultMethod;

  const CityLocation({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.lat,
    required this.lng,
    required this.tz,
    required this.defaultMethod,
  });
}

class VerifiedCitiesRegistry {
  static const List<CityLocation> cities = [
    CityLocation(id: 'riyadh', nameAr: 'الرياض، السعودية', nameEn: 'Riyadh, Saudi Arabia', lat: 24.68773, lng: 46.72185, tz: 3.0, defaultMethod: 'UmmAlQura'),
    CityLocation(id: 'makkah', nameAr: 'مكة المكرمة، السعودية', nameEn: 'Makkah, Saudi Arabia', lat: 21.4225, lng: 39.8262, tz: 3.0, defaultMethod: 'UmmAlQura'),
    CityLocation(id: 'madinah', nameAr: 'المدينة المنورة، السعودية', nameEn: 'Madinah, Saudi Arabia', lat: 24.46861, lng: 39.61417, tz: 3.0, defaultMethod: 'UmmAlQura'),
    CityLocation(id: 'jeddah', nameAr: 'جدة، السعودية', nameEn: 'Jeddah, Saudi Arabia', lat: 21.49012, lng: 39.18624, tz: 3.0, defaultMethod: 'UmmAlQura'),
    CityLocation(id: 'dubai', nameAr: 'دبي، الإمارات', nameEn: 'Dubai, UAE', lat: 25.2048, lng: 55.2708, tz: 4.0, defaultMethod: 'Dubai'),
    CityLocation(id: 'doha', nameAr: 'الدوحة، قطر', nameEn: 'Doha, Qatar', lat: 25.2854, lng: 51.5310, tz: 3.0, defaultMethod: 'Qatar'),
    CityLocation(id: 'kuwait', nameAr: 'مدينة الكويت، الكويت', nameEn: 'Kuwait City, Kuwait', lat: 29.3759, lng: 47.9774, tz: 3.0, defaultMethod: 'Kuwait'),
    CityLocation(id: 'cairo', nameAr: 'القاهرة، مصر', nameEn: 'Cairo, Egypt', lat: 30.0444, lng: 31.2357, tz: 2.0, defaultMethod: 'Egypt'),
    CityLocation(id: 'baghdad', nameAr: 'بغداد، العراق', nameEn: 'Baghdad, Iraq', lat: 33.3152, lng: 44.3661, tz: 3.0, defaultMethod: 'MWL'),
    CityLocation(id: 'casablanca', nameAr: 'الدار البيضاء، المغرب', nameEn: 'Casablanca, Morocco', lat: 33.5731, lng: -7.5898, tz: 1.0, defaultMethod: 'Morocco'),
  ];
}

class CalculationMethodSpec {
  final String key;
  final String nameAr;
  final String nameEn;
  final double fajrAngle;
  final double ishaAngle;
  final int ishaMinutesAfterMaghrib;

  const CalculationMethodSpec({
    required this.key,
    required this.nameAr,
    required this.nameEn,
    required this.fajrAngle,
    required this.ishaAngle,
    required this.ishaMinutesAfterMaghrib,
  });

  static const Map<String, CalculationMethodSpec> methods = {
    'UmmAlQura': CalculationMethodSpec(key: 'UmmAlQura', nameAr: 'جامعة أم القرى (مكة المكرمة)', nameEn: 'Umm al-Qura University', fajrAngle: 18.5, ishaAngle: 0, ishaMinutesAfterMaghrib: 90),
    'MWL': CalculationMethodSpec(key: 'MWL', nameAr: 'رابطة العالم الإسلامي', nameEn: 'Muslim World League', fajrAngle: 18.0, ishaAngle: 17.0, ishaMinutesAfterMaghrib: 0),
    'Egypt': CalculationMethodSpec(key: 'Egypt', nameAr: 'الهيئة المصرية العامة للمساحة', nameEn: 'Egyptian General Authority', fajrAngle: 19.5, ishaAngle: 17.5, ishaMinutesAfterMaghrib: 0),
    'Karachi': CalculationMethodSpec(key: 'Karachi', nameAr: 'جامعة العلوم الإسلامية بكراتشي', nameEn: 'Islamic Sciences, Karachi', fajrAngle: 18.0, ishaAngle: 18.0, ishaMinutesAfterMaghrib: 0),
    'ISNA': CalculationMethodSpec(key: 'ISNA', nameAr: 'الجمعية الإسلامية لأمريكا الشمالية', nameEn: 'ISNA (North America)', fajrAngle: 15.0, ishaAngle: 15.0, ishaMinutesAfterMaghrib: 0),
    'Dubai': CalculationMethodSpec(key: 'Dubai', nameAr: 'دبي / الإمارات', nameEn: 'Dubai / UAE', fajrAngle: 18.2, ishaAngle: 18.2, ishaMinutesAfterMaghrib: 0),
    'Qatar': CalculationMethodSpec(key: 'Qatar', nameAr: 'دار التقويم القطري', nameEn: 'Qatar Calendar House', fajrAngle: 18.0, ishaAngle: 0, ishaMinutesAfterMaghrib: 90),
    'Kuwait': CalculationMethodSpec(key: 'Kuwait', nameAr: 'وزارة الأوقاف الكويتية', nameEn: 'Kuwait Awqaf', fajrAngle: 18.0, ishaAngle: 17.5, ishaMinutesAfterMaghrib: 0),
    'Morocco': CalculationMethodSpec(key: 'Morocco', nameAr: 'وزارة الأوقاف المغربية', nameEn: 'Morocco Habous', fajrAngle: 19.0, ishaAngle: 17.0, ishaMinutesAfterMaghrib: 0),
  };
}

class DailyPrayerTimesResult {
  final int fajr;
  final int sunrise;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;
  final int duha;
  final int midnight;
  final int lastThird;
  final double qiblaBearing;
  final int distanceKm;

  const DailyPrayerTimesResult({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.duha,
    required this.midnight,
    required this.lastThird,
    required this.qiblaBearing,
    required this.distanceKm,
  });

  String format12h(int totalMins, {bool isEnglish = false}) {
    final norm = ((totalMins % 1440) + 1440) % 1440;
    final h24 = norm ~/ 60;
    final m = norm % 60;
    final suffix = isEnglish ? (h24 >= 12 ? 'PM' : 'AM') : (h24 >= 12 ? 'م' : 'ص');
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $suffix';
  }

  String format24h(int totalMins) {
    final norm = ((totalMins % 1440) + 1440) % 1440;
    final h24 = norm ~/ 60;
    final m = norm % 60;
    return '${h24.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}

class MiqatiPrayerCalculator {
  static double _dtr(double d) => (d * pi) / 180.0;
  static double _rtd(double r) => (r * 180.0) / pi;

  static DailyPrayerTimesResult compute({
    required DateTime date,
    required double lat,
    required double lng,
    required double tz,
    String methodKey = 'UmmAlQura',
    int asrShadowFactor = 1,
    Map<String, int>? manualOffsets,
  }) {
    final d0 = DateTime.utc(date.year, 1, 1);
    final d1 = DateTime.utc(date.year, date.month, date.day);
    final dayOfYear = d1.difference(d0).inDays + 1;

    final gamma = (2.0 * pi / 365.0) * (dayOfYear - 1 + 0.5);
    final eqTime = 229.18 * (
      0.000075 +
      0.001868 * cos(gamma) -
      0.032077 * sin(gamma) -
      0.014615 * cos(2 * gamma) -
      0.040849 * sin(2 * gamma)
    );
    final decl = 0.006918 -
      0.399912 * cos(gamma) +
      0.070257 * sin(gamma) -
      0.006758 * cos(2 * gamma) +
      0.000907 * sin(2 * gamma) -
      0.002697 * cos(3 * gamma) +
      0.00148 * sin(3 * gamma);

    final solarNoon = 720.0 - 4.0 * lng - eqTime + tz * 60.0;

    double hourAngleMinutes(double zenithDeg) {
      final cosHA = (cos(_dtr(zenithDeg)) - sin(_dtr(lat)) * sin(decl)) /
                    (cos(_dtr(lat)) * cos(decl));
      return _rtd(acos(cosHA.clamp(-1.0, 1.0))) * 4.0;
    }

    final method = CalculationMethodSpec.methods[methodKey] ??
        CalculationMethodSpec.methods['UmmAlQura']!;
    final fajrOffset = hourAngleMinutes(90.0 + method.fajrAngle);
    final sunriseOffset = hourAngleMinutes(90.833);

    final latRad = _dtr(lat);
    final asrCot = asrShadowFactor + tan((latRad - decl).abs());
    final asrAltRad = atan(1.0 / asrCot);
    final asrZenithDeg = 90.0 - _rtd(asrAltRad);
    final asrOffset = hourAngleMinutes(asrZenithDeg);

    final off = manualOffsets ?? const {};
    final fajr = (solarNoon - fajrOffset).round() + (off['fajr'] ?? 0);
    final sunrise = (solarNoon - sunriseOffset).round() + (off['sunrise'] ?? 0);
    final dhuhr = solarNoon.round() + (off['dhuhr'] ?? 0);
    final asr = (solarNoon + asrOffset).round() + (off['asr'] ?? 0);
    final maghrib = (solarNoon + sunriseOffset).round() + (off['maghrib'] ?? 0);
    final ishaBase = method.ishaMinutesAfterMaghrib > 0
        ? maghrib + method.ishaMinutesAfterMaghrib
        : (solarNoon + hourAngleMinutes(90.0 + method.ishaAngle)).round();
    final isha = ishaBase + (off['isha'] ?? 0);

    final nightSpan = (fajr + 1440) - maghrib;
    final duha = sunrise + 20;
    final midnight = maghrib + (nightSpan ~/ 2);
    final lastThird = maghrib + ((nightSpan * 2) ~/ 3);

    return DailyPrayerTimesResult(
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
      duha: duha,
      midnight: midnight,
      lastThird: lastThird,
      qiblaBearing: calculateQiblaBearing(lat, lng),
      distanceKm: calculateDistanceKm(lat, lng),
    );
  }

  static double calculateQiblaBearing(double lat, double lng) {
    final phi1 = _dtr(lat);
    final phi2 = _dtr(AppBrandingAndSounds.kaabaLatitude);
    final dLambda = _dtr(AppBrandingAndSounds.kaabaLongitude - lng);
    final y = sin(dLambda);
    final x = cos(phi1) * tan(phi2) - sin(phi1) * cos(dLambda);
    return (_rtd(atan2(y, x)) + 360.0) % 360.0;
  }

  static int calculateDistanceKm(double lat, double lng) {
    const r = 6371.0;
    final phi1 = _dtr(lat);
    final phi2 = _dtr(AppBrandingAndSounds.kaabaLatitude);
    final dPhi = phi2 - phi1;
    final dLambda = _dtr(AppBrandingAndSounds.kaabaLongitude - lng);
    final a = pow(sin(dPhi / 2), 2) + cos(phi1) * cos(phi2) * pow(sin(dLambda / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return (r * c).round();
  }

  static String format12h(int totalMins, {bool isEn = false}) {
    final norm = ((totalMins % 1440) + 1440) % 1440;
    final h24 = norm ~/ 60;
    final m = norm % 60;
    final suffix = isEn ? (h24 >= 12 ? 'PM' : 'AM') : (h24 >= 12 ? 'م' : 'ص');
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $suffix';
  }

  static double computeQiblaBearing(double lat, double lng) {
    const kLat = 21.4225 * pi / 180.0;
    const kLng = 39.8262 * pi / 180.0;
    final uLat = lat * pi / 180.0;
    final uLng = lng * pi / 180.0;
    final dLng = kLng - uLng;
    final y = sin(dLng);
    final x = cos(uLat) * tan(kLat) - sin(uLat) * cos(dLng);
    return (atan2(y, x) * 180.0 / pi + 360.0) % 360.0;
  }

  static double computeDistanceToMakkahKm(double lat, double lng) {
    const r = 6371.0;
    final dLat = (21.4225 - lat) * pi / 180.0;
    final dLng = (39.8262 - lng) * pi / 180.0;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat * pi / 180.0) * cos(21.4225 * pi / 180.0) * sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static String formatHijriLabel(DateTime gDate, {bool isEn = false, int offsetDays = 0}) {
    final adj = gDate.add(Duration(days: offsetDays));
    final jd = ((1461 * (adj.year + 4800 + ((adj.month - 14) ~/ 12))) ~/ 4) +
        ((367 * (adj.month - 2 - 12 * ((adj.month - 14) ~/ 12))) ~/ 12) -
        ((3 * ((adj.year + 4900 + ((adj.month - 14) ~/ 12)) ~/ 100)) ~/ 4) +
        adj.day - 32075;
    var l = jd - 1948440 + 10632;
    final n = ((l - 1) ~/ 10631);
    l = l - 10631 * n + 354;
    final j = (((10985 - l) ~/ 5316)) * (((50 * l) ~/ 17719)) + ((l ~/ 5670)) * (((43 * l) ~/ 15238));
    l = l - (((30 - j) ~/ 15)) * (((17719 * j) ~/ 50)) - ((j ~/ 16)) * (((15238 * j) ~/ 43)) + 29;
    final month = ((24 * l) ~/ 709);
    final day = l - ((709 * month) ~/ 24);
    final year = 30 * n + j - 30;
    const monthsAr = ['', 'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'];
    const monthsEn = ['', 'Muharram', 'Safar', 'Rabi I', 'Rabi II', 'Jumada I', 'Jumada II', 'Rajab', 'Shaban', 'Ramadan', 'Shawwal', 'Dhul Qadah', 'Dhul Hijjah'];
    final mName = isEn ? monthsEn[month.clamp(1, 12)] : monthsAr[month.clamp(1, 12)];
    return '$day $mName $year ${isEn ? "AH" : "هـ"}';
  }

  static String formatGregorianLabel(DateTime dt, {bool isEn = false}) {
    const mAr = ['', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    const mEn = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${isEn ? mEn[dt.month] : mAr[dt.month]} ${dt.year}';
  }

}
