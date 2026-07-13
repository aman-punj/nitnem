import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/app_config_model.dart';
import '../../models/developer_support_model.dart';
import '../../models/feature_flags_model.dart';
import '../app_info_service.dart';

/// Drop-in replacement for [FirebaseAppInfoService] that implements
/// the [AppInfoService] interface using bundled JSON fixtures.
class MockAppInfoService implements AppInfoService {
  static const _mobileAsset = 'assets/mock_data/app_config__mobile.json';
  static const _settingsAsset = 'assets/mock_data/app_config__settings.json';
  static const _devSupportAsset =
      'assets/mock_data/app_config__developer_support.json';

  @override
  Future<AppConfig?> fetchAppInfo() async {
    try {
      final raw = await rootBundle.loadString(_mobileAsset);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return AppConfig.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Menu?> fetchMenuSettings() async {
    try {
      final raw = await rootBundle.loadString(_settingsAsset);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return Menu.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DeveloperSupport?> fetchDeveloperSupport() async {
    try {
      final raw = await rootBundle.loadString(_devSupportAsset);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return DeveloperSupport.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<FeatureFlags?> fetchFeatureFlags() async {
    // Not yet implemented in the real service either.
    return null;
  }
}
