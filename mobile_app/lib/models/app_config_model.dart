class AppConfig {
  final Versions versions;
  final Messages messages;
  final Maintenance maintenance;
  final StoreUrl storeUrl;

  const AppConfig({
    required this.versions,
    required this.messages,
    required this.maintenance,
    required this.storeUrl,
  });

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      versions: Versions.fromMap(map['versions'] ?? {}),
      messages: Messages.fromMap(map['messages'] ?? {}),
      maintenance: Maintenance.fromMap(map['maintenance'] ?? {}),
      storeUrl: StoreUrl.fromMap(map['storeUrl'] ?? {}),
    );
  }
}

class Versions {
  final int latest;
  final int? minorUpdate;
  final int? forceUpdate;

  const Versions({
    required this.latest,
    this.minorUpdate,
    this.forceUpdate,
  });

  factory Versions.fromMap(Map<String, dynamic> map) {
    return Versions(
      latest: (map['latest'] ?? 0) as int,
      minorUpdate: map['minorUpdate'] as int?,
      forceUpdate: map['forceUpdate'] as int?,
    );
  }
}

class Messages {
  final UpdateMessage? minorUpdate;
  final UpdateMessage? forceUpdate;
  final UpdateMessage? maintenance;

  const Messages({
    this.minorUpdate,
    this.forceUpdate,
    this.maintenance,
  });

  factory Messages.fromMap(Map<String, dynamic> map) {
    return Messages(
      minorUpdate: map['minorUpdate'] != null ? UpdateMessage.fromMap(map['minorUpdate']) : null,
      forceUpdate: map['forceUpdate'] != null ? UpdateMessage.fromMap(map['forceUpdate']) : null,
      maintenance: map['maintenance'] != null ? UpdateMessage.fromMap(map['maintenance']) : null,
    );
  }
}

class UpdateMessage {
  final String title;
  final String body;
  final String primaryButton;
  final String? secondaryButton;

  const UpdateMessage({
    required this.title,
    required this.body,
    required this.primaryButton,
    this.secondaryButton,
  });

  factory UpdateMessage.fromMap(Map<String, dynamic> map) {
    return UpdateMessage(
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      primaryButton: map['primaryButton'] ?? '',
      secondaryButton: map['secondaryButton'] as String?,
    );
  }
}

class Maintenance {
  final bool enabled;

  const Maintenance({
    required this.enabled,
  });

  factory Maintenance.fromMap(Map<String, dynamic> map) {
    return Maintenance(
      enabled: map['enabled'] ?? false,
    );
  }
}

class StoreUrl {
  final String android;
  final String ios;

  const StoreUrl({
    required this.android,
    required this.ios,
  });

  factory StoreUrl.fromMap(Map<String, dynamic> map) {
    return StoreUrl(
      android: (map['android'] ?? '') as String,
      ios: (map['ios'] ?? '') as String,
    );
  }
}
