import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/preference_module.dart';
import '../services/preference_service.dart';
import '../screens/feedback_screen.dart';
import '../services/shared_prefs_service.dart';

class PreferenceController extends GetxController {
  final PreferenceService _preferenceService = Get.find<PreferenceService>();

  final RxList<PreferenceModule> modules = <PreferenceModule>[].obs;
  final RxBool isLoading = true.obs;
  final RxMap<String, bool> toggleStates = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchModules();
  }

  Future<void> fetchModules() async {
    isLoading.value = true;
    try {
      final fetchedModules = await _preferenceService.getPreferenceModules();
      modules.value = fetchedModules;

      // Initialize toggle states from shared prefs
      for (var module in fetchedModules) {
        if (module.type == PreferenceModuleType.toggle) {
          toggleStates[module.id] = SharedPrefsService.getBool(module.id, defaultValue: true);
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  void handleEvent(String event, PreferenceModule module) {
    if (module.type == PreferenceModuleType.toggle) {
      _handleToggle(module);
      return;
    }

    switch (event) {
      case 'open_theme_settings':
        _openThemeBottomSheet();
        break;
      case 'open_language_settings':
        _openLanguageBottomSheet();
        break;
      case 'adjust_font_size':
        _openFontSizeSlider();
        break;
      case 'open_support_sewa':
        _navigateToSupportPage();
        break;
      case 'open_feedback':
        Get.to(() => FeedbackScreen());
        break;
      case 'open_storage_management':
        _navigateToStorageManagement();
        break;
      case 'open_about':
        _navigateToAbout();
        break;
      case 'open_help_center':
        _navigateToHelpCenter();
        break;
      default:
        debugPrint('Unhandled preference event: $event');
    }
  }

  void _handleToggle(PreferenceModule module) {
    final newValue = !(toggleStates[module.id] ?? true);
    toggleStates[module.id] = newValue;
    SharedPrefsService.setBool(module.id, newValue);

    // Add specific toggle logic if needed
    if (module.event == 'toggle_notifications') {
      _toggleNotifications(newValue);
    }
  }

  void _toggleNotifications(bool enabled) {
    debugPrint('Notifications enabled: $enabled');
  }

  void _openThemeBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1C1B1B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Theme Settings', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Customization options coming soon...', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _openLanguageBottomSheet() {}
  void _openFontSizeSlider() {}
  void _navigateToSupportPage() {}
  void _navigateToStorageManagement() {}
  void _navigateToAbout() {}
  void _navigateToHelpCenter() {}
}
