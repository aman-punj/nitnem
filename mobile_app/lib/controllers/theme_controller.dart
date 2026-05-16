import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/services/shared_prefs_service.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    final savedTheme = SharedPrefsService.getBool('theme_is_dark', defaultValue: false) ? 'dark' : 'auto';
    themeMode.value = _mapStringToThemeMode(savedTheme);
  }

  void setTheme(String themeString) {
    themeMode.value = _mapStringToThemeMode(themeString);
    // Simplified persistence for banisagar
    SharedPrefsService.setBool('theme_is_dark', themeString == 'dark');
    Get.changeThemeMode(themeMode.value);
  }

  ThemeMode _mapStringToThemeMode(String theme) {
    switch (theme) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }
}
