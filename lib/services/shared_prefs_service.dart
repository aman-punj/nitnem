import 'dart:convert';

import 'package:nitnem/models/app_info_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const _keyLanguage = 'language';
  static const _latestPatchApplied = 'last_patch_applied';
  static const _appInfo = 'app_info';

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences? _prefs;

  static Future<void> setLanguage(String code) async {
    await _prefs?.setString(_keyLanguage, code);
  }

  static String getLanguage() {
    return _prefs?.getString(_keyLanguage) ?? "hi";
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
        final map = json.decode(jsonString) as Map<String, dynamic>;
        return AppInfoModel.fromMap(map);
      }
    } catch (_) {}

    return AppInfoModel(
      updateFor: [],
      updateNotes: '',
      currentVersion: '1.0.0',
      minorUpdateAvailable: false,
      forceUpdate: false,
      lastMinorUpdateTime: DateTime.now(),
    );
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }
}
