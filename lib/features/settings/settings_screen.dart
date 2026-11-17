import 'package:flutter/material.dart';
import '../../config/app_branding_and_sounds.dart';
import '../../config/miqati_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../admin/admin_controller.dart';
import '../prayer_times/prayer_calculator.dart';

class SettingsScreen extends StatefulWidget {
  final MiqatiAppController controller;
  const SettingsScreen({super.key, required this.controller});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showContactModal(MiqatiPalette pal, bool isAr) {
    final nameCtrl = TextEditingController();
    final infoCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    var sending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: pal.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 18,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isAr ? '✉️ تواصل معنا' : '✉️ Contact Us',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: pal.gold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: pal.textPrimary),
                decoration: InputDecoration(labelText: isAr ? 'الاسم' : 'Your Name', border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: infoCtrl,
                style: TextStyle(color: pal.textPrimary),
                decoration: InputDecoration(labelText: isAr ? 'البريد الإلكتروني أو وسيلة التواصل' : 'Email / Contact Info', border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: msgCtrl,
                maxLines: 3,
                style: TextStyle(color: pal.textPrimary),
                decoration: InputDecoration(labelText: isAr ? 'رسالتك أو ملاحظتك' : 'Your Message', border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: pal.emerald, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                onPressed: sending
                    ? null
                    : () async {
                        if (nameCtrl.text.trim().isEmpty || msgCtrl.text.trim().isEmpty) return;
                        setModalState(() => sending = true);
                        await widget.controller.submitContactMessage(
                          name: nameCtrl.text,
                          contactInfo: infoCtrl.text,
                          message: msgCtrl.text,
                        );
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isAr ? '✅ تم إرسال رسالتك إلى المطور بنجاح' : '✅ Message sent to developer')),
                          );
                        }
                      },
                icon: const Icon(Icons.send),
                label: Text(sending ? '...' : (isAr ? 'إرسال الرسالة' : 'Send Message')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutAndPrivacyDialog(MiqatiPalette pal, bool isAr) {
    final c = widget.controller;
    final about = isAr ? c.aboutTextAr : c.aboutTextEn;
    final privacy = isAr ? c.privacyTextAr : c.privacyTextEn;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: pal.cardBg,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/logo/app_logo.png', width: 34, height: 34, errorBuilder: (_, __, ___) => const Icon(Icons.mosque)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isAr ? 'حول التطبيق وسياسة الخصوصية' : 'About & Privacy Policy',
                style: TextStyle(color: pal.gold, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            '$about\n\n${isAr ? "سياسة الخصوصية:" : "Privacy Policy:"}\n$privacy',
            style: TextStyle(color: pal.textPrimary, fontSize: 13, height: 1.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isAr ? 'إغلاق' : 'Close', style: TextStyle(color: pal.gold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isAr = t.isAr;
    final pal = MiqatiPalette.of(widget.controller.isDarkMode);
    final c = widget.controller;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _sectionCard(
          pal,
          isAr ? '📍 الموقع التلقائي والحساب الفلكي' : '📍 Auto GPS & Calculation',
          [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: pal.cardAlt, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.displayCityName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: pal.textPrimary, fontWeight: FontWeight.bold)),
                        Text('${c.lat.toStringAsFixed(3)}°, ${c.lng.toStringAsFixed(3)}°', style: TextStyle(color: pal.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: pal.emerald, foregroundColor: Colors.white),
                    onPressed: c.isDetectingGps ? null : c.detectLocationViaGps,
                    icon: const Icon(Icons.my_location, size: 16),
                    label: Text(c.isDetectingGps ? '...' : (isAr ? 'تحديث GPS' : 'Update GPS'), style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<CityLocation>(
              value: VerifiedCitiesRegistry.cities.contains(c.currentCity) ? c.currentCity : VerifiedCitiesRegistry.cities.first,
              isExpanded: true,
              decoration: InputDecoration(labelText: isAr ? 'منطقة احتياطية' : 'Fallback Region', border: const OutlineInputBorder()),
              items: VerifiedCitiesRegistry.cities
                  .map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(isAr ? city.nameAr : city.nameEn, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (city) {
                if (city != null) c.selectCity(city);
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: c.calcMethodKey,
              isExpanded: true,
              decoration: InputDecoration(labelText: isAr ? 'طريقة الحساب' : 'Calculation Method', border: const OutlineInputBorder()),
              items: CalculationMethodSpec.methods.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(isAr ? e.value.nameAr : e.value.nameEn, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  c.calcMethodKey = val;
                  c.persistState();
                  c.notifyListeners();
                }
              },
            ),
          ],
        ),

        _sectionCard(
          pal,
          isAr ? '🔊 الأذان والتشغيل بالخلفية' : '🔊 Adhan Voice & Background Service',
          [
            DropdownButtonFormField<AdhanVoiceOption>(
              value: c.selectedAdhanVoice,
              isExpanded: true,
              decoration: InputDecoration(labelText: isAr ? 'صوت المؤذن' : 'Adhan Voice', border: const OutlineInputBorder()),
              items: c.adhanVoices
                  .map((v) => DropdownMenuItem(
                        value: v,
                        child: Text(v.label(isAr), overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  c.selectedAdhanVoice = v;
                  c.persistState();
                  c.notifyListeners();
                }
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: c.audioService.isTestingAdhanInSettings ? pal.danger : pal.emerald,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (c.audioService.isTestingAdhanInSettings) {
                  c.audioService.stopAdhanFromAppOrNotification();
                } else {
                  c.audioService.triggerAdhanWithNotificationStop(
                    prayerName: isAr ? 'تجربة الأذان' : 'Adhan Test',
                    voice: c.selectedAdhanVoice,
                    langCode: c.locale.languageCode,
                    isTest: true,
                  );
                }
              },
              icon: Icon(c.audioService.isTestingAdhanInSettings ? Icons.stop : Icons.play_arrow),
              label: Text(
                c.audioService.isTestingAdhanInSettings
                    ? (isAr ? 'إيقاف التجربة' : 'Stop Test')
                    : (isAr ? 'تجربة صوت الأذان هنا' : 'Test Adhan Here'),
              ),
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(isAr ? 'تذكير قبل الأذان (${c.preAdhanReminderMinutes} دقيقة)' : 'Pre-Adhan Reminder (${c.preAdhanReminderMinutes}m)', style: TextStyle(color: pal.textPrimary, fontSize: 13)),
              value: c.enablePreAdhanReminder,
              onChanged: (v) {
                c.enablePreAdhanReminder = v;
                c.persistState();
                c.notifyListeners();
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(isAr ? 'تنبيهات الأعياد والمناسبات (في اليوم وقبله بيومين)' : 'Eid & Occasion Alerts (Day-of & 1-2d Prior)', style: TextStyle(color: pal.textPrimary, fontSize: 13)),
              value: c.enableOccasionAlerts,
              onChanged: (v) {
                c.enableOccasionAlerts = v;
                c.persistState();
                c.notifyListeners();
              },
            ),
            OutlinedButton.icon(
              onPressed: c.audioService.openBatterySettings,
              icon: Icon(Icons.battery_saver, color: pal.gold),
              label: Text(
                isAr ? 'تفعيل التشغيل التلقائي واستثناء البطارية' : 'Enable Auto-Start & Battery Exemption',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: pal.gold, fontSize: 12),
              ),
            ),
          ],
        ),

        _sectionCard(
          pal,
          isAr ? '🎨 المظهر واللغة والتفسير' : '🎨 Appearance, Language & Tafsir',
          [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: c.toggleLanguage,
                    icon: const Icon(Icons.language, size: 18),
                    label: Text(isAr ? 'English' : 'العربية', overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: c.toggleTheme,
                    icon: Icon(c.isDarkMode ? Icons.light_mode : Icons.dark_mode, size: 18),
                    label: Text(c.isDarkMode ? (isAr ? 'نهاري' : 'Light') : (isAr ? 'ليلي' : 'Dark'), overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: c.selectedTafsirSlug,
              isExpanded: true,
              decoration: InputDecoration(labelText: isAr ? 'التفسير السني المعتمد' : 'Default Sunni Tafsir', border: const OutlineInputBorder()),
              items: AppBrandingAndSounds.sunniTafsirs
                  .map((tf) => DropdownMenuItem(
                        value: tf.slug,
                        child: Text(isAr ? '${tf.nameAr} — ${tf.authorAr}' : tf.nameEn, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (slug) {
                if (slug != null) c.setSelectedTafsir(slug);
              },
            ),
          ],
        ),


        Card(
          color: pal.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: pal.border)),
          child: ListTile(
            leading: Icon(Icons.widgets_outlined, color: pal.gold),
            title: Text(isAr ? 'وضع ودجت على الشاشة الرئيسية' : 'Add Home Screen Widget', style: TextStyle(color: pal.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text(isAr ? 'اختر ودجت الصلوات أو القرآن أو الأذكار لإضافتها لسطح المكتب' : 'Choose Prayers, Quran, or Adhkar widget to pin to desktop', style: TextStyle(color: pal.textMuted, fontSize: 11)),
            trailing: Icon(Icons.add_to_home_screen, color: pal.emerald),
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: pal.cardBg,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(isAr ? '📌 اختر الودجت لإضافتها لسطح المكتب' : '📌 Select Widget to Pin', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: pal.gold)),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: Icon(Icons.access_time, color: pal.emerald),
                        title: Text(isAr ? 'ودجت مواقيت الصلاة القادمة' : 'Prayer Times Widget', style: TextStyle(color: pal.textPrimary, fontWeight: FontWeight.bold)),
                        onTap: () async {
                          Navigator.of(ctx).pop();
                          final ok = await c.audioService.pinWidget('prayers');
                          if (!ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? 'اضغط مطولاً على الشاشة الرئيسية > Widgets > ميقاتي' : 'Long-press Home Screen > Widgets > Miqati')));
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.menu_book, color: pal.gold),
                        title: Text(isAr ? 'ودجت آية اليوم والقرآن' : 'Daily Quran Ayah Widget', style: TextStyle(color: pal.textPrimary, fontWeight: FontWeight.bold)),
                        onTap: () async {
                          Navigator.of(ctx).pop();
                          final ok = await c.audioService.pinWidget('quran');
                          if (!ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? 'اضغط مطولاً على الشاشة الرئيسية > Widgets > ميقاتي' : 'Long-press Home Screen > Widgets > Miqati')));
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.volunteer_activism, color: pal.emerald),
                        title: Text(isAr ? 'ودجت الأذكار والتسبيح' : 'Adhkar & Tasbih Widget', style: TextStyle(color: pal.textPrimary, fontWeight: FontWeight.bold)),
                        onTap: () async {
                          Navigator.of(ctx).pop();
                          final ok = await c.audioService.pinWidget('adhkar');
                          if (!ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? 'اضغط مطولاً على الشاشة الرئيسية > Widgets > ميقاتي' : 'Long-press Home Screen > Widgets > Miqati')));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: pal.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: pal.border)),
          child: ListTile(
            leading: Icon(Icons.mail_outline, color: pal.emerald),
            title: Text(t.tr('contact_us'), style: TextStyle(color: pal.textPrimary, fontWeight: FontWeight.bold)),
            subtitle: Text(isAr ? 'نرحب برسائلك ومقترحاتك' : 'We welcome your feedback & inquiries', style: TextStyle(color: pal.textMuted, fontSize: 12)),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: pal.gold),
            onTap: () => _showContactModal(pal, isAr),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: pal.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: pal.border)),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/logo/app_logo.png', width: 32, height: 32, errorBuilder: (_, __, ___) => const Icon(Icons.info_outline)),
            ),
            title: Text(t.tr('about_privacy'), style: TextStyle(color: pal.textPrimary, fontWeight: FontWeight.bold)),
            subtitle: Text(isAr ? 'الإصدار 8.1 • قابل للتعديل من الإدارة' : 'Version 8.1 • Admin Editable', style: TextStyle(color: pal.textMuted, fontSize: 12)),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: pal.gold),
            onTap: () => _showAboutAndPrivacyDialog(pal, isAr),
          ),
        ),
      ],
    );
  }

  Widget _sectionCard(MiqatiPalette pal, String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: pal.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: pal.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: pal.gold)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}
