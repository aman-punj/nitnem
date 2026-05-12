/// Controls which theme variant is resolved at startup.
///
/// [themeId] is the preset name ('sacred_radiance_dark').
/// [tokenOverrides] is an optional partial JSON map fetched from the server
/// (Firebase Remote Config / Firestore) to patch individual token values.
class ThemeConfig {
  const ThemeConfig({
    this.amoled = true,
    this.themeId = 'sacred_radiance_dark',
    this.tokenOverrides,
  });

  /// When true, background uses the deepest AMOLED black tier.
  final bool amoled;

  /// Identifier used to select the base token preset.
  final String themeId;

  /// Optional server-sourced overrides applied on top of the base preset.
  /// Only keys present in this map are patched; all others use preset defaults.
  /// Example server payload: { "primary": "#C084FC", "secondary": "#A855F7" }
  final Map<String, dynamic>? tokenOverrides;
}
