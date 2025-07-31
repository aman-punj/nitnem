import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/app_info_controller.dart';

import '../services/firebase_service.dart';

class DependencyInjection {
  static void init() {
    Get.put<AppInfoController>(
      AppInfoController(service: FirebaseAppInfoService(firestoreInstance:  FirebaseFirestore.instance)),
    );
  }
}
