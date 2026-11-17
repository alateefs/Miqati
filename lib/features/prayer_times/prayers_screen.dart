import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/miqati_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../admin/admin_controller.dart';
import 'prayer_calculator.dart';

class PrayersScreen extends StatefulWidget {
  final MiqatiAppController controller;
  const PrayersScreen({super.key, required this.controller});

  @override
  State<PrayersScreen> createState() => _PrayersScreenState();
}

class _PrayersScreenState extends State<PrayersScreen> {
  late Timer _timer;
  final ValueNotifier<DateTime> _nowNotifier = ValueNotifier<DateTime>(DateTime.now());
  String _lastTriggeredKey = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncNativeAlarms());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        final current = DateTime.now();
        _nowNotifier.value = current;
        _checkAutoAdhanTrigger(current);
      }
    });
  }

  void _syncNativeAlarms() {
    final s = MiqatiPrayerCalculator.compute(
      date: DateTime.now(),
      lat: widget.controller.lat,
      lng: widget.controller.lng,
      tz: widget.controller.tz,
      methodKey: widget.controller.calcMethodKey,
      asrShadowFactor: widget.controller.asrShadowFactor,
      manualOffsets: widget.controller.manualPrayerOffsets,
    );
    widget.controller.audioService.scheduleNativeBackgroundAlarms(
      {
        'الفجر': s.fajr,
        'الظهر': s.dhuhr,
        'العصر': s.asr,
        'المغرب': s.maghrib,
        'العشاء': s.isha,
      },
      widget.controller.selectedAdhanVoice.pathOrUrl,
      widget.controller.locale.languageCode,
    );
  }

  void _checkAutoAdhanTrigger(DateTime now) {
    if (now.second > 1) return;
    final curMins = now.hour * 60 + now.minute;
    final dateTag = '${now.year}-${now.month}-${now.day}';
    final s = MiqatiPrayerCalculator.compute(
      date: now,
      lat: widget.controller.lat,
      lng: widget.controller.lng,
      tz: widget.controller.tz,
      methodKey: widget.controller.calcMethodKey,
      asrShadowFactor: widget.controller.asrShadowFactor,
      manualOffsets: widget.controller.manualPrayerOffsets,
    );
    final map = {
      'fajr': ('الفجر', s.fajr),
      'dhuhr': ('الظهر', s.dhuhr),
      'asr': ('العصر', s.asr),
      'maghrib': ('المغرب', s.maghrib),
      'isha': ('العشاء', s.isha),
    };
    for (final entry in map.entries) {
      final trigKey = '${entry.key}_$dateTag';
      if (entry.value.$2 == curMins &&
          _lastTriggeredKey != trigKey &&
          widget.controller.prayerNotifyModes[entry.key] != 'صامت') {
        _lastTriggeredKey = trigKey;
        widget.controller.audioService.triggerAdhanWithNotificationStop(
          prayerName: entry.value.$1,
          voice: widget.controller.selectedAdhanVoice,
          langCode: widget.controller.locale.languageCode,
          isTest: false,
        );
        break;
      }
    }
  }

  String _formatLiveClock(DateTime dt, bool isEn) {
    final h24 = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final suffix = isEn ? (h24 >= 12 ? 'PM' : 'AM') : (h24 >= 12 ? 'م' : 'ص');
    final h12 = (h24 % 12 == 0 ? 12 : h24 % 12).toString().padLeft(2, '0');
    return '$h12:$m:$s $suffix';
  }

  @override
  void dispose() {
    _timer.cancel();
    _nowNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isEn = !t.isAr;
    final pal = MiqatiPalette.of(widget.controller.isDarkMode);

    return ValueListenableBuilder<DateTime>(
      valueListenable: _nowNotifier,
      builder: (context, now, _) {
        final schedule = MiqatiPrayerCalculator.compute(
          date: now,
          lat: widget.controller.lat,
          lng: widget.controller.lng,
          tz: widget.controller.tz,
          methodKey: widget.controller.calcMethodKey,
          asrShadowFactor: widget.controller.asrShadowFactor,
          manualOffsets: widget.controller.manualPrayerOffsets,
        );
        final nowTotalSeconds = now.hour * 3600 + now.minute * 60 + now.second;
        final allRows = [
          ('fajr', t.tr('fajr'), '🌙', schedule.fajr, true),
          ('sunrise', t.tr('sunrise'), '🌅', schedule.sunrise, false),
          ('dhuhr', t.tr('dhuhr'), '☀️', schedule.dhuhr, true),
          ('asr', t.tr('asr'), '🌤️', schedule.asr, true),
          ('maghrib', t.tr('maghrib'), '🌇', schedule.maghrib, true),
          ('isha', t.tr('isha'), '🌌', schedule.isha, true),
        ];
        final prayerMinsMap = {
          'fajr': schedule.fajr,
          'dhuhr': schedule.dhuhr,
          'asr': schedule.asr,
          'maghrib': schedule.maghrib,
          'isha': schedule.isha,
        };

        final obligatory = allRows.where((r) => r.$5).toList();
        String nextKey = 'fajr';
        String nextName = t.tr('fajr');
        int nextMins = schedule.fajr + 1440;
        int prevMins = schedule.isha;

        for (var i = 0; i < obligatory.length; i++) {
          final pSec = obligatory[i].$4 * 60;
          if (pSec > nowTotalSeconds) {
            nextKey = obligatory[i].$1;
            nextName = obligatory[i].$2;
            nextMins = obligatory[i].$4;
            prevMins = i > 0 ? obligatory[i - 1].$4 : obligatory.last.$4 - 1440;
            break;
          }
        }

        final remTotalSec = ((nextMins * 60) - nowTotalSeconds).clamp(0, 86400);
        final remH = (remTotalSec ~/ 3600).toString().padLeft(2, '0');
        final remM = ((remTotalSec % 3600) ~/ 60).toString().padLeft(2, '0');
        final remS = (remTotalSec % 60).toString().padLeft(2, '0');
        final spanSec = ((nextMins - prevMins) * 60).clamp(1, 86400);
        final progress = (1.0 - (remTotalSec / spanSec)).clamp(0.0, 1.0);
        final doneCount = widget.controller.prayerDoneToday.values.where((v) => v).length;
        final hijriLabel = MiqatiPrayerCalculator.formatHijriLabel(now, isEn: isEn, offsetDays: widget.controller.hijriOffsetDays);
        final gregLabel = MiqatiPrayerCalculator.formatGregorianLabel(now, isEn: isEn);

        return ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: pal.cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: pal.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📍 ${widget.controller.displayCityName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: pal.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text('$hijriLabel • $gregLabel', style: TextStyle(fontSize: 12, color: pal.gold, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: pal.emerald.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: pal.emerald.withOpacity(0.4)),
                        ),
                        child: Text(
                          _formatLiveClock(now, isEn),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: pal.emerald),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [pal.emerald.withOpacity(0.28), pal.cardAlt]),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: pal.emerald.withOpacity(0.45)),
                    ),
                    child: Column(
                      children: [
                        Text(t.tr('next_prayer'), style: TextStyle(fontSize: 12, color: pal.textMuted)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(nextName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: pal.textPrimary)),
                            const SizedBox(width: 10),
                            Text(
                              MiqatiPrayerCalculator.format12h(nextMins % 1440, isEn: isEn),
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: pal.gold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$remH:$remM:$remS',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: pal.gold, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: pal.cardBg,
                            valueColor: AlwaysStoppedAnimation<Color>(pal.emerald),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // تظهر لافتة إيقاف الأذان هنا فقط عندما يعمل أذان صلاة فعلي وليس تجربة الإعدادات
            if (widget.controller.audioService.isLivePrayerAdhanPlaying)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: pal.danger.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: pal.danger),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '🔊 ${t.tr('adhan_playing_now')} ${widget.controller.audioService.currentPlayingPrayer}',
                        style: TextStyle(color: pal.textPrimary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: pal.danger, foregroundColor: Colors.white),
                      onPressed: widget.controller.audioService.stopAdhanFromAppOrNotification,
                      icon: const Icon(Icons.stop_circle),
                      label: Text(t.tr('stop_adhan')),
                    ),
                  ],
                ),
              ),
            if (widget.controller.showHabitTracker)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: pal.cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: pal.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('✅ ${t.tr('habit_tracker')}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: pal.textPrimary)),
                        Text('$doneCount / 5', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: pal.gold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'].map((k) {
                        final done = widget.controller.prayerDoneToday[k] ?? false;
                        final pMin = prayerMinsMap[k] ?? 0;
                        final hasEntered = nowTotalSeconds >= pMin * 60;
                        return GestureDetector(
                          onTap: () {
                            if (!hasEntered) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(t.tr('prayer_locked')), duration: const Duration(seconds: 2)),
                              );
                              return;
                            }
                            widget.controller.togglePrayerHabitIfAllowed(k, true);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: !hasEntered
                                  ? pal.cardAlt.withOpacity(0.5)
                                  : (done ? pal.emerald.withOpacity(0.25) : pal.cardAlt),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: !hasEntered ? pal.border : (done ? pal.emerald : pal.gold.withOpacity(0.4)),
                              ),
                            ),
                            child: Text(
                              '${!hasEntered ? "🔒 " : (done ? "✓ " : "○ ")}${t.tr(k)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: !hasEntered ? pal.textMuted : (done ? pal.emerald : pal.textPrimary),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ...allRows.map((r) {
              final key = r.$1;
              final name = r.$2;
              final icon = r.$3;
              final mins = r.$4;
              final isOblig = r.$5;
              final isNext = key == nextKey;
              final iqMin = widget.controller.iqamahMinutes[key] ?? 0;
              final mode = widget.controller.prayerNotifyModes[key] ?? 'أذان كامل';

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isNext ? pal.emerald.withOpacity(0.18) : pal.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isNext ? pal.gold : pal.border, width: isNext ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: pal.textPrimary)),
                          if (isOblig && widget.controller.showIqamahBadges)
                            Text(
                              '${t.tr('iqamah_after')} $iqMin ${t.tr('min_short')}',
                              style: TextStyle(fontSize: 11, color: pal.textMuted),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      MiqatiPrayerCalculator.format12h(mins, isEn: isEn),
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isNext ? pal.gold : pal.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => widget.controller.cyclePrayerNotifyMode(key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: mode == 'صامت' ? pal.cardAlt : pal.emerald.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: mode == 'صامت' ? pal.border : pal.emerald.withOpacity(0.5)),
                        ),
                        child: Text(
                          isEn
                              ? (mode == 'أذان كامل' ? 'Full Adhan' : (mode == 'تكبير' ? 'Takbir' : (mode == 'تنبيه' ? 'Alert' : 'Silent')))
                              : mode,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: mode == 'صامت' ? pal.textMuted : pal.emerald,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: pal.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: pal.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(isEn ? 'Duha' : 'صلاة الضحى', style: TextStyle(fontSize: 11, color: pal.textMuted)),
                        const SizedBox(height: 2),
                        Text(MiqatiPrayerCalculator.format12h(schedule.duha, isEn: isEn), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: pal.gold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(isEn ? 'Midnight' : 'منتصف الليل', style: TextStyle(fontSize: 11, color: pal.textMuted)),
                        const SizedBox(height: 2),
                        Text(MiqatiPrayerCalculator.format12h(schedule.midnight, isEn: isEn), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: pal.gold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(isEn ? 'Last Third' : 'الثلث الأخير (القيام)', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: pal.textMuted)),
                        const SizedBox(height: 2),
                        Text(MiqatiPrayerCalculator.format12h(schedule.lastThird, isEn: isEn), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: pal.gold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
