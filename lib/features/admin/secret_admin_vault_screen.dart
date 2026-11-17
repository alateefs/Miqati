import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/miqati_theme.dart';
import 'admin_controller.dart';

class SecretAdminVaultScreen extends StatefulWidget {
  final MiqatiAppController controller;
  const SecretAdminVaultScreen({super.key, required this.controller});

  @override
  State<SecretAdminVaultScreen> createState() => _SecretAdminVaultScreenState();
}

class _SecretAdminVaultScreenState extends State<SecretAdminVaultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  late TextEditingController _nameArCtrl;
  late TextEditingController _nameEnCtrl;
  late TextEditingController _channelCtrl;
  late TextEditingController _aboutArCtrl;
  late TextEditingController _aboutEnCtrl;
  late TextEditingController _privacyArCtrl;
  late TextEditingController _privacyEnCtrl;
  final _msgTitleCtrl = TextEditingController();
  final _msgBodyCtrl = TextEditingController();
  String _category = 'تحديث عام';
  String _priority = 'high';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _nameArCtrl = TextEditingController(text: widget.controller.appNameAr);
    _nameEnCtrl = TextEditingController(text: widget.controller.appNameEn);
    _channelCtrl = TextEditingController(text: widget.controller.cloudTopicChannel);
    _aboutArCtrl = TextEditingController(text: widget.controller.aboutTextAr);
    _aboutEnCtrl = TextEditingController(text: widget.controller.aboutTextEn);
    _privacyArCtrl = TextEditingController(text: widget.controller.privacyTextAr);
    _privacyEnCtrl = TextEditingController(text: widget.controller.privacyTextEn);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nameArCtrl.dispose();
    _nameEnCtrl.dispose();
    _channelCtrl.dispose();
    _aboutArCtrl.dispose();
    _aboutEnCtrl.dispose();
    _privacyArCtrl.dispose();
    _privacyEnCtrl.dispose();
    _msgTitleCtrl.dispose();
    _msgBodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pal = MiqatiPalette.of(widget.controller.isDarkMode);
    final c = widget.controller;

    return Scaffold(
      backgroundColor: pal.scaffoldBg,
      appBar: AppBar(
        backgroundColor: pal.cardBg,
        foregroundColor: pal.textPrimary,
        title: const Text('🔐 لوحة تحكم الأدمن المتقدمة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'قفل الخزينة',
            icon: Icon(Icons.lock_outline, color: pal.gold),
            onPressed: () {
              c.lockAdminVault();
              Navigator.of(context).pop();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          indicatorColor: pal.gold,
          labelColor: pal.gold,
          unselectedLabelColor: pal.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'الإحصائيات والرسوم'),
            Tab(icon: Icon(Icons.notifications_active), text: 'الإشعارات المتقدمة'),
            Tab(icon: Icon(Icons.tune), text: 'الهوية والمواقيت'),
            Tab(icon: Icon(Icons.mail_outline), text: 'رسائل المستخدمين'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildAnalyticsTab(pal, c),
          _buildNotificationsTab(pal, c),
          _buildBrandingAndOffsetsTab(pal, c),
          _buildInboxTab(pal, c),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(MiqatiPalette pal, MiqatiAppController c) {
    final days = c.weeklyActivityMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final recentDays = days.length > 7 ? days.sublist(days.length - 7) : days;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: pal.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: pal.gold.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset('assets/logo/app_logo.png', width: 32, height: 32, errorBuilder: (_, __, ___) => const Icon(Icons.verified_user)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('البيانات الحقيقية الفعلية للجهاز المثبّت', style: TextStyle(fontWeight: FontWeight.bold, color: pal.gold)),
                        Text('معرّف التثبيت الحقيقي: ${c.deviceInstallId}', style: TextStyle(fontSize: 11, color: pal.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _kpiBox('مرات الفتح', '${c.totalAppOpens}', pal.emerald, pal),
                  _kpiBox('صفحات القرآن', '${c.quranPagesReadCount}', pal.gold, pal),
                  _kpiBox('آيات مستمعة', '${c.ayahsListenedCount}', Colors.teal, pal),
                  _kpiBox('أذكار منجزة', '${c.adhkarCompletedCount}', Colors.indigoAccent, pal),
                  _kpiBox('صلوات مسجلة', '${c.prayersLoggedTotal}', Colors.green, pal),
                  _kpiBox('فحص القبلة', '${c.qiblaChecksCount}', Colors.amber, pal),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
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
              Text('📊 الرسم البياني لسلوك الاستخدام اليومي (آخر 7 أيام)', style: TextStyle(fontWeight: FontWeight.bold, color: pal.textPrimary)),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: CustomPaint(
                  size: const Size(double.infinity, 160),
                  painter: _BarChartPainter(
                    entries: recentDays,
                    barColor: pal.emerald,
                    labelColor: pal.textMuted,
                    valueColor: pal.gold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
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
              Text('📱 سجل التثبيت الفعلي (جهاز واحد موثّق — بدون أجهزة وهمية)', style: TextStyle(fontWeight: FontWeight.bold, color: pal.textPrimary)),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: pal.emerald.withOpacity(0.2), child: Icon(Icons.smartphone, color: pal.emerald)),
                title: Text('الجهاز الحالي (${c.deviceInstallId})', style: TextStyle(color: pal.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(
                  'أول تثبيت: ${c.firstInstallDate.toString().split('.').first}\nالموقع: ${c.displayCityName} • آخر سورة: ${c.lastReadSurah}',
                  style: TextStyle(color: pal.textMuted, fontSize: 11),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: pal.emerald.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text('نشط الآن', style: TextStyle(color: pal.emerald, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kpiBox(String label, String val, Color col, MiqatiPalette pal) {
    return Container(
      width: 105,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: col.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: col.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: col)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: pal.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab(MiqatiPalette pal, MiqatiAppController c) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: pal.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: pal.emerald.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('📣 منشئ الإشعارات السحابية المحمية (HMAC-SHA256)', style: TextStyle(fontWeight: FontWeight.bold, color: pal.gold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ActionChip(
                    label: const Text('🌙 تذكير قيام الليل', style: TextStyle(fontSize: 11)),
                    onPressed: () {
                      _msgTitleCtrl.text = 'تذكير بقيام الليل والوتر';
                      _msgBodyCtrl.text = 'اغتنم الثلث الأخير من الليل بالدعاء والاستغفار وصلاة الوتر.';
                      setState(() => _category = 'تذكير إيماني');
                    },
                  ),
                  ActionChip(
                    label: const Text('🎉 تهنئة عيد/مناسبة', style: TextStyle(fontSize: 11)),
                    onPressed: () {
                      _msgTitleCtrl.text = 'تقبل الله طاعاتكم';
                      _msgBodyCtrl.text = 'نسأل الله أن يعيد عليكم هذه الأيام المباركة باليمن والبركات.';
                      setState(() => _category = 'مناسبة دينية');
                    },
                  ),
                  ActionChip(
                    label: const Text('🚀 تحديث جديد', style: TextStyle(fontSize: 11)),
                    onPressed: () {
                      _msgTitleCtrl.text = 'تحديث تطبيق ميقاتي';
                      _msgBodyCtrl.text = 'تتوفر تحسينات جديدة للأذان ووضعية المصحف التفاعلي.';
                      setState(() => _category = 'تحديث تقني');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _channelCtrl,
                style: TextStyle(color: pal.textPrimary, fontSize: 12),
                decoration: const InputDecoration(labelText: 'القناة السحابية الخاصة', border: OutlineInputBorder()),
                onChanged: (v) => c.cloudTopicChannel = v.trim(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'تحديث عام', child: Text('تحديث عام')),
                        DropdownMenuItem(value: 'تذكير إيماني', child: Text('تذكير إيماني')),
                        DropdownMenuItem(value: 'مناسبة دينية', child: Text('مناسبة دينية')),
                        DropdownMenuItem(value: 'تحديث تقني', child: Text('تحديث تقني')),
                        DropdownMenuItem(value: 'تنبيه عاجل', child: Text('تنبيه عاجل')),
                      ],
                      onChanged: (v) => setState(() => _category = v ?? 'تحديث عام'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priority,
                      decoration: const InputDecoration(labelText: 'الأولوية', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'urgent', child: Text('عاجل جداً')),
                        DropdownMenuItem(value: 'high', child: Text('عالية')),
                        DropdownMenuItem(value: 'default', child: Text('عادية')),
                      ],
                      onChanged: (v) => setState(() => _priority = v ?? 'high'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _msgTitleCtrl,
                style: TextStyle(color: pal.textPrimary),
                decoration: const InputDecoration(labelText: 'عنوان الإشعار', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _msgBodyCtrl,
                maxLines: 3,
                style: TextStyle(color: pal.textPrimary),
                decoration: const InputDecoration(labelText: 'نص الرسالة للمستخدمين', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: pal.emerald, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () async {
                  if (_msgTitleCtrl.text.trim().isEmpty || _msgBodyCtrl.text.trim().isEmpty) return;
                  await c.broadcastAdminNotification(
                    title: _msgTitleCtrl.text.trim(),
                    body: _msgBodyCtrl.text.trim(),
                    category: _category,
                    priority: _priority,
                  );
                  _msgTitleCtrl.clear();
                  _msgBodyCtrl.clear();
                  if (mounted) {
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ تم إرسال الإشعار الموقّع للأجهزة النشطة فقط (دون إعادة القديم)')),
                    );
                  }
                },
                icon: const Icon(Icons.send),
                label: const Text('بث الإشعار الموثق الآن'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text('📜 سجل الإشعارات المرسلة (${c.broadcasts.length})', style: TextStyle(fontWeight: FontWeight.bold, color: pal.textPrimary)),
        const SizedBox(height: 8),
        ...c.broadcasts.map((b) => Card(
              color: pal.cardBg,
              child: ListTile(
                leading: Icon(Icons.campaign, color: pal.gold),
                title: Text(b.title, style: TextStyle(color: pal.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('${b.body}\n[${b.category}] • ${b.createdAt.toString().split('.').first}', style: TextStyle(color: pal.textMuted, fontSize: 11)),
              ),
            )),
      ],
    );
  }

  Widget _buildBrandingAndOffsetsTab(MiqatiPalette pal, MiqatiAppController c) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: pal.cardBg, borderRadius: BorderRadius.circular(18), border: Border.all(color: pal.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('🎨 هوية التطبيق', style: TextStyle(fontWeight: FontWeight.bold, color: pal.gold)),
              const SizedBox(height: 10),
              TextField(controller: _nameArCtrl, style: TextStyle(color: pal.textPrimary), decoration: const InputDecoration(labelText: 'الاسم بالعربية', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: _nameEnCtrl, style: TextStyle(color: pal.textPrimary), decoration: const InputDecoration(labelText: 'الاسم بالإنجليزية', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              TextField(controller: _aboutArCtrl, maxLines: 2, style: TextStyle(color: pal.textPrimary, fontSize: 12), decoration: const InputDecoration(labelText: 'نص حول التطبيق (عربي)', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _aboutEnCtrl, maxLines: 2, style: TextStyle(color: pal.textPrimary, fontSize: 12), decoration: const InputDecoration(labelText: 'About App (English)', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _privacyArCtrl, maxLines: 2, style: TextStyle(color: pal.textPrimary, fontSize: 12), decoration: const InputDecoration(labelText: 'سياسة الخصوصية (عربي)', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _privacyEnCtrl, maxLines: 2, style: TextStyle(color: pal.textPrimary, fontSize: 12), decoration: const InputDecoration(labelText: 'Privacy Policy (English)', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: pal.emerald, foregroundColor: Colors.white),
                onPressed: () {
                  c.updateBranding(newNameAr: _nameArCtrl.text, newNameEn: _nameEnCtrl.text, newLogoEmojiOrUrl: c.appLogoEmojiOrUrl);
                  c.updateAboutAndPrivacy(
                    newAboutAr: _aboutArCtrl.text,
                    newAboutEn: _aboutEnCtrl.text,
                    newPrivacyAr: _privacyArCtrl.text,
                    newPrivacyEn: _privacyEnCtrl.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم تحديث الهوية وحول التطبيق والسياسات')));
                },
                child: const Text('حفظ الهوية والسياسات'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: pal.cardBg, borderRadius: BorderRadius.circular(18), border: Border.all(color: pal.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('⏱️ معايرة دقائق الصلوات (± دقيقة)', style: TextStyle(fontWeight: FontWeight.bold, color: pal.gold)),
              const SizedBox(height: 8),
              ...c.manualPrayerOffsets.keys.map((k) {
                final val = c.manualPrayerOffsets[k] ?? 0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(k.toUpperCase(), style: TextStyle(color: pal.textPrimary, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            setState(() => c.manualPrayerOffsets[k] = val - 1);
                            c.persistState();
                          },
                        ),
                        Text('$val د', style: TextStyle(color: pal.gold, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() => c.manualPrayerOffsets[k] = val + 1);
                            c.persistState();
                          },
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: c.exportFullConfigJson()));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ ملف الإعدادات JSON')));
          },
          icon: const Icon(Icons.copy),
          label: const Text('نسخ إعدادات التطبيق JSON'),
        ),
      ],
    );
  }

  Widget _buildInboxTab(MiqatiPalette pal, MiqatiAppController c) {
    if (c.contactMessages.isEmpty) {
      return Center(
        child: Text('لا توجد رسائل واردة من نموذج "تواصل معنا" بعد.', style: TextStyle(color: pal.textMuted)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: c.contactMessages.length,
      itemBuilder: (_, i) {
        final m = c.contactMessages[i];
        return Card(
          color: pal.cardBg,
          child: ListTile(
            leading: Icon(Icons.person_outline, color: pal.emerald),
            title: Text('${m.name} (${m.contactInfo})', style: TextStyle(color: pal.textPrimary, fontWeight: FontWeight.bold)),
            subtitle: Text('${m.message}\n${m.createdAt.toString().split('.').first}', style: TextStyle(color: pal.textMuted, fontSize: 12)),
          ),
        );
      },
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<MapEntry<String, int>> entries;
  final Color barColor;
  final Color labelColor;
  final Color valueColor;

  _BarChartPainter({
    required this.entries,
    required this.barColor,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;
    final maxVal = entries.map((e) => e.value).fold<int>(1, (a, b) => a > b ? a : b);
    final count = entries.length;
    final slotW = size.width / count;
    final chartH = size.height - 28;
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final item = entries[i];
      final ratio = item.value / maxVal;
      final barH = (chartH - 18) * ratio;
      final barW = (slotW * 0.45).clamp(12.0, 32.0);
      final left = i * slotW + (slotW - barW) / 2;
      final top = chartH - barH;

      paint.color = barColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(left, top, barW, barH), const Radius.circular(6)),
        paint,
      );

      final valTp = TextPainter(
        text: TextSpan(text: '${item.value}', style: TextStyle(color: valueColor, fontSize: 10, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      valTp.paint(canvas, Offset(left + (barW - valTp.width) / 2, top - 14));

      final shortDate = item.key.length >= 10 ? item.key.substring(5) : item.key;
      final lblTp = TextPainter(
        text: TextSpan(text: shortDate, style: TextStyle(color: labelColor, fontSize: 9)),
        textDirection: TextDirection.ltr,
      )..layout();
      lblTp.paint(canvas, Offset(i * slotW + (slotW - lblTp.width) / 2, chartH + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => true;
}
