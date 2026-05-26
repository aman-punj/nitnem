import 'package:flutter/material.dart';

enum SettingsSection {
  appearance,
  notifications,
  storage,
  experience,
  support,
}

enum SettingsItemType {
  navigation,
  toggle,
  segmented,
  slider,
  action,
}

enum DrawerMenuItem {
  theme(
    id: 'theme',
    title: 'Theme',
    icon: Icons.palette,
    iconAsset: 'assets/icons/ic_theme.svg',
    section: SettingsSection.appearance,
    itemType: SettingsItemType.navigation,
  ),
  language(
    id: 'language',
    title: 'Change Language',
    icon: Icons.language,
    iconAsset: 'assets/icons/ic_language.svg',
    section: SettingsSection.appearance,
    itemType: SettingsItemType.navigation,
  ),
  typography(
    id: 'typography',
    title: 'Reading Size',
    icon: Icons.format_size,
    iconAsset: 'assets/icons/ic_fontsize.svg',
    section: SettingsSection.appearance,
    itemType: SettingsItemType.slider,
  ),
  notifications(
    id: 'notifications',
    title: 'Notifications',
    icon: Icons.notifications,
    iconAsset: 'assets/icons/ic_bell.svg',
    section: SettingsSection.notifications,
    itemType: SettingsItemType.navigation,
  ),
  clear_cache(
    id: 'clear_cache',
    title: 'Clear Cache',
    icon: Icons.delete_outline,
    iconAsset: 'assets/icons/ic_storage.svg',
    section: SettingsSection.storage,
    itemType: SettingsItemType.action,
  ),
  keep_awake(
    id: 'keep_awake',
    title: 'Keep Screen Awake',
    icon: Icons.visibility,
    iconAsset: 'assets/icons/ic_lock.svg',
    section: SettingsSection.experience,
    itemType: SettingsItemType.toggle,
  ),
  share(
    id: 'share',
    title: 'Share App',
    icon: Icons.share,
    section: SettingsSection.support,
    itemType: SettingsItemType.action,
  ),
  support_dev(
    id: 'support_dev',
    title: 'Support Development',
    icon: Icons.volunteer_activism,
    section: SettingsSection.support,
    itemType: SettingsItemType.navigation,
  ),
  feedback(
    id: 'feedback',
    title: 'Feedback',
    icon: Icons.feedback,
    iconAsset: 'assets/icons/ic_quote.svg',
    section: SettingsSection.support,
    itemType: SettingsItemType.navigation,
  ),
  faq(
    id: 'faq',
    title: 'FAQ',
    icon: Icons.help_outline,
    iconAsset: 'assets/icons/ic_faq.svg',
    section: SettingsSection.support,
    itemType: SettingsItemType.navigation,
  ),
  privacy_policy(
    id: 'privacy_policy',
    title: 'Privacy Policy',
    icon: Icons.privacy_tip,
    iconAsset: 'assets/icons/ic_hukamnama.svg',
    section: SettingsSection.support,
    itemType: SettingsItemType.navigation,
  );

  final String id;
  final String title;
  final IconData icon;
  final String? iconAsset;
  final SettingsSection section;
  final SettingsItemType itemType;

  const DrawerMenuItem({
    required this.id,
    required this.title,
    required this.icon,
    this.iconAsset,
    required this.section,
    required this.itemType,
  });
}