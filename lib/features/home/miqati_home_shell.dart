import 'package:flutter/material.dart';
import '../../config/miqati_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../adhkar/adhkar_zakat_screen.dart';
import '../admin/admin_controller.dart';
import '../admin/secret_admin_vault_screen.dart';
import '../calendar/hijri_calendar_screen.dart';
import '../prayer_times/prayers_screen.dart';
import '../qibla/qibla_screen.dart';
import '../quran/quran_screen.dart';
import '../settings/settings_screen.dart';

class MiqatiHomeShell extends StatefulWidget {
  final MiqatiAppController controller;
  const MiqatiHomeShell({super.key, required this.controller});

  @override
  State<MiqatiHomeShell> createState() => _MiqatiHomeShellState();
}

class _MiqatiHomeShellState extends State<MiqatiHomeShell> {
  int _selectedIndex = 0;
  final Set<int> _visitedTabs = <int>{0};

  void _showSecretPasswordModal() {
    final passCtrl = TextEditingController();
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.tr('secret_vault_title')),
        content: TextField(
          controller: passCtrl,
          obscureText: true,
          autofocus: true,
          decoration: InputDecoration(
            labelText: t.tr('enter_admin_password'),
            hintText: '••••••••••',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final ok = widget.controller.verifyAndUnlockAdmin(passCtrl.text);
              Navigator.of(ctx).pop();
              if (ok) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SecretAdminVaultScreen(controller: widget.controller),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('كلمة المرور غير صحيحة')),
                );
              }
            },
            child: Text(t.tr('unlock_admin')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final pal = MiqatiPalette.of(widget.controller.isDarkMode);
    final hideBarsForMushaf = _selectedIndex == 1 && widget.controller.isFullScreenMushaf;

    return Scaffold(
      backgroundColor: pal.scaffoldBg,
      appBar: hideBarsForMushaf
          ? null
          : AppBar(
              backgroundColor: pal.cardBg,
              foregroundColor: pal.textPrimary,
              elevation: 0,
              title: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (widget.controller.registerLogoTapForSecretAdmin()) {
                    _showSecretPasswordModal();
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/logo/app_logo.png',
                        width: 32,
                        height: 32,
                        errorBuilder: (_, __, ___) => Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: pal.emerald,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.controller.appLogoEmojiOrUrl,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.controller.activeAppName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, color: pal.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              actions: const [],
            ),
      body: SafeArea(
        child: Column(
          children: [
            if (!hideBarsForMushaf &&
                widget.controller.showBroadcastBanner &&
                widget.controller.broadcasts.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: pal.emerald.withOpacity(0.2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '🔔 ${widget.controller.broadcasts.first.title}: ${widget.controller.broadcasts.first.body}',
                        style: TextStyle(color: pal.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 16, color: pal.textMuted),
                      onPressed: () {
                        widget.controller.showBroadcastBanner = false;
                        widget.controller.notifyListeners();
                      },
                    ),
                  ],
                ),
              ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  PrayersScreen(controller: widget.controller),
                  _visitedTabs.contains(1)
                      ? QuranScreen(controller: widget.controller, onSecretCodeEntered: _showSecretPasswordModal)
                      : const SizedBox.shrink(),
                  _visitedTabs.contains(2)
                      ? QiblaScreen(controller: widget.controller)
                      : const SizedBox.shrink(),
                  _visitedTabs.contains(3)
                      ? AdhkarAndZakatScreen(controller: widget.controller)
                      : const SizedBox.shrink(),
                  _visitedTabs.contains(4)
                      ? HijriCalendarScreen(controller: widget.controller)
                      : const SizedBox.shrink(),
                  _visitedTabs.contains(5)
                      ? SettingsScreen(controller: widget.controller)
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: hideBarsForMushaf
          ? null
          : NavigationBar(
              backgroundColor: pal.cardBg,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (idx) => setState(() { _selectedIndex = idx; _visitedTabs.add(idx); }),
              destinations: [
                NavigationDestination(icon: const Icon(Icons.access_time), label: t.tr('tab_prayers')),
                NavigationDestination(icon: const Icon(Icons.menu_book), label: t.tr('tab_quran')),
                NavigationDestination(icon: const Icon(Icons.explore), label: t.tr('tab_qibla')),
                NavigationDestination(icon: const Icon(Icons.volunteer_activism), label: t.tr('tab_adhkar')),
                NavigationDestination(icon: const Icon(Icons.calendar_month), label: t.tr('tab_calendar')),
                NavigationDestination(icon: const Icon(Icons.settings), label: t.tr('tab_settings')),
              ],
            ),
    );
  }
}
