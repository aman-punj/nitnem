import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/app_info_controller.dart';
import 'package:nitnem/services/prayer_update_service.dart';

import '../controllers/home_controller.dart';
import '../services/firebase_service.dart';
import '../services/prayer_storage_service.dart';
import '../services/transcript_path_service.dart';


class DependencyInjection {
  static void init() {
    // Data layer
    Get.put(PrayerUpdateService());
    Get.put(PrayerStorageService());

    // Domain layer
    Get.put(TranscriptPathService(storageService: Get.find()));


    // Controllers
    Get.put(AppInfoController(
      service: FirebaseAppInfoService(firestoreInstance: FirebaseFirestore.instance),
    ));
    Get.put(HomeController(transcriptPathService: Get.find()));
  }
}