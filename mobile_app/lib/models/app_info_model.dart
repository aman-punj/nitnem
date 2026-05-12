class VersionControlConfig {
  final int latestBuild;
  final int minimumSupportedBuild;
  final String latestVersionName;
  final bool forceUpdate;
  final String updateMessage;
  final String androidStoreUrl;
  final String iosStoreUrl;

  const VersionControlConfig({
    required this.latestBuild,
    required this.minimumSupportedBuild,
    required this.latestVersionName,
    required this.forceUpdate,
    required this.updateMessage,
    required this.androidStoreUrl,
    required this.iosStoreUrl,
  });

  factory VersionControlConfig.fromMap(Map<String, dynamic> map) {
    return VersionControlConfig(
      latestBuild: (map['latestBuild'] ?? 0) as int,
      minimumSupportedBuild: (map['minimumSupportedBuild'] ?? 0) as int,
      latestVersionName: (map['latestVersionName'] ?? '') as String,
      forceUpdate: (map['forceUpdate'] ?? false) as bool,
      updateMessage: (map['updateMessage'] ?? '') as String,
      androidStoreUrl: (map['androidStoreUrl'] ?? '') as String,
      iosStoreUrl: (map['iosStoreUrl'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latestBuild': latestBuild,
      'minimumSupportedBuild': minimumSupportedBuild,
      'latestVersionName': latestVersionName,
      'forceUpdate': forceUpdate,
      'updateMessage': updateMessage,
      'androidStoreUrl': androidStoreUrl,
      'iosStoreUrl': iosStoreUrl,
    };
  }
}

class MaintenanceConfig {
  final bool isUnderMaintenance;
  final String maintenanceMessage;

  const MaintenanceConfig({
    required this.isUnderMaintenance,
    required this.maintenanceMessage,
  });

  factory MaintenanceConfig.fromMap(Map<String, dynamic> map) {
    return MaintenanceConfig(
      isUnderMaintenance: (map['isUnderMaintenance'] ?? false) as bool,
      maintenanceMessage: (map['maintenanceMessage'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isUnderMaintenance': isUnderMaintenance,
      'maintenanceMessage': maintenanceMessage,
    };
  }
}

class LanguageFlags {
  final bool punjabi;
  final bool english;
  final bool hindi;

  const LanguageFlags({
    required this.punjabi,
    required this.english,
    required this.hindi,
  });

  factory LanguageFlags.fromMap(Map<String, dynamic> map) {
    return LanguageFlags(
      punjabi: (map['punjabi'] ?? false) as bool,
      english: (map['english'] ?? false) as bool,
      hindi: (map['hindi'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'punjabi': punjabi,
      'english': english,
      'hindi': hindi,
    };
  }
}

class FeatureFlagsConfig {
  final LanguageFlags languages;
  final bool focusReadingMode;
  final bool newPlayerUi;
  final bool experimentalHome;

  const FeatureFlagsConfig({
    required this.languages,
    required this.focusReadingMode,
    required this.newPlayerUi,
    required this.experimentalHome,
  });

  factory FeatureFlagsConfig.fromMap(Map<String, dynamic> map) {
    return FeatureFlagsConfig(
      languages: LanguageFlags.fromMap(map['languages'] as Map<String, dynamic>? ?? {}),
      focusReadingMode: (map['focus_reading_mode'] ?? false) as bool,
      newPlayerUi: (map['new_player_ui'] ?? false) as bool,
      experimentalHome: (map['experimental_home'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'languages': languages.toMap(),
      'focus_reading_mode': focusReadingMode,
      'new_player_ui': newPlayerUi,
      'experimental_home': experimentalHome,
    };
  }
}

class AppInfoModel {
  final String appName;
  final String environment;
  final VersionControlConfig versionControl;
  final MaintenanceConfig maintenance;
  final FeatureFlagsConfig featureFlags;

  const AppInfoModel({
    required this.appName,
    required this.environment,
    required this.versionControl,
    required this.maintenance,
    required this.featureFlags,
  });

  factory AppInfoModel.fromMap(Map<String, dynamic> map) {
    return AppInfoModel(
      appName: (map['appName'] ?? '') as String,
      environment: (map['environment'] ?? 'Production') as String,
      versionControl: VersionControlConfig.fromMap(
          map['versionControl'] as Map<String, dynamic>? ?? {}),
      maintenance: MaintenanceConfig.fromMap(
          map['maintenance'] as Map<String, dynamic>? ?? {}),
      featureFlags: FeatureFlagsConfig.fromMap(
          map['featureFlags'] as Map<String, dynamic>? ?? {}),
    );
  }

  bool shouldForceUpdate(int currentBuild) {
    return versionControl.forceUpdate ||
        currentBuild < versionControl.minimumSupportedBuild;
  }

  bool shouldRecommendUpdate(int currentBuild) {
    return currentBuild < versionControl.latestBuild &&
        !shouldForceUpdate(currentBuild);
  }

   Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'environment': environment,
      'versionControl': versionControl.toMap(),
      'maintenance': maintenance.toMap(),
      'featureFlags': featureFlags.toMap(),
    };
  }
}
