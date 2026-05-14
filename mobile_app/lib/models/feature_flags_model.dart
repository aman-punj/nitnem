class FeatureFlags {
  final bool focusReading;
  final bool englishLanguage;
  final bool newPlayerUi;

  const FeatureFlags({
    required this.focusReading,
    required this.englishLanguage,
    required this.newPlayerUi,
  });

  factory FeatureFlags.fromMap(Map<String, dynamic> map) {
    return FeatureFlags(
      focusReading: map['focusReading'] ?? false,
      englishLanguage: map['englishLanguage'] ?? false,
      newPlayerUi: map['newPlayerUi'] ?? false,
    );
  }
}
