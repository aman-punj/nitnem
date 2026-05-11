class AppInfoModel {
  final int latestBuild;
  final int minimumSupportedBuild;
  final bool forceUpdate;
  final String updateMessage;

  const AppInfoModel({
    required this.latestBuild,
    required this.minimumSupportedBuild,
    required this.forceUpdate,
    required this.updateMessage,
  });

  factory AppInfoModel.fromMap(Map<String, dynamic> map) {
    return AppInfoModel(
      latestBuild: (map['latestBuild'] ?? map['latest_build'] ?? 0) as int,
      minimumSupportedBuild: (map['minimumSupportedBuild'] ?? map['minimum_supported_build'] ?? 0) as int,
      forceUpdate: (map['forceUpdate'] ?? map['force_update'] ?? false) as bool,
      updateMessage: (map['updateMessage'] ?? map['update_notes'] ?? '') as String,
    );
  }

  bool shouldForceUpdate(int currentBuild) {
    return forceUpdate || currentBuild < minimumSupportedBuild;
  }

  bool shouldRecommendUpdate(int currentBuild) {
    return currentBuild < latestBuild && !shouldForceUpdate(currentBuild);
  }

  Map<String, dynamic> toMap() {
    return {
      'latestBuild': latestBuild,
      'minimumSupportedBuild': minimumSupportedBuild,
      'forceUpdate': forceUpdate,
      'updateMessage': updateMessage,
    };
  }
}
