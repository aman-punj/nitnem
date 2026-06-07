import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/app_info_controller.dart';
import 'package:nitnem/controllers/font_size_controller.dart';
import 'package:nitnem/controllers/language_controller.dart';
import 'package:nitnem/controllers/quote_controller.dart';
import 'package:nitnem/controllers/theme_controller.dart';
import 'package:nitnem/controllers/settings_controller.dart';
import 'package:nitnem/core/design_system/tokens/colors.dart';
import 'package:nitnem/core/design_system/tokens/radius.dart';
import 'package:nitnem/core/design_system/tokens/spacing.dart';
import 'package:nitnem/core/design_system/tokens/typography.dart';
import 'package:nitnem/core/design_system/widgets/frosted_settings_card.dart';
import 'package:nitnem/core/design_system/widgets/sacred_button.dart';
import 'package:nitnem/core/design_system/widgets/settings_tile.dart';
import 'package:nitnem/core/design_system/widgets/sacred_segmented_control.dart';
import 'package:nitnem/models/drawer_item.dart';
import 'package:nitnem/screens/developer_support_screen.dart';
import 'package:nitnem/screens/faq_screen.dart';
import 'package:nitnem/screens/feedback_screen.dart';
import 'package:nitnem/screens/notifications_settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:nitnem/services/share_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = SacredColors.of(context);
    final appInfoController = Get.find<AppInfoController>();
    final fontSizeController = Get.find<FontSizeController>();
    final languageController = Get.find<LanguageController>();
    final themeController = Get.find<ThemeController>();
    final settingsController = Get.find<SettingsController>();
    final quoteController = Get.find<QuoteController>();
    final enabledIds = appInfoController.menuConfig.value?.enabledItems ?? [];

    final groupedItems = <SettingsSection, List<DrawerMenuItem>>{};
    for (var item in DrawerMenuItem.values) {
      if (enabledIds.contains(item.id)) {
        groupedItems.putIfAbsent(item.section, () => []).add(item);
      }
    }

    return Scaffold(
      backgroundColor: c.backgroundPrimary,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final version = snapshot.data?.version ?? '';
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: SacredSpacing.marginMobile, vertical: SacredSpacing.sm),
            children: [
              ...groupedItems.entries.map((entry) {
                return FrostedSettingsCard(
                  title: entry.key.name.toUpperCase(),
                  children: entry.value.map((item) {
                    if (item.id == 'theme') {
                      // Obx ensures the indicator updates immediately on tap
                      return Obx(() => Padding(
                        padding: const EdgeInsets.fromLTRB(SacredSpacing.marginMobile, SacredSpacing.base, SacredSpacing.marginMobile, SacredSpacing.marginMobile),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _IconLabel(asset: 'assets/icons/ic_theme.svg', text: 'Theme', c: c),
                            const SizedBox(height: SacredSpacing.base),
                            SacredSegmentedControl<String>(
                              segments: const {'auto': 'Auto', 'light': 'Light', 'dark': 'Dark'},
                              selected: _themeModeToString(themeController.themeMode.value),
                              onSelected: themeController.setTheme,
                            ),
                          ],
                        ),
                      ));
                    }
                    if (item.id == 'language') {
                      return Obx(() => Padding(
                        padding: const EdgeInsets.fromLTRB(SacredSpacing.marginMobile, SacredSpacing.base, SacredSpacing.marginMobile, SacredSpacing.marginMobile),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _IconLabel(asset: 'assets/icons/ic_language.svg', text: 'Language', c: c),
                            const SizedBox(height: SacredSpacing.base),
                            SacredSegmentedControl<String>(
                              segments: const {'pa': 'ਪੰਜਾਬੀ', 'en': 'English', 'hi': 'हिन्दी'},
                              selected: languageController.currentLang.value,
                              onSelected: languageController.setLanguage,
                            ),
                          ],
                        ),
                      ));
                    }
                    if (item.id == 'keep_awake') {
                      return Obx(() => SettingsTile(
                        title: item.title,
                        icon: item.icon,
                        iconAsset: item.iconAsset,
                        onTap: () => settingsController.toggleKeepAwake(!settingsController.isKeepAwakeEnabled.value),
                        trailing: Switch(
                          value: settingsController.isKeepAwakeEnabled.value,
                          onChanged: settingsController.toggleKeepAwake,
                          activeThumbColor: c.primaryAccent,
                        ),
                      ));
                    }
                    if (item.id == 'clear_cache') {
                      return Obx(() => Padding(
                        padding: const EdgeInsets.fromLTRB(
                          SacredSpacing.marginMobile,
                          SacredSpacing.base,
                          SacredSpacing.marginMobile,
                          SacredSpacing.marginMobile,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(SacredSpacing.gutter),
                          decoration: BoxDecoration(
                            color: c.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(SacredRadius.md),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Clear Prayer Cache', style: SacredTypography.bodyMd.copyWith(color: c.textPrimary)),
                              const SizedBox(height: SacredSpacing.base),
                              Text(
                                'Removes downloaded prayer audio and transcript files only. '
                                'Listing data and app settings stay untouched.',
                                style: SacredTypography.bodySm.copyWith(color: c.textSecondary),
                              ),
                              const SizedBox(height: SacredSpacing.gutter),
                              Text(
                                'Stored Playback Cache: ${settingsController.storageUsage.value}',
                                style: SacredTypography.meta.copyWith(color: c.textSecondary),
                              ),
                              const SizedBox(height: SacredSpacing.gutter),
                              SacredButton(
                                label: settingsController.isClearingCache.value
                                    ? 'Clearing...'
                                    : 'Clear Cache',
                                fullWidth: true,
                                onPressed: settingsController.isClearingCache.value
                                    ? null
                                    : settingsController.clearPrayerCache,
                              ),
                            ],
                          ),
                        ),
                      ));
                    }
                    if (item.itemType == SettingsItemType.slider) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(SacredSpacing.marginMobile, SacredSpacing.base, SacredSpacing.marginMobile, SacredSpacing.marginMobile),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _IconLabel(asset: 'assets/icons/ic_fontsize.svg', text: item.title, c: c),
                            const SizedBox(height: SacredSpacing.base),
                            Container(
                              padding: const EdgeInsets.all(SacredSpacing.gutter),
                              decoration: BoxDecoration(
                                color: c.surfaceContainerLow.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(SacredRadius.md),
                              ),
                              child: Center(
                                child: Obx(() => Text('ੴ ਸਤਿਨਾਮੁ ਕਰਤਾ ਪੁਰਖੁ', style: SacredTypography.transcript.copyWith(color: c.textPrimary))),
                              ),
                            ),
                            const SizedBox(height: SacredSpacing.base),
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
                      iconAsset: item.iconAsset,
                      onTap: () => _handleMenuAction(context, item),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: SacredSpacing.marginMobile),
              Center(
                child: Text('Version $version', style: SacredTypography.labelSm.copyWith(color: c.textSecondary)),
              ),
              const SizedBox(height: SacredSpacing.xxl),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(SacredSpacing.xs),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: c.primaryAccent, width: 3),
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/images/settings_footer.png', width: 60, height: 60, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: SacredSpacing.md),
              Obx(() {
                final q = quoteController.quote;
                if (q.text.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SacredSpacing.xl),
                  child: Container(
                    padding: const EdgeInsets.all(SacredSpacing.gutter),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SacredRadius.md),
                      border: Border.all(color: c.primaryAccent.withValues(alpha: 0.2)),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          c.primaryAccent.withValues(alpha: 0.06),
                          c.surfaceContainerLow.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '“${q.text}”',
                          textAlign: TextAlign.center,
                          style: SacredTypography.bodyMd.copyWith(
                            color: c.primary,
                            fontStyle: FontStyle.italic,
                            height: 1.55,
                            shadows: [
                              Shadow(
                                color: c.primaryAccent.withValues(alpha: 0.35),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        if (q.author != null) ...[
                          const SizedBox(height: SacredSpacing.sm),
                          Text(
                            '— ${q.author}',
                            textAlign: TextAlign.center,
                            style: SacredTypography.meta.copyWith(
                              color: c.textSecondary.withValues(alpha: 0.7),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: SacredSpacing.lg),
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

  void _handleMenuAction(BuildContext context, DrawerMenuItem item) {
    switch (item) {
      case DrawerMenuItem.share:
        Get.find<ShareService>().shareApp(context);
        break;
      case DrawerMenuItem.support_dev:
        Get.to(() => const DeveloperSupportScreen());
        break;
      case DrawerMenuItem.notifications:
        Get.to(() => const NotificationsSettingsScreen());
        break;
      case DrawerMenuItem.feedback:
        Get.to(() => FeedbackScreen());
        break;
      case DrawerMenuItem.faq:
        Get.to(() => FaqScreen());
        break;
      case DrawerMenuItem.privacy_policy:
        launchUrl(
          Uri.parse('https://sites.google.com/view/bani-sagar-privacy-policy'),
          mode: LaunchMode.externalApplication,
        );
        break;
      default:
        break;
    }
  }
}

class _IconLabel extends StatelessWidget {
  final String asset;
  final String text;
  final SacredColors c;

  const _IconLabel({required this.asset, required this.text, required this.c});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          asset,
          width: 13,
          height: 13,
          colorFilter: ColorFilter.mode(c.textSecondary, BlendMode.srcIn),
        ),
        const SizedBox(width: 5),
        Text(text, style: SacredTypography.meta.copyWith(color: c.textSecondary)),
      ],
    );
  }
}
