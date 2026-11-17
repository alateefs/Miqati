import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../config/app_branding_and_sounds.dart';

class AdhanAudioService extends ChangeNotifier {
  static const MethodChannel _channel = MethodChannel('com.miqati.app/adhan_service');

  // فصل تام بين الأذان الفعلي (الذي يظهر شريط إيقاف بالرئيسية) وبين تجربة الصوت في الإعدادات
  bool isLivePrayerAdhanPlaying = false;
  bool isTestingAdhanInSettings = false;
  bool isPlayingQuran = false;

  String currentPlayingPrayer = '';
  String currentQuranLabel = '';
  Timer? _statusPollTimer;
  VoidCallback? onQuranStreamCompleted;

  bool get isPlaying => isLivePrayerAdhanPlaying;

  Future<void> saveDiskJson(String key, String jsonStr) async {
    try {
      await _channel.invokeMethod('saveDiskJson', {'key': key, 'json': jsonStr});
    } catch (_) {}
  }

  Future<String?> loadDiskJson(String key) async {
    try {
      return await _channel.invokeMethod<String>('loadDiskJson', {'key': key});
    } catch (_) {
      return null;
    }
  }

  Future<void> saveNativeState(String jsonStr) async {
    try {
      await _channel.invokeMethod('saveState', {'json': jsonStr});
    } catch (_) {}
  }

  Future<String?> loadNativeState() async {
    try {
      return await _channel.invokeMethod<String>('loadState');
    } catch (_) {
      return null;
    }
  }

  Future<void> requestNativePermissions() async {
    try {
      await _channel.invokeMethod('requestPermissions');
    } catch (_) {}
  }

  Future<bool> pinWidget(String kind) async {
    try {
      return await _channel.invokeMethod<bool>('pinWidget', {'kind': kind}) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> refreshWidgets() async {
    try {
      await _channel.invokeMethod('refreshWidgets');
    } catch (_) {}
  }

  Future<void> openBatterySettings() async {
    try {
      await _channel.invokeMethod('openBatterySettings');
    } catch (_) {}
  }

  Future<double> fetchNativeCompassHeading() async {
    try {
      final res = await _channel.invokeMethod<double>('getCompassHeading');
      return res ?? -1.0;
    } catch (_) {
      return -1.0;
    }
  }

  Future<Map<String, dynamic>?> fetchNativeGpsLocation() async {
    try {
      final res = await _channel.invokeMethod<Map<dynamic, dynamic>>('getGpsLocation');
      if (res != null) {
        return res.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (_) {}
    return null;
  }

  Future<void> showSystemPushNotification(String title, String body) async {
    try {
      await _channel.invokeMethod('showInstantNotification', {
        'title': title,
        'body': body,
      });
    } catch (_) {}
  }

  Future<void> scheduleNativeBackgroundAlarms(
    Map<String, int> prayerMinutes,
    String voiceAssetPath,
    String langCode,
  ) async {
    try {
      await _channel.invokeMethod('scheduleAlarms', {
        'times': prayerMinutes,
        'voiceAsset': voiceAssetPath,
        'lang': langCode,
      });
    } catch (_) {}
  }

  void _ensureStatusPolling() {
    _statusPollTimer?.cancel();
    _statusPollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!isLivePrayerAdhanPlaying && !isPlayingQuran && !isTestingAdhanInSettings) {
        _statusPollTimer?.cancel();
        return;
      }
      try {
        final st = await _channel.invokeMethod<Map<dynamic, dynamic>>('getAudioStatus');
        if (st != null) {
          final adhanOn = st['adhanPlaying'] == true;
          final streamOn = st['streamPlaying'] == true;
          var changed = false;

          if (isLivePrayerAdhanPlaying && !adhanOn) {
            isLivePrayerAdhanPlaying = false;
            currentPlayingPrayer = '';
            changed = true;
          }
          if (isTestingAdhanInSettings && !adhanOn) {
            isTestingAdhanInSettings = false;
            changed = true;
          }
          if (isPlayingQuran && !streamOn) {
            isPlayingQuran = false;
            currentQuranLabel = '';
            changed = true;
            onQuranStreamCompleted?.call();
          }
          if (changed) notifyListeners();
        }
      } catch (_) {}
    });
  }

  Future<void> triggerAdhanWithNotificationStop({
    required String prayerName,
    required AdhanVoiceOption voice,
    required String langCode,
    bool isTest = false,
  }) async {
    if (isTest) {
      isTestingAdhanInSettings = true;
    } else {
      isLivePrayerAdhanPlaying = true;
      currentPlayingPrayer = prayerName;
    }
    notifyListeners();
    _ensureStatusPolling();
    try {
      await _channel.invokeMethod('startAdhanNotification', {
        'prayerName': prayerName,
        'voiceAsset': voice.pathOrUrl,
        'lang': langCode,
        'isTest': isTest,
      });
    } catch (_) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<void> stopAdhanFromAppOrNotification() async {
    isLivePrayerAdhanPlaying = false;
    isTestingAdhanInSettings = false;
    currentPlayingPrayer = '';
    notifyListeners();
    try {
      await _channel.invokeMethod('stopAdhanNotification');
    } catch (_) {}
  }

  Future<bool> playQuranAudioUrl(String url, String label) async {
    isPlayingQuran = true;
    currentQuranLabel = label;
    notifyListeners();
    _ensureStatusPolling();
    try {
      final ok = await _channel.invokeMethod<bool>('playAudioUrl', {'url': url});
      if (ok == false) {
        isPlayingQuran = false;
        currentQuranLabel = '';
        notifyListeners();
        return false;
      }
      return true;
    } catch (_) {
      isPlayingQuran = false;
      currentQuranLabel = '';
      notifyListeners();
      return false;
    }
  }

  Future<void> stopQuranAudio() async {
    isPlayingQuran = false;
    currentQuranLabel = '';
    notifyListeners();
    try {
      await _channel.invokeMethod('stopAudio');
    } catch (_) {}
  }

  @override
  void dispose() {
    _statusPollTimer?.cancel();
    super.dispose();
  }
}
