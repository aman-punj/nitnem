import 'package:flutter/material.dart';

enum PreferenceModuleType {
  navigation,
  toggle,
  action,
  externalLink,
  bottomSheet,
  dialog,
  slider;

  static PreferenceModuleType fromString(String value) {
    return PreferenceModuleType.values.firstWhere(
      (e) => e.name == value || _toSnakeCase(e.name) == value,
      orElse: () => PreferenceModuleType.navigation,
    );
  }

  static String _toSnakeCase(String text) {
    return text.replaceAllMapped(RegExp(r'([A-Z])'), (match) => '_${match.group(1)!.toLowerCase()}');
  }
}

class PreferenceModule {
  final String id;
  final bool enabled;
  final int order;
  final String title;
  final String description;
  final String icon;
  final PreferenceModuleType type;
  final String event;

  const PreferenceModule({
    required this.id,
    required this.enabled,
    required this.order,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.event,
  });

  factory PreferenceModule.fromFirestore(Map<String, dynamic> data, String id) {
    return PreferenceModule(
      id: id,
      enabled: data['enabled'] ?? true,
      order: data['order'] ?? 0,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? 'settings',
      type: PreferenceModuleType.fromString(data['type'] ?? 'navigation'),
      event: data['event'] ?? '',
    );
  }
}
