import 'package:flutter/material.dart';
import '../../config/miqati_theme.dart';
import '../admin/admin_controller.dart';

class HijriMonthSpec {
  final int monthNumber;
  final String nameAr;
  final String nameEn;
  final DateTime gregorianStart;
  final int lengthDays;

  const HijriMonthSpec({
    required this.monthNumber,
    required this.nameAr,
    required this.nameEn,
    required this.gregorianStart,
    required this.lengthDays,
  });
}

class IslamicOccasionItem {
  final int hijriMonth;
  final int hijriDay;
  final String titleAr;
  final String gregorianDateStr;
  final DateTime eventUtcDate;
  final String badge;
  final Color distinctColor;
  final String descriptionAr;

  const IslamicOccasionItem({
    required this.hijriMonth,
    required this.hijriDay,
    required this.titleAr,
    required this.gregorianDateStr,
    required this.eventUtcDate,
    required this.badge,
    required this.distinctColor,
    required this.descriptionAr,
  });
}

class HijriCalendarScreen extends StatefulWidget {
  final MiqatiAppController controller;
  const HijriCalendarScreen({super.key, required this.controller});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  int _selectedMonthIdx = 5; // Jumada al-Akhirah 1448
  IslamicOccasionItem? _inspectedOccasion;

  static final List<HijriMonthSpec> months1448 = [
    HijriMonthSpec(monthNumber: 1, nameAr: 'محرم 1448 هـ', nameEn: 'Muharram 1448', gregorianStart: DateTime.utc(2026, 6, 16), lengthDays: 30),
    HijriMonthSpec(monthNumber: 2, nameAr: 'صفر 1448 هـ', nameEn: 'Safar 1448', gregorianStart: DateTime.utc(2026, 7, 16), lengthDays: 29),
    HijriMonthSpec(monthNumber: 3, nameAr: 'ربيع الأول 1448 هـ', nameEn: 'Rabi al-Awwal 1448', gregorianStart: DateTime.utc(2026, 8, 14), lengthDays: 29),
    HijriMonthSpec(monthNumber: 4, nameAr: 'ربيع الثاني 1448 هـ', nameEn: 'Rabi al-Thani 1448', gregorianStart: DateTime.utc(2026, 9, 12), lengthDays: 30),
    HijriMonthSpec(monthNumber: 5, nameAr: 'جمادى الأولى 1448 هـ', nameEn: 'Jumada al-Ula 1448', gregorianStart: DateTime.utc(2026, 10, 12), lengthDays: 30),
    HijriMonthSpec(monthNumber: 6, nameAr: 'جمادى الآخرة 1448 هـ', nameEn: 'Jumada al-Akhirah 1448', gregorianStart: DateTime.utc(2026, 11, 11), lengthDays: 29),
    HijriMonthSpec(monthNumber: 7, nameAr: 'رجب 1448 هـ', nameEn: 'Rajab 1448', gregorianStart: DateTime.utc(2026, 12, 10), lengthDays: 30),
    HijriMonthSpec(monthNumber: 8, nameAr: 'شعبان 1448 هـ', nameEn: 'Shaban 1448', gregorianStart: DateTime.utc(2027, 1, 9), lengthDays: 30),
    HijriMonthSpec(monthNumber: 9, nameAr: 'رمضان المبارك 1448 هـ', nameEn: 'Ramadan 1448', gregorianStart: DateTime.utc(2027, 2, 8), lengthDays: 29),
    HijriMonthSpec(monthNumber: 10, nameAr: 'شوال 1448 هـ', nameEn: 'Shawwal 1448', gregorianStart: DateTime.utc(2027, 3, 9), lengthDays: 30),
    HijriMonthSpec(monthNumber: 11, nameAr: 'ذو القعدة 1448 هـ', nameEn: 'Dhu al-Qadah 1448', gregorianStart: DateTime.utc(2027, 4, 8), lengthDays: 29),
    HijriMonthSpec(monthNumber: 12, nameAr: 'ذو الحجة 1448 هـ', nameEn: 'Dhu al-Hijjah 1448', gregorianStart: DateTime.utc(2027, 5, 7), lengthDays: 30),
  ];

  static const List<String> gregMonthsShort = [
    'يناير','فبراير','مارس','أبريل','مايو','يونيو',
    'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'
  ];

  static final List<IslamicOccasionItem> allOccasions = [
    IslamicOccasionItem(
      hijriMonth: 1,
      hijriDay: 1,
      titleAr: 'رأس السنة الهجرية 1448 هـ',
      gregorianDateStr: '16 يونيو 2026 م',
      eventUtcDate: DateTime.utc(2026, 6, 16),
      badge: 'مطلع العام الهجري',
      distinctColor: const Color(0xFF6366F1),
      descriptionAr: 'بداية العام الهجري الجديد وأول شهر الله المحرم من الأشهر الحرم التي يعظم فيها الأجر.',
    ),
    IslamicOccasionItem(
      hijriMonth: 1,
      hijriDay: 10,
      titleAr: 'يوم عاشوراء (صيام سنة نبوية)',
      gregorianDateStr: '25 يونيو 2026 م',
      eventUtcDate: DateTime.utc(2026, 6, 25),
      badge: 'يكفر سنة ماضية',
      distinctColor: const Color(0xFF0284C7),
      descriptionAr: 'اليوم الذي نجى الله فيه موسى عليه السلام؛ صيامه يكفر ذنوب السنة الماضية ويستحب صيام تاسوعاء معه.',
    ),
    IslamicOccasionItem(
      hijriMonth: 3,
      hijriDay: 12,
      titleAr: 'ذكرى المولد النبوي الشريف',
      gregorianDateStr: '25 أغسطس 2026 م',
      eventUtcDate: DateTime.utc(2026, 8, 25),
      badge: 'سيرة المصطفى ﷺ',
      distinctColor: const Color(0xFFEC4899),
      descriptionAr: 'ذكرى مولد خير البشر سيدنا محمد ﷺ في شهر ربيع الأول، فرصة لتدارس سيرته العطرة والإكثار من الصلاة والسلام عليه.',
    ),
    IslamicOccasionItem(
      hijriMonth: 6,
      hijriDay: 13,
      titleAr: 'الأيام البيض لشهر جمادى الآخرة (13-15)',
      gregorianDateStr: '23 - 25 نوفمبر 2026 م',
      eventUtcDate: DateTime.utc(2026, 11, 23),
      badge: 'صيام 3 أيام',
      distinctColor: const Color(0xFF0EA5E9),
      descriptionAr: 'أيام الثالث عشر والرابع عشر والخامس عشر من كل شهر هجري؛ صيامها كصيام الدهر كما أوصى النبي ﷺ.',
    ),
    IslamicOccasionItem(
      hijriMonth: 7,
      hijriDay: 1,
      titleAr: 'غرة شهر رجب الحرام 1448 هـ',
      gregorianDateStr: '10 ديسمبر 2026 م',
      eventUtcDate: DateTime.utc(2026, 12, 10),
      badge: 'شهر حرام',
      distinctColor: const Color(0xFF8B5CF6),
      descriptionAr: 'أحد الأشهر الحرم الأربعة التي قال الله فيها: (فَلَا تَظْلِمُوا فِيهِنَّ أَنْفُسَكُمْ)، ومفتتح التهيؤ الروحي لرمضان.',
    ),
    IslamicOccasionItem(
      hijriMonth: 7,
      hijriDay: 27,
      titleAr: 'ذكرى الإسراء والمعراج',
      gregorianDateStr: '5 يناير 2027 م',
      eventUtcDate: DateTime.utc(2027, 1, 5),
      badge: 'فرض الصلوات الخمس',
      distinctColor: const Color(0xFFEC4899),
      descriptionAr: 'المعجزة العظيمة التي أسري فيها بالنبي ﷺ من المسجد الحرام إلى المسجد الأقصى وعرج به إلى السماوات العلى وفرضت فيها الصلوات الخمس.',
    ),
    IslamicOccasionItem(
      hijriMonth: 8,
      hijriDay: 15,
      titleAr: 'ليلة النصف من شعبان',
      gregorianDateStr: '23 يناير 2027 م',
      eventUtcDate: DateTime.utc(2027, 1, 23),
      badge: 'شعبان ترفع فيه الأعمال',
      distinctColor: const Color(0xFF14B8A6),
      descriptionAr: 'شهر شعبان ترفع فيه الأعمال إلى رب العالمين، وكان النبي ﷺ يكثر فيه من الصيام استعداداً لشهر رمضان.',
    ),
    IslamicOccasionItem(
      hijriMonth: 9,
      hijriDay: 1,
      titleAr: 'أول أيام شهر رمضان المبارك 1448 هـ',
      gregorianDateStr: '8 فبراير 2027 م',
      eventUtcDate: DateTime.utc(2027, 2, 8),
      badge: 'شهر الصيام والقرآن',
      distinctColor: const Color(0xFFF59E0B),
      descriptionAr: 'شهر رمضان الذي أنزل فيه القرآن، تفتح فيه أبواب الجنة وتغلق أبواب النار وتصفد الشياطين.',
    ),
    IslamicOccasionItem(
      hijriMonth: 9,
      hijriDay: 27,
      titleAr: 'ليلة القدر (العشر الأواخر من رمضان)',
      gregorianDateStr: '6 مارس 2027 م',
      eventUtcDate: DateTime.utc(2027, 3, 6),
      badge: 'خير من ألف شهر',
      distinctColor: const Color(0xFFD97706),
      descriptionAr: 'ليلة مباركة في الأوتار من العشر الأواخر من رمضان، العبادة والقيام فيها خير من عبادة ألف شهر.',
    ),
    IslamicOccasionItem(
      hijriMonth: 10,
      hijriDay: 1,
      titleAr: 'عيد الفطر المبارك 1448 هـ',
      gregorianDateStr: '9 مارس 2027 م',
      eventUtcDate: DateTime.utc(2027, 3, 9),
      badge: 'عيد الفطر السعيد',
      distinctColor: const Color(0xFF9333EA),
      descriptionAr: 'يوم الجائزة والفرح بإتمام صيام رمضان، تشرع فيه زكاة الفطر وصلاة العيد والتكبير وصلة الأرحام.',
    ),
    IslamicOccasionItem(
      hijriMonth: 12,
      hijriDay: 1,
      titleAr: 'بداية عشر ذي الحجة المباركة',
      gregorianDateStr: '7 مايو 2027 م',
      eventUtcDate: DateTime.utc(2027, 5, 7),
      badge: 'أفضل أيام الدنيا',
      distinctColor: const Color(0xFF059669),
      descriptionAr: 'الأيام العشر التي أقسم الله بها في الفجر؛ العمل الصالح فيها أحب إلى الله من سائر أيام السنة.',
    ),
    IslamicOccasionItem(
      hijriMonth: 12,
      hijriDay: 9,
      titleAr: 'وقفة يوم عرفة (يكفر سنتين)',
      gregorianDateStr: '15 مايو 2027 م',
      eventUtcDate: DateTime.utc(2027, 5, 15),
      badge: 'الركن الأعظم للحج',
      distinctColor: const Color(0xFF0284C7),
      descriptionAr: 'أعظم أيام السنة، ما من يوم أكثر من أن يعتق الله فيه عبداً من النار من يوم عرفة، وصيامه لغير الحاج يكفر سنتين.',
    ),
    IslamicOccasionItem(
      hijriMonth: 12,
      hijriDay: 10,
      titleAr: 'عيد الأضحى المبارك 1448 هـ',
      gregorianDateStr: '16 مايو 2027 م',
      eventUtcDate: DateTime.utc(2027, 5, 16),
      badge: 'عيد النحر الأكبر',
      distinctColor: const Color(0xFFE11D48),
      descriptionAr: 'يوم الحج الأكبر وعيد النحر، تشرع فيه صلاة العيد وذبح الأضاحي والتكبير في أيام التشريق.',
    ),
  ];

  String _formatCountdown(DateTime targetUtc, DateTime now) {
    final todayUtc = DateTime.utc(now.year, now.month, now.day);
    final diffDays = targetUtc.difference(todayUtc).inDays;
    if (diffDays == 0) {
      return '🎉 اليوم! (مناسبة جارية الآن)';
    } else if (diffDays > 0) {
      final remHours = 24 - now.hour;
      return '⏳ متبقي: $diffDays يوم و $remHours ساعة';
    } else {
      return '✓ انقضت منذ ${diffDays.abs()} يوم';
    }
  }

  void _showOccasionDialog(IslamicOccasionItem occ, MiqatiPalette pal) {
    setState(() => _inspectedOccasion = occ);
    final countdownStr = _formatCountdown(occ.eventUtcDate, DateTime.now());
    showModalBottomSheet(
      context: context,
      backgroundColor: pal.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(color: occ.distinctColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    occ.titleAr,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: pal.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: occ.distinctColor.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: occ.distinctColor),
              ),
              child: Text(
                countdownStr,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: occ.distinctColor),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'التاريخ الهجري: ${occ.hijriDay} ${months1448[occ.hijriMonth - 1].nameAr} • الميلادي: ${occ.gregorianDateStr}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: pal.emerald),
            ),
            const SizedBox(height: 10),
            Text(
              occ.descriptionAr,
              style: TextStyle(fontSize: 14, height: 1.65, color: pal.textSecondary),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: occ.distinctColor, foregroundColor: Colors.white),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('حسناً'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = MiqatiPalette.of(widget.controller.isDarkMode);
    final monthSpec = months1448[_selectedMonthIdx];
    final now = DateTime.now();
    final todayUtc = DateTime.utc(now.year, now.month, now.day);

    final startDate = monthSpec.gregorianStart.add(Duration(days: widget.controller.hijriOffsetDays));
    final firstWeekdayIndex = startDate.weekday % 7;

    final upcomingFridays = <String>[];
    for (int d = 1; d <= monthSpec.lengthDays; d++) {
      final dt = startDate.add(Duration(days: d - 1));
      if (dt.weekday == DateTime.friday && !dt.isBefore(todayUtc)) {
        upcomingFridays.add('الجمعة $d ${monthSpec.nameAr.split(" ").first} (${dt.day} ${gregMonthsShort[dt.month - 1]})');
      }
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // 1. Month Switcher
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: pal.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: pal.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _selectedMonthIdx > 0 ? () => setState(() => _selectedMonthIdx--) : null,
                    icon: Icon(Icons.chevron_right, color: pal.gold),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          monthSpec.nameAr,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: pal.textPrimary),
                        ),
                        Text(
                          '${gregMonthsShort[startDate.month - 1]} ${startDate.year} م • اضغط على أي مناسبة لعرض العد التنازلي وتعريفها',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: pal.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _selectedMonthIdx < months1448.length - 1 ? () => setState(() => _selectedMonthIdx++) : null,
                    icon: Icon(Icons.chevron_left, color: pal.gold),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 2. Full 7-Column Calendar Grid (Distinct Friday Shading + Distinct Per-Occasion Color + Shaded Passed Days)
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: pal.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: pal.border),
          ),
          child: Column(
            children: [
              Row(
                children: ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'].map((dayLabel) {
                  final isFri = dayLabel == 'الجمعة';
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isFri ? const Color(0xFF059669).withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        dayLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isFri ? const Color(0xFF10B981) : pal.gold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 0.80,
                ),
                itemCount: firstWeekdayIndex + monthSpec.lengthDays,
                itemBuilder: (context, idx) {
                  if (idx < firstWeekdayIndex) return const SizedBox.shrink();
                  final hDay = idx - firstWeekdayIndex + 1;
                  final cellDate = startDate.add(Duration(days: hDay - 1));
                  final isPassed = cellDate.isBefore(todayUtc);
                  final isToday = cellDate.year == todayUtc.year &&
                      cellDate.month == todayUtc.month &&
                      cellDate.day == todayUtc.day;
                  final isFriday = cellDate.weekday == DateTime.friday;
                  final isWhiteDay = hDay >= 13 && hDay <= 15;

                  IslamicOccasionItem? matchedOcc;
                  for (final o in allOccasions) {
                    if (o.hijriMonth == monthSpec.monthNumber && o.hijriDay == hDay) {
                      matchedOcc = o;
                      break;
                    }
                  }

                  Color cellBg = pal.cardElevated;
                  Color borderCol = pal.border;
                  if (isToday) {
                    cellBg = pal.emerald;
                    borderCol = pal.gold;
                  } else if (matchedOcc != null) {
                    cellBg = matchedOcc.distinctColor.withOpacity(0.28);
                    borderCol = matchedOcc.distinctColor;
                  } else if (isWhiteDay) {
                    cellBg = const Color(0xFF0284C7).withOpacity(0.22);
                    borderCol = const Color(0xFF0284C7);
                  } else if (isFriday) {
                    cellBg = const Color(0xFF059669).withOpacity(0.22);
                    borderCol = const Color(0xFF10B981);
                  } else if (isPassed) {
                    cellBg = pal.scaffoldBg.withOpacity(0.45);
                    borderCol = pal.border.withOpacity(0.25);
                  }

                  return GestureDetector(
                    onTap: () {
                      if (matchedOcc != null) {
                        _showOccasionDialog(matchedOcc, pal);
                      } else if (isWhiteDay) {
                        _showOccasionDialog(
                          IslamicOccasionItem(
                            hijriMonth: monthSpec.monthNumber,
                            hijriDay: hDay,
                            titleAr: 'صيام الأيام البيض ($hDay ${monthSpec.nameAr})',
                            gregorianDateStr: '${cellDate.day} ${gregMonthsShort[cellDate.month - 1]} ${cellDate.year} م',
                            eventUtcDate: cellDate,
                            badge: 'سنة نبوية',
                            distinctColor: const Color(0xFF0284C7),
                            descriptionAr: 'من صام ثلاثة أيام من كل شهر فكأنما صام الدهر كله، ويستحب تحري أيام 13 و14 و15.',
                          ),
                          pal,
                        );
                      } else if (isFriday) {
                        _showOccasionDialog(
                          IslamicOccasionItem(
                            hijriMonth: monthSpec.monthNumber,
                            hijriDay: hDay,
                            titleAr: 'يوم الجمعة المبارك ($hDay ${monthSpec.nameAr})',
                            gregorianDateStr: '${cellDate.day} ${gregMonthsShort[cellDate.month - 1]} ${cellDate.year} م',
                            eventUtcDate: cellDate,
                            badge: 'خير يوم طلعت عليه الشمس',
                            distinctColor: const Color(0xFF059669),
                            descriptionAr: 'يستحب في يوم الجمعة الاغتسال، التبكير إلى المسجد، قراءة سورة الكهف، الإكثار من الصلاة على النبي ﷺ، وتحري ساعة الإجابة.',
                          ),
                          pal,
                        );
                      }
                    },
                    child: Opacity(
                      opacity: (isPassed && !isToday && matchedOcc == null) ? 0.45 : 1.0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: cellBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderCol, width: (isToday || matchedOcc != null) ? 1.8 : 1.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (matchedOcc != null)
                                    Text('★', style: TextStyle(fontSize: 9, color: matchedOcc.distinctColor)),
                                  Text(
                                    '$hDay',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      decoration: (isPassed && !isToday) ? TextDecoration.lineThrough : null,
                                      color: isToday
                                          ? Colors.white
                                          : (matchedOcc != null
                                              ? matchedOcc.distinctColor
                                              : (isFriday ? const Color(0xFF10B981) : pal.textPrimary)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${cellDate.day} ${gregMonthsShort[cellDate.month - 1]}',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  color: isToday ? Colors.white70 : pal.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                children: [
                  _legendDot(const Color(0xFF059669), 'أيام الجمعة', pal),
                  _legendDot(const Color(0xFF9333EA), 'الأعياد', pal),
                  _legendDot(const Color(0xFFF59E0B), 'رمضان وليلة القدر', pal),
                  _legendDot(const Color(0xFF0284C7), 'عرفة / عاشوراء / البيض', pal),
                  _legendDot(pal.textMuted.withOpacity(0.4), 'يوم منقضٍ (مظلل)', pal),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 3. Upcoming Fridays Card
        if (upcomingFridays.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: pal.cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF059669).withOpacity(0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🕌 أيام الجمعة القادمة في هذا الشهر:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: upcomingFridays.map((f) {
                    return Chip(
                      backgroundColor: const Color(0xFF059669).withOpacity(0.18),
                      label: Text(f, style: TextStyle(fontSize: 11, color: pal.textPrimary, fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),

        // 4. All Islamic Occasions with Live Countdowns & Interactive Details
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: pal.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: pal.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🌟 المناسبات الإسلامية والعد التنازلي (اضغط على أي مناسبة لتعريفها):',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: pal.gold),
              ),
              const SizedBox(height: 8),
              ...allOccasions.map((occ) {
                final mName = months1448[occ.hijriMonth - 1].nameAr;
                final cd = _formatCountdown(occ.eventUtcDate, now);
                return InkWell(
                  onTap: () => _showOccasionDialog(occ, pal),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: occ.distinctColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: occ.distinctColor.withOpacity(0.55)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(color: occ.distinctColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                occ.titleAr,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: pal.textPrimary),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: occ.distinctColor.withOpacity(0.22),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                cd,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: occ.distinctColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'الهجري: ${occ.hijriDay} $mName • الميلادي: ${occ.gregorianDateStr}',
                          style: TextStyle(fontSize: 11, color: pal.emerald, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          occ.descriptionAr,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: pal.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color col, String text, MiqatiPalette pal) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 10, color: pal.textSecondary)),
      ],
    );
  }
}
