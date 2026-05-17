import 'package:flutter/material.dart';

/// The single source of truth for all design tokens.
///
/// Can be constructed from a JSON map — enabling server-driven theming via
/// Firebase Remote Config or Firestore without an app update.
///
/// Usage:
///   final tokens = AppTokens.sacredRadianceDark();           // default
///   final tokens = AppTokens.sacredRadianceDark()            // server override
///       .mergeFromJson(remoteConfigMap);
@immutable
class AppTokens {
  const AppTokens({
    // Colors
    required this.background,
    required this.surface,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.outline,
    required this.outlineVariant,
    required this.surfaceTint,
    required this.error,
    required this.onError,
    required this.borderSoft,
    // Spacing
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.spaceXl,
    required this.spaceGutter,
    required this.spaceMarginMobile,
    // Radius
    required this.radiusSm,
    required this.radiusDef,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
  });

  // ─── Colors ────────────────────────────────────────────────────────────────
  final Color background;
  final Color surface;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color outline;
  final Color outlineVariant;
  final Color surfaceTint;
  final Color error;
  final Color onError;
  final Color borderSoft;

  // ─── Spacing ───────────────────────────────────────────────────────────────
  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;
  final double spaceGutter;
  final double spaceMarginMobile;

  // ─── Radius ────────────────────────────────────────────────────────────────
  final double radiusSm;
  final double radiusDef;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;

  // ─── Derived convenience getters ──────────────────────────────────────────
  /// Gold outer glow for "sacred" / active elements.
  Color get focusGlow     => primary.withValues(alpha: 0.15);
  /// Subtle gold border for cards and tiles.
  Color get borderGold    => primary.withValues(alpha: 0.25);
  /// Fading golden gradient divider color.
  Color get dividerGold   => primary.withValues(alpha: 0.20);

  // ─── Built-in theme presets ───────────────────────────────────────────────

  /// Default dark theme — Sacred Radiance palette.
  factory AppTokens.sacredRadianceDark() {
    return const AppTokens(
      // Colors — from DESIGN.md frontmatter
      background:               Color(0xFF131313),
      surface:                  Color(0xFF131313),
      surfaceContainerLowest:   Color(0xFF0E0E0E),
      surfaceContainerLow:      Color(0xFF1C1B1B),
      surfaceContainer:         Color(0xFF201F1F),
      surfaceContainerHigh:     Color(0xFF2A2A2A),
      surfaceContainerHighest:  Color(0xFF353534),
      onSurface:                Color(0xFFE5E2E1),
      onSurfaceVariant:         Color(0xFFD0C5AF),
      primary:                  Color(0xFFF2CA50),
      onPrimary:                Color(0xFF3C2F00),
      primaryContainer:         Color(0xFFD4AF37),
      onPrimaryContainer:       Color(0xFF554300),
      secondary:                Color(0xFFF0C12C),
      onSecondary:              Color(0xFF3D2E00),
      outline:                  Color(0xFF99907C),
      outlineVariant:           Color(0xFF4D4635),
      surfaceTint:              Color(0xFFE9C349),
      error:                    Color(0xFFFFB4AB),
      onError:                  Color(0xFF690005),
      borderSoft:               Color(0x1AFFFFFF), // 10% white — dark surfaces only
      // Spacing
      spaceXs:           4,
      spaceSm:           12,
      spaceMd:           24,
      spaceLg:           48,
      spaceXl:           64,
      spaceGutter:       16,
      spaceMarginMobile: 20,
      // Radius
      radiusSm:  4,
      radiusDef: 8,
      radiusMd:  12,
      radiusLg:  16,
      radiusXl:  24,
    );
  }

  /// Light theme — warm parchment palette. Easily adjustable when design is finalised.
 factory AppTokens.sacredRadianceLight() {
  return const AppTokens(
    // Warm parchment backgrounds
    background:               Color(0xFFF7F3EC),
    surface:                  Color(0xFFF7F3EC),
    surfaceContainerLowest:   Color(0xFFF2EDE3),
    surfaceContainerLow:      Color(0xFFEDE6D8),
    surfaceContainer:         Color(0xFFE8DFD0),
    surfaceContainerHigh:     Color(0xFFDED4C2),
    surfaceContainerHighest:  Color(0xFFD4C9B4),

    // Text — deep warm brown, not harsh black
    onSurface:                Color(0xFF1E1408),
    onSurfaceVariant:         Color(0xFF5C4A2A),

    // Gold — darkened enough to be readable on light bg (4.5:1 contrast)
    primary:                  Color(0xFFA07800),
    onPrimary:                Color(0xFFFFFFFF),
    primaryContainer:         Color(0xFFFFF0C2),
    onPrimaryContainer:       Color(0xFF3A2800),

    secondary:                Color(0xFF8A6600),
    onSecondary:              Color(0xFFFFFFFF),

    // Borders
    outline:                  Color(0xFF9C8A6A),
    outlineVariant:           Color(0xFFCFC0A0),

    surfaceTint:              Color(0xFFA07800),
    error:                    Color(0xFFBA1A1A),
    onError:                  Color(0xFFFFFFFF),
    borderSoft:               Color(0x14B8A890), // 8% warm tan — light surfaces

    // Spacing — same
    spaceXs:           4,
    spaceSm:           12,
    spaceMd:           24,
    spaceLg:           48,
    spaceXl:           64,
    spaceGutter:       16,
    spaceMarginMobile: 20,

    // Radius — same
    radiusSm:  4,
    radiusDef: 8,
    radiusMd:  12,
    radiusLg:  16,
    radiusXl:  24,
  );
}
  // ─── JSON support ─────────────────────────────────────────────────────────

  /// Construct tokens entirely from a JSON map (all fields required).
  factory AppTokens.fromJson(Map<String, dynamic> json) {
    return AppTokens(
      background:               _c(json['background']),
      surface:                  _c(json['surface']),
      surfaceContainerLowest:   _c(json['surfaceContainerLowest']),
      surfaceContainerLow:      _c(json['surfaceContainerLow']),
      surfaceContainer:         _c(json['surfaceContainer']),
      surfaceContainerHigh:     _c(json['surfaceContainerHigh']),
      surfaceContainerHighest:  _c(json['surfaceContainerHighest']),
      onSurface:                _c(json['onSurface']),
      onSurfaceVariant:         _c(json['onSurfaceVariant']),
      primary:                  _c(json['primary']),
      onPrimary:                _c(json['onPrimary']),
      primaryContainer:         _c(json['primaryContainer']),
      onPrimaryContainer:       _c(json['onPrimaryContainer']),
      secondary:                _c(json['secondary']),
      onSecondary:              _c(json['onSecondary']),
      outline:                  _c(json['outline']),
      outlineVariant:           _c(json['outlineVariant']),
      surfaceTint:              _c(json['surfaceTint']),
      error:                    _c(json['error']),
      onError:                  _c(json['onError']),
      borderSoft:               json.containsKey('borderSoft') ? _c(json['borderSoft']) : const Color(0x1AFFFFFF),
      spaceXs:           (json['spaceXs'] as num).toDouble(),
      spaceSm:           (json['spaceSm'] as num).toDouble(),
      spaceMd:           (json['spaceMd'] as num).toDouble(),
      spaceLg:           (json['spaceLg'] as num).toDouble(),
      spaceXl:           (json['spaceXl'] as num).toDouble(),
      spaceGutter:       (json['spaceGutter'] as num).toDouble(),
      spaceMarginMobile: (json['spaceMarginMobile'] as num).toDouble(),
      radiusSm:  (json['radiusSm'] as num).toDouble(),
      radiusDef: (json['radiusDef'] as num).toDouble(),
      radiusMd:  (json['radiusMd'] as num).toDouble(),
      radiusLg:  (json['radiusLg'] as num).toDouble(),
      radiusXl:  (json['radiusXl'] as num).toDouble(),
    );
  }

  /// Apply a partial JSON override on top of this token set.
  /// Only fields present in [overrides] are changed.
  AppTokens mergeFromJson(Map<String, dynamic> overrides) {
    return AppTokens(
      background:               overrides.containsKey('background')              ? _c(overrides['background'])              : background,
      surface:                  overrides.containsKey('surface')                 ? _c(overrides['surface'])                 : surface,
      surfaceContainerLowest:   overrides.containsKey('surfaceContainerLowest')  ? _c(overrides['surfaceContainerLowest'])  : surfaceContainerLowest,
      surfaceContainerLow:      overrides.containsKey('surfaceContainerLow')     ? _c(overrides['surfaceContainerLow'])     : surfaceContainerLow,
      surfaceContainer:         overrides.containsKey('surfaceContainer')        ? _c(overrides['surfaceContainer'])        : surfaceContainer,
      surfaceContainerHigh:     overrides.containsKey('surfaceContainerHigh')    ? _c(overrides['surfaceContainerHigh'])    : surfaceContainerHigh,
      surfaceContainerHighest:  overrides.containsKey('surfaceContainerHighest') ? _c(overrides['surfaceContainerHighest']) : surfaceContainerHighest,
      onSurface:                overrides.containsKey('onSurface')               ? _c(overrides['onSurface'])               : onSurface,
      onSurfaceVariant:         overrides.containsKey('onSurfaceVariant')        ? _c(overrides['onSurfaceVariant'])        : onSurfaceVariant,
      primary:                  overrides.containsKey('primary')                 ? _c(overrides['primary'])                 : primary,
      onPrimary:                overrides.containsKey('onPrimary')               ? _c(overrides['onPrimary'])               : onPrimary,
      primaryContainer:         overrides.containsKey('primaryContainer')        ? _c(overrides['primaryContainer'])        : primaryContainer,
      onPrimaryContainer:       overrides.containsKey('onPrimaryContainer')      ? _c(overrides['onPrimaryContainer'])      : onPrimaryContainer,
      secondary:                overrides.containsKey('secondary')               ? _c(overrides['secondary'])               : secondary,
      onSecondary:              overrides.containsKey('onSecondary')             ? _c(overrides['onSecondary'])             : onSecondary,
      outline:                  overrides.containsKey('outline')                 ? _c(overrides['outline'])                 : outline,
      outlineVariant:           overrides.containsKey('outlineVariant')          ? _c(overrides['outlineVariant'])          : outlineVariant,
      surfaceTint:              overrides.containsKey('surfaceTint')             ? _c(overrides['surfaceTint'])             : surfaceTint,
      error:                    overrides.containsKey('error')                   ? _c(overrides['error'])                   : error,
      onError:                  overrides.containsKey('onError')                 ? _c(overrides['onError'])                 : onError,
      borderSoft:               overrides.containsKey('borderSoft')              ? _c(overrides['borderSoft'])              : borderSoft,
      spaceXs:           _d(overrides, 'spaceXs',           spaceXs),
      spaceSm:           _d(overrides, 'spaceSm',           spaceSm),
      spaceMd:           _d(overrides, 'spaceMd',           spaceMd),
      spaceLg:           _d(overrides, 'spaceLg',           spaceLg),
      spaceXl:           _d(overrides, 'spaceXl',           spaceXl),
      spaceGutter:       _d(overrides, 'spaceGutter',       spaceGutter),
      spaceMarginMobile: _d(overrides, 'spaceMarginMobile', spaceMarginMobile),
      radiusSm:  _d(overrides, 'radiusSm',  radiusSm),
      radiusDef: _d(overrides, 'radiusDef', radiusDef),
      radiusMd:  _d(overrides, 'radiusMd',  radiusMd),
      radiusLg:  _d(overrides, 'radiusLg',  radiusLg),
      radiusXl:  _d(overrides, 'radiusXl',  radiusXl),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Parse a hex string like '#F2CA50' or 'F2CA50' into a [Color].
  static Color _c(dynamic hex) {
    final str = (hex as String).replaceAll('#', '');
    return Color(int.parse('FF$str', radix: 16));
  }

  static double _d(Map<String, dynamic> map, String key, double fallback) {
    return map.containsKey(key) ? (map[key] as num).toDouble() : fallback;
  }
}
