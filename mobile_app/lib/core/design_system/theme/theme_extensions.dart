import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../models/app_tokens.dart';

/// A [ThemeExtension] that exposes Sacred Radiance tokens not covered by
/// Flutter's standard [ColorScheme].
///
/// Access in widgets:
///   `Theme.of(context).extension<SacredPalette>()!`
@immutable
class SacredPalette extends ThemeExtension<SacredPalette> {
  const SacredPalette({
    // Surface tier colours (supplement ColorScheme.surface)
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    // Interactive/state colours
    required this.focusGlow,
    required this.borderGold,
    required this.borderSoft,
    required this.dividerGold,
    // Spacing shortcuts used by widgets
    required this.spaceGutter,
    required this.spaceMarginMobile,
    // Radius shortcuts
    required this.radiusCard,
    required this.radiusBtn,
    required this.radiusTile,
    required this.radiusSm,
  });

  // ─── Surface tiers ────────────────────────────────────────────────────────
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;

  // ─── Interactive state ────────────────────────────────────────────────────
  /// Outer glow for active / "now reading" elements.
  final Color focusGlow;
  /// Subtle gold border for cards and tiles.
  final Color borderGold;
  /// Faint white border for very low-emphasis containers.
  final Color borderSoft;
  /// Color for fading golden gradient dividers.
  final Color dividerGold;

  // ─── Spacing ──────────────────────────────────────────────────────────────
  final double spaceGutter;
  final double spaceMarginMobile;

  // ─── Radius ───────────────────────────────────────────────────────────────
  /// For feature / hero cards — xl (24 px).
  final double radiusCard;
  /// For buttons and inputs — default (8 px).
  final double radiusBtn;
  /// For standard list tiles and small cards — lg (16 px).
  final double radiusTile;
  /// For small chips and badges — sm (4 px).
  final double radiusSm;

  // ─── Factory ──────────────────────────────────────────────────────────────

  factory SacredPalette.fromTokens(AppTokens t) {
    return SacredPalette(
      surfaceContainerLowest:  t.surfaceContainerLowest,
      surfaceContainerLow:     t.surfaceContainerLow,
      surfaceContainer:        t.surfaceContainer,
      surfaceContainerHigh:    t.surfaceContainerHigh,
      surfaceContainerHighest: t.surfaceContainerHighest,
      focusGlow:         t.focusGlow,
      borderGold:        t.borderGold,
      borderSoft:        t.borderSoft,
      dividerGold:       t.dividerGold,
      spaceGutter:       t.spaceGutter,
      spaceMarginMobile: t.spaceMarginMobile,
      radiusCard: t.radiusXl,
      radiusBtn:  t.radiusDef,
      radiusTile: t.radiusLg,
      radiusSm:   t.radiusSm,
    );
  }

  // ─── ThemeExtension boilerplate ──────────────────────────────────────────

  @override
  SacredPalette copyWith({
    Color? surfaceContainerLowest,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? focusGlow,
    Color? borderGold,
    Color? borderSoft,
    Color? dividerGold,
    double? spaceGutter,
    double? spaceMarginMobile,
    double? radiusCard,
    double? radiusBtn,
    double? radiusTile,
    double? radiusSm,
  }) {
    return SacredPalette(
      surfaceContainerLowest:  surfaceContainerLowest  ?? this.surfaceContainerLowest,
      surfaceContainerLow:     surfaceContainerLow     ?? this.surfaceContainerLow,
      surfaceContainer:        surfaceContainer        ?? this.surfaceContainer,
      surfaceContainerHigh:    surfaceContainerHigh    ?? this.surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest ?? this.surfaceContainerHighest,
      focusGlow:         focusGlow         ?? this.focusGlow,
      borderGold:        borderGold        ?? this.borderGold,
      borderSoft:        borderSoft        ?? this.borderSoft,
      dividerGold:       dividerGold       ?? this.dividerGold,
      spaceGutter:       spaceGutter       ?? this.spaceGutter,
      spaceMarginMobile: spaceMarginMobile ?? this.spaceMarginMobile,
      radiusCard: radiusCard ?? this.radiusCard,
      radiusBtn:  radiusBtn  ?? this.radiusBtn,
      radiusTile: radiusTile ?? this.radiusTile,
      radiusSm:   radiusSm   ?? this.radiusSm,
    );
  }

  @override
  SacredPalette lerp(covariant SacredPalette? other, double t) {
    if (other == null) return this;
    return SacredPalette(
      surfaceContainerLowest:  Color.lerp(surfaceContainerLowest,  other.surfaceContainerLowest,  t)!,
      surfaceContainerLow:     Color.lerp(surfaceContainerLow,     other.surfaceContainerLow,     t)!,
      surfaceContainer:        Color.lerp(surfaceContainer,        other.surfaceContainer,        t)!,
      surfaceContainerHigh:    Color.lerp(surfaceContainerHigh,    other.surfaceContainerHigh,    t)!,
      surfaceContainerHighest: Color.lerp(surfaceContainerHighest, other.surfaceContainerHighest, t)!,
      focusGlow:         Color.lerp(focusGlow,   other.focusGlow,   t)!,
      borderGold:        Color.lerp(borderGold,  other.borderGold,  t)!,
      borderSoft:        Color.lerp(borderSoft,  other.borderSoft,  t)!,
      dividerGold:       Color.lerp(dividerGold, other.dividerGold, t)!,
      spaceGutter:       lerpDouble(spaceGutter,       other.spaceGutter,       t)!,
      spaceMarginMobile: lerpDouble(spaceMarginMobile, other.spaceMarginMobile, t)!,
      radiusCard: lerpDouble(radiusCard, other.radiusCard, t)!,
      radiusBtn:  lerpDouble(radiusBtn,  other.radiusBtn,  t)!,
      radiusTile: lerpDouble(radiusTile, other.radiusTile, t)!,
      radiusSm:   lerpDouble(radiusSm,   other.radiusSm,   t)!,
    );
  }
}
