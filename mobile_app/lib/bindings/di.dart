import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/app_info_controller.dart';
import 'package:nitnem/services/firebase_content_service.dart';
import 'package:nitnem/services/firebase_category_service.dart';
import 'package:nitnem/services/local_content_service.dart';
import 'package:nitnem/services/prayer_asset_service.dart';
import 'package:nitnem/services/prayer_storage_service.dart';
import 'package:nitnem/services/shared_prefs_service.dart';
import 'package:nitnem/services/preference_service.dart';
import 'package:nitnem/services/transcript_sync_service.dart';
import 'package:nitnem/services/notification_service.dart';
import 'package:nitnem/services/audio_handler.dart';

import '../controllers/home_controller.dart';
import '../services/firebase_service.dart';
import '../services/transcript_path_service.dart';


class DependencyInjection {
  static Future<void> init() async {
    // Data layer
    Get.put(PreferenceService());
    await Get.putAsync(() => NotificationService().init());
    
    // Initialize Audio Service
    try {
      final audioHandler = await AudioService.init(
        builder: () => MyAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.example.nitnem.channel.audio',
          androidNotificationChannelName: 'Audio Playback',
          androidNotificationOngoing: true,
        ),
      );
      Get.put<MyAudioHandler>(audioHandler);
    } catch (e, stackTrace) {
      print('Error initializing AudioService: $e');
      debugPrintStack(stackTrace: stackTrace);
      // We don't crash the app; media features might be limited.
    }

    Get.put(PrayerStorageService());
    Get.put(PrayerAssetService());
    Get.put(FirebaseContentService());
    Get.put(FirebaseCategoryService());
    Get.put(LocalContentService(SharedPrefsService.instance));

    // Domain layer
    Get.put(TranscriptPathService(storageService: Get.find()));
    Get.put(TranscriptSyncService(Get.find(), Get.find()));

    // Controllers
    Get.put(AppInfoController(
      service: FirebaseAppInfoService(firestoreInstance: FirebaseFirestore.instance),
    ));
    Get.put(HomeController(
      firebaseContentService: Get.find(),
      firebaseCategoryService: Get.find(),
      localContentService: Get.find(),
      syncService: Get.find(),
      appInfoController: Get.find(),
    ));
  }
}
