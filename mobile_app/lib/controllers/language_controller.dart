import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/services/shared_prefs_service.dart';

class LanguageController extends GetxController {
  final RxString currentLang = 'pa'.obs;

  @override
  void onInit() {
    super.onInit();
    currentLang.value = SharedPrefsService.getLanguage();
  }

  void setLanguage(String langCode) {
    currentLang.value = langCode;
    SharedPrefsService.setLanguage(langCode);
    Get.updateLocale(Locale(langCode));
  }
}
