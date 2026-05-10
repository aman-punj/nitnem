import 'package:cloud_firestore/cloud_firestore.dart';

class AppInfoModel {
  final List<String> updateFor;
  final String updateNotes;
  final String currentVersion;
  final bool minorUpdateAvailable;
  final bool forceUpdate;
  final DateTime lastMinorUpdateTime;

  AppInfoModel({
    required this.updateFor,
    required this.updateNotes,
    required this.currentVersion,
    required this.minorUpdateAvailable,
    required this.forceUpdate,
    required this.lastMinorUpdateTime
  });

  factory AppInfoModel.fromMap(Map<String, dynamic> map) {
    return AppInfoModel(
      updateFor: List<String>.from(map['update_for'] ?? []),
      updateNotes: map['update_notes'] ?? '',
      currentVersion: map['current_version'] ?? '',
      minorUpdateAvailable: map['minor_update_available'] ?? false,
      forceUpdate: map['force_update'] ?? false,
      lastMinorUpdateTime: (map['last_minor_update_time'] as Timestamp?)?.toDate() ?? DateTime(2000),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'update_for': updateFor,
      'update_notes': updateNotes,
      'current_version': currentVersion,
      'minor_update_available': minorUpdateAvailable,
      'force_update': forceUpdate,
      'last_minor_update_time': Timestamp.fromDate(lastMinorUpdateTime),
    };
  }
}