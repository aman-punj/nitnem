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
  Future<FeatureFlags?> fetchFeatureFlags() async {
    try {
      final doc = await firestore
          .collection('feature_flags')
          .doc('mobile')
          .get();

      if (doc.data() != null) {
        final data = doc.data()!;
        appLogs(
          'Fetched Firestore feature flags: feature_flags/mobile',
          data: data,
          tag: 'FIRESTORE',
        );
        return FeatureFlags.fromMap(data);
      }
      appLogs(
        'No feature flags found in Firestore: feature_flags/mobile',
        tag: 'FIRESTORE',
      );
    } catch (e) {
      appLogs(
        'Failed to fetch feature flags from Firestore',
        data: {'error': e.toString()},
        tag: 'FIRESTORE',
      );
      log(e.toString());
    }
    return null;
  }
}
