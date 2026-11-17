import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../config/miqati_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../admin/admin_controller.dart';
import '../prayer_times/prayer_calculator.dart';

class QiblaScreen extends StatefulWidget {
  final MiqatiAppController controller;
  const QiblaScreen({super.key, required this.controller});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _deviceHeading = 0.0;
  bool _hasHardwareSensor = false;
  Timer? _sensorPollTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.recordQiblaCheck();
    _sensorPollTimer = Timer.periodic(const Duration(milliseconds: 120), (_) async {
      final h = await widget.controller.audioService.fetchNativeCompassHeading();
      if (mounted && h >= 0) {
        setState(() {
          _hasHardwareSensor = true;
          _deviceHeading = h;
        });
      }
    });
  }

  @override
  void dispose() {
    _sensorPollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final pal = MiqatiPalette.of(widget.controller.isDarkMode);
    final qiblaAngle = MiqatiPrayerCalculator.computeQiblaBearing(
      widget.controller.lat,
      widget.controller.lng,
    );
    final distKm = MiqatiPrayerCalculator.computeDistanceToMakkahKm(
      widget.controller.lat,
      widget.controller.lng,
    );

    final diff = ((qiblaAngle - _deviceHeading + 540) % 360) - 180;
    final aligned = diff.abs() <= 5.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: pal.cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: pal.border),
            ),
            child: Column(
              children: [
                Text(
                  '🕋 ${t.tr('qibla_title')}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: pal.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.controller.displayCityName} • ${distKm.round()} ${t.tr('km_unit')}',
                  style: TextStyle(color: pal.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 266,
                          height: 266,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pal.cardAlt,
                            border: Border.all(color: aligned ? pal.emerald : pal.gold, width: 3.5),
                            boxShadow: [
                              BoxShadow(
                                color: (aligned ? pal.emerald : pal.gold).withOpacity(0.25),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                        ),
                        Transform.rotate(
                          angle: (-_deviceHeading) * math.pi / 180,
                          child: SizedBox(
                            width: 246,
                            height: 246,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(top: 8, child: Text('N', style: TextStyle(color: pal.danger, fontWeight: FontWeight.bold, fontSize: 16))),
                                Positioned(bottom: 8, child: Text('S', style: TextStyle(color: pal.textMuted, fontWeight: FontWeight.bold, fontSize: 14))),
                                Positioned(right: 10, child: Text('E', style: TextStyle(color: pal.textMuted, fontWeight: FontWeight.bold, fontSize: 14))),
                                Positioned(left: 10, child: Text('W', style: TextStyle(color: pal.textMuted, fontWeight: FontWeight.bold, fontSize: 14))),
                                Transform.rotate(
                                  angle: qiblaAngle * math.pi / 180,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('🕋', style: TextStyle(fontSize: 28)),
                                      Container(
                                        width: 5,
                                        height: 78,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [pal.gold, pal.emerald],
                                          ),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                      const SizedBox(height: 66),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(top: 0, child: Icon(Icons.arrow_drop_down, color: pal.gold, size: 32)),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pal.gold,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: aligned ? pal.emerald.withOpacity(0.2) : pal.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    aligned
                        ? t.tr('qibla_aligned')
                        : (diff > 0
                            ? '${t.tr('rotate_right')} ${diff.abs().round()}°'
                            : '${t.tr('rotate_left')} ${diff.abs().round()}°'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: aligned ? pal.emerald : pal.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _metricPill(t.tr('qibla_bearing'), '${qiblaAngle.toStringAsFixed(1)}°', pal.gold, pal),
                    _metricPill(t.tr('device_heading'), '${_deviceHeading.toStringAsFixed(1)}°', pal.emerald, pal),
                    _metricPill(t.tr('distance_to_makkah'), '${distKm.round()} ${t.tr('km_unit')}', pal.textPrimary, pal),
                    _metricPill(
                      t.tr('coordinates'),
                      '${widget.controller.lat.toStringAsFixed(2)}°, ${widget.controller.lng.toStringAsFixed(2)}°',
                      pal.textMuted,
                      pal,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _hasHardwareSensor
                      ? t.tr('qibla_sensor_note')
                      : t.tr('qibla_sensor_note'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: pal.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricPill(String title, String val, Color col, MiqatiPalette pal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: pal.cardAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pal.border),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 10, color: pal.textMuted)),
          const SizedBox(height: 2),
          Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: col)),
        ],
      ),
    );
  }
}
