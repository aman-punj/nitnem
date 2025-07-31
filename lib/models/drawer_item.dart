import 'package:flutter/material.dart';

class DrawerItem {
  final String title;
  final IconData icon;
  final String id;

  const DrawerItem({required this.title, required this.icon, required this.id});
}

const List<DrawerItem> drawerItems = [
  DrawerItem(title: 'Change Language', icon: Icons.language, id: 'language'),
  DrawerItem(title: 'Share App', icon: Icons.share, id: 'share'),
  DrawerItem(title: 'Feedback', icon: Icons.feedback, id: 'feedback'),
  DrawerItem(title: 'Rate Us', icon: Icons.star_rate, id: 'rate'),
  // DrawerItem(title: 'Privacy Policy', icon: Icons.privacy_tip, id: 'privacy'),
  // DrawerItem(title: 'About App', icon: Icons.info_outline, id: 'about'),
  DrawerItem(title: 'Exit', icon: Icons.exit_to_app, id: 'exit'),
];