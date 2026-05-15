import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/app_logs.dart';
import '../models/app_config_model.dart';
import '../models/feature_flags_model.dart';
import 'app_info_service.dart';

class FirebaseAppInfoService implements AppInfoService {
  final FirebaseFirestore firestore;

  FirebaseAppInfoService({FirebaseFirestore? firestoreInstance})
      : firestore = firestoreInstance ?? FirebaseFirestore.instance;

  @override
  Future<AppConfig?> fetchAppInfo() async {
    try {
      final doc = await firestore
          .collection('app_config')
          .doc('mobile')
          .get();

      if (doc.data() != null) {
        final data = doc.data()!;
        appLogs(
          'Fetched Firestore app config: app_config/mobile',
          data: data,
          tag: 'FIRESTORE',
        );
        return AppConfig.fromMap(data);
      }
      appLogs(
        'No app config found in Firestore: app_config/mobile',
        tag: 'FIRESTORE',
      );
    } catch (e) {
      appLogs(
        'Failed to fetch app config from Firestore',
        data: {'error': e.toString()},
        tag: 'FIRESTORE',
      );
      log(e.toString());
    }
    return null;
  }

  @override
  Future<Menu?> fetchMenuSettings() async {
    try {
      final doc = await firestore
          .collection('app_config')
          .doc('settings')
          .get();

      if (doc.data() != null) {
        return Menu.fromMap(doc.data()!);
      }
    } catch (e) {
      log('Error fetching menu settings: $e');
    }
    return null;
  }

  @override
  Future<FeatureFlags?> fetchFeatureFlags() {
    throw UnimplementedError();
  }
}
