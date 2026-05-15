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
    section: SettingsSection.appearance,
    itemType: SettingsItemType.navigation,
  ),
  language(
    id: 'language',
    title: 'Change Language',
    icon: Icons.language,
    section: SettingsSection.appearance,
    itemType: SettingsItemType.navigation,
  ),
  typography(
    id: 'typography',
    title: 'Reading Size',
    icon: Icons.format_size,
    section: SettingsSection.appearance,
    itemType: SettingsItemType.slider,
  ),
  notifications(
    id: 'notifications',
    title: 'Notifications',
    icon: Icons.notifications,
    section: SettingsSection.notifications,
    itemType: SettingsItemType.navigation,
  ),
  clear_cache(
    id: 'clear_cache',
    title: 'Clear Cache',
    icon: Icons.delete_outline,
    section: SettingsSection.storage,
    itemType: SettingsItemType.action,
  ),
  keep_awake(
    id: 'keep_awake',
    title: 'Keep Screen Awake',
    icon: Icons.visibility,
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
  feedback(
    id: 'feedback',
    title: 'Feedback',
    icon: Icons.feedback,
    section: SettingsSection.support,
    itemType: SettingsItemType.navigation,
  ),
  faq(
    id: 'faq',
    title: 'FAQ',
    icon: Icons.help_outline,
    section: SettingsSection.support,
    itemType: SettingsItemType.navigation,
  ),
  privacy_policy(
    id: 'privacy_policy',
    title: 'Privacy Policy',
    icon: Icons.privacy_tip,
    section: SettingsSection.support,
    itemType: SettingsItemType.navigation,
  );

  final String id;
  final String title;
  final IconData icon;
  final SettingsSection section;
  final SettingsItemType itemType;

  const DrawerMenuItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.section,
    required this.itemType,
  });
}