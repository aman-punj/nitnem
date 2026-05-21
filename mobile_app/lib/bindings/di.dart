import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';
import 'package:nitnem/controllers/app_info_controller.dart';
import 'package:nitnem/controllers/font_size_controller.dart';
import 'package:nitnem/controllers/preference_controller.dart';
import 'package:nitnem/controllers/language_controller.dart';
import 'package:nitnem/controllers/theme_controller.dart';
import 'package:nitnem/controllers/settings_controller.dart';
import 'package:nitnem/services/cache_service.dart';
import 'package:nitnem/services/firebase_content_service.dart';
import 'package:nitnem/services/firebase_category_service.dart';
import 'package:nitnem/services/local_content_service.dart';
import 'package:nitnem/services/prayer_asset_service.dart';
import 'package:nitnem/services/prayer_storage_service.dart';
import 'package:nitnem/services/shared_prefs_service.dart';
import 'package:nitnem/services/preference_service.dart';
import 'package:nitnem/services/transcript_sync_service.dart';
import 'package:nitnem/services/share_service.dart';
import 'package:nitnem/controllers/hukamnama_controller.dart';
import 'package:nitnem/controllers/notification_settings_controller.dart';
import 'package:nitnem/services/hukamnama_service.dart';
import 'package:nitnem/services/notification_service.dart';
import 'package:nitnem/services/analytics_service.dart';
import 'package:nitnem/services/support_service.dart';

import '../controllers/home_controller.dart';
import '../services/firebase_service.dart';
import '../services/transcript_path_service.dart';

class DependencyInjection {
  static final Completer<void> _audioBackgroundReady = Completer<void>();
  static Future<void> get audioBackgroundReady => _audioBackgroundReady.future;

  static final Completer<void> _notifSettingsReady = Completer<void>();
  static Future<void> get notifSettingsReady => _notifSettingsReady.future;

  static Future<void> init() async {
    // Data layer
    Get.put(PreferenceService());
    Get.put(FontSizeController());
    Get.put(PreferenceController());
    Get.put(LanguageController());
    Get.put(ThemeController());
    Get.put(CacheService());
    Get.put(SettingsController());
    try {
      await Get.putAsync(
        () => NotificationService().init().timeout(const Duration(seconds: 8)),
      );
    } catch (e) {
      debugPrint('NotificationService init failed: $e');
      if (!Get.isRegistered<NotificationService>()) {
        Get.put(NotificationService());
      }
    }

    Get.put(PrayerStorageService());
    Get.put(PrayerAssetService());
    Get.put(FirebaseContentService());
    Get.put(FirebaseCategoryService());
    Get.put(LocalContentService(SharedPrefsService.instance));
    Get.put(ShareService());
    Get.put(SupportService());
    Get.put(AnalyticsService());

    // Domain layer
    Get.put(TranscriptPathService(storageService: Get.find()));
    Get.put(TranscriptSyncService(Get.find(), Get.find()));

    // Controllers
    Get.put(AppInfoController(
      service: FirebaseAppInfoService(firestoreInstance: FirebaseFirestore.instance),
    ));
    Get.put(HukamnamaController(service: HukamnamaService()));
    Get.put(HomeController(
      firebaseContentService: Get.find(),
      firebaseCategoryService: Get.find(),
      localContentService: Get.find(),
      syncService: Get.find(),
      appInfoController: Get.find(),
    ));
  }

  /// Called after runApp() so AudioService.init() runs with a live Flutter
  /// engine (avoids the native-splash hang some Android devices exhibit).
  /// On failure the original just_audio platform is restored so plain audio
  /// still works. Either way a singleton AudioPlayer is registered.
  static Future<void> initAudioBackground() async {
    final originalPlatform = JustAudioPlatform.instance;
    try {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.banisagar.nitnem.channel.audio',
        androidNotificationChannelName: 'Audio Playback',
        androidNotificationIcon: 'drawable/ic_notification',
        androidStopForegroundOnPause: true,
      ).timeout(const Duration(seconds: 8));
      debugPrint('Background audio ready');
    } catch (e) {
      debugPrint('Background audio unavailable ($e) - reverting to local playback');
      // Restore the original platform so AudioPlayer works without background.
      JustAudioPlatform.instance = originalPlatform;
    } finally {
      // Create player only after background initialization attempt.
      if (!Get.isRegistered<AudioPlayer>()) {
        Get.put(AudioPlayer(), permanent: true);
      }
      if (!_audioBackgroundReady.isCompleted) {
        _audioBackgroundReady.complete();
      }
    }
  }

  /// Initializes notification scheduling after runApp() so it doesn't block
  /// Flutter's first frame. Firestore sync inside can take up to 5 s.
  static Future<void> initNotificationSettings() async {
    try {
      await Get.putAsync(
        () => NotificationSettingsController()
            .init()
            .timeout(const Duration(seconds: 8)),
      );
    } catch (e) {
      debugPrint('NotificationSettingsController init failed: $e');
      if (!Get.isRegistered<NotificationSettingsController>()) {
        Get.put(NotificationSettingsController());
      }
    } finally {
      if (!_notifSettingsReady.isCompleted) {
        _notifSettingsReady.complete();
      }
    }
  }
}
