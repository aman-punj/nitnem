import 'dart:convert';

import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:nitnem/models/app_info_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const _keyLanguage = 'language';
  static const _latestPatchApplied = 'last_patch_applied';
  static const _appInfo = 'app_info';
  static const _quotesCache = 'quotes_cache';

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences? _prefs;

  static SharedPreferences get instance {
    if (_prefs == null) throw Exception('SharedPrefsService not initialized');
    return _prefs!;
  }

  static Future<void> setLanguage(String code) async {
    await _prefs?.setString(_keyLanguage, code);
  }

  static String getLanguage() {
    return _prefs?.getString(_keyLanguage) ?? "pa";
  }

  static Future<void> setPatchNum(String applied) async {
    await _prefs?.setString(_latestPatchApplied, applied);
  }

  static String getPatchNum() {
    return _prefs?.getString(_latestPatchApplied) ?? "1.0.0";
  }

  static Future<void> setAppInfo(AppInfoModel appInfo) async {
    if (_prefs != null) {
      await _prefs!.setString(_appInfo, json.encode(appInfo.toMap()));
    }
  }

  static AppInfoModel getAppInfo() {
    try {
      final jsonString = _prefs?.getString(_appInfo);
      if (jsonString != null && jsonString.isNotEmpty) {
        final decodedData = json.decode(jsonString);
        if (decodedData is Map) {
          return AppInfoModel.fromMap(Map<String, dynamic>.from(decodedData));
        } else {
          debugPrint('Error: Decoded data from SharedPreferences is not a Map<String, dynamic>. Type: ${decodedData.runtimeType}');
          // Optionally clear corrupted data if it's a persistent issue
          // await _prefs?.remove(_appInfo);
        }
      }
    } catch (e) {
      debugPrint('Error decoding AppInfoModel from SharedPreferences: $e');
      // Optionally, clear corrupted data if it's a persistent issue
      // await _prefs?.remove(_appInfo);
    }

    // Return a default AppInfoModel if decoding fails, string is empty, or data is not a map
    return AppInfoModel(
      appName: '',
      environment: 'Production',
      versionControl: const VersionControlConfig(
        latestBuild: 0,
        minimumSupportedBuild: 0,
        latestVersionName: '',
        forceUpdate: false,
        updateMessage: '',
        androidStoreUrl: '',
        iosStoreUrl: '',
      ),
      maintenance: const MaintenanceConfig(
        isUnderMaintenance: false,
        maintenanceMessage: '',
      ),
      featureFlags: const FeatureFlagsConfig(
        languages: LanguageFlags(
          punjabi: true,
          english: true,
          hindi: true,
        ),
        focusReadingMode: false,
        newPlayerUi: false,
        experimentalHome: false,
      ),
    );
  }

  static Future<void> cacheQuotes(List<Map<String, dynamic>> quotes) async {
    await _prefs?.setString(_quotesCache, json.encode(quotes));
  }

  static List<Map<String, dynamic>>? getCachedQuotes() {
    final s = _prefs?.getString(_quotesCache);
    if (s == null || s.isEmpty) return null;
    try {
      return (json.decode(s) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  static bool hasContentCached() {
    return _prefs?.containsKey('content_catalog') ?? false;
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }

  static Future<void> clearWithKey(String clearKey) async {
      await _prefs?.remove(clearKey);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }
}
