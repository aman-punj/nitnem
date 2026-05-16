import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/app_info_controller.dart';
import 'package:nitnem/controllers/font_size_controller.dart';
import 'package:nitnem/controllers/language_controller.dart';
import 'package:nitnem/controllers/theme_controller.dart';
import 'package:nitnem/controllers/settings_controller.dart';
import 'package:nitnem/services/cache_service.dart';
import 'package:nitnem/core/design_system/widgets/frosted_settings_card.dart';
import 'package:nitnem/core/design_system/widgets/settings_tile.dart';
import 'package:nitnem/core/design_system/widgets/sacred_segmented_control.dart';
import 'package:nitnem/models/drawer_item.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appInfoController = Get.find<AppInfoController>();
    final fontSizeController = Get.find<FontSizeController>();
    final languageController = Get.find<LanguageController>();
    final themeController = Get.find<ThemeController>();
    final settingsController = Get.find<SettingsController>();
    final cacheService = Get.find<CacheService>();

    final enabledIds = appInfoController.menuConfig.value?.enabledItems ?? [];
    
    // Group items by section
    final groupedItems = <SettingsSection, List<DrawerMenuItem>>{};
    for (var item in DrawerMenuItem.values) {
      if (enabledIds.contains(item.id)) {
        groupedItems.putIfAbsent(item.section, () => []).add(item);
      }
    }

    return Scaffold(
      backgroundColor: SacredColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: SacredColors.textPrimary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final version = snapshot.data?.version ?? '';
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              ...groupedItems.entries.map((entry) {
                return FrostedSettingsCard(
                  title: entry.key.name.toUpperCase(),
                  children: entry.value.map((item) {
                    if (item.id == 'theme') {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Theme', style: TextStyle(color: SacredColors.textSecondary, fontSize: 13)),
                            const SizedBox(height: 8),
                            SacredSegmentedControl<String>(
                              segments: const {'auto': 'Auto', 'light': 'Light', 'dark': 'Dark'},
                              selected: _themeModeToString(themeController.themeMode.value),
                              onSelected: themeController.setTheme,
                            ),
                          ],
                        ),
                      );
                    }
                    if (item.id == 'language') {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Language', style: TextStyle(color: SacredColors.textSecondary, fontSize: 13)),
                            const SizedBox(height: 8),
                            SacredSegmentedControl<String>(
                              segments: const {'pa': 'ਪੰਜਾਬੀ', 'en': 'English', 'hi': 'हिन्दी'},
                              selected: languageController.currentLang.value,
                              onSelected: languageController.setLanguage,
                            ),
                          ],
                        ),
                      );
                    }
                    if (item.id == 'keep_awake') {
                       return Obx(() => SwitchListTile(
                         title: Text(item.title, style: const TextStyle(color: SacredColors.textPrimary)),
                         value: settingsController.isKeepAwakeEnabled.value,
                         onChanged: settingsController.toggleKeepAwake,
                       ));
                    }
                    if (item.id == 'clear_cache') {
                      return Obx(() => SettingsTile(
                        title: '${item.title} (${settingsController.storageUsage})',
                        icon: item.icon,
                        onTap: () async {
                           await cacheService.clearAllCache();
                           await settingsController.refreshStorageUsage();
                           Get.snackbar('Success', 'Cache cleared');
                        },
                      ));
                    }
                    if (item.itemType == SettingsItemType.slider) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: const TextStyle(color: SacredColors.textSecondary, fontSize: 13)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Obx(() => Text('ੴ ਸਤਿਨਾਮੁ ਕਰਤਾ ਪੁਰਖੁ', style: SacredTypography.transcript)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Obx(() => SacredSegmentedControl<int>(
                              segments: const {0: 'Small', 1: 'Medium', 2: 'Large'},
                              selected: fontSizeController.currentStep,
                              onSelected: fontSizeController.setFontSizeStep,
                            )),
                          ],
                        ),
                      );
                    }
                    return SettingsTile(
                      title: item.title,
                      icon: item.icon,
                      onTap: () { /* Handle navigation */ },
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 20),
              Center(
                child: Text('Version $version', style: const TextStyle(color: SacredColors.textSecondary, fontSize: 12)),
              ),
              const SizedBox(height: 32),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: SacredColors.primaryAccent, width: 3),
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/images/settings_footer.png', width: 60, height: 60,fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  '“Truth is the highest virtue, but higher still is truthful living.”',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: SacredColors.primary,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    shadows: [
                      Shadow(
                        color: SacredColors.primaryAccent.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'light';
      case ThemeMode.dark: return 'dark';
      default: return 'auto';
    }
  }
}
