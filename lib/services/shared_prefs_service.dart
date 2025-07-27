import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const _keyLanguage = 'language';

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences? _prefs;

  static Future<void> setLanguage(String code) async {
    await _prefs?.setString(_keyLanguage, code);
  }

  static String getLanguage()  {
    return _prefs?.getString(_keyLanguage) ?? "hi";
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }
}
