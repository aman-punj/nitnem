import 'package:flutter/material.dart';

/// Sacred Radiance color tokens — sourced from DESIGN.md frontmatter.
/// Legacy names are kept as aliases so existing widgets compile unchanged.
/// Phase 3 will migrate widgets to use these canonical names directly.
class SacredColors {
  SacredColors._();

  // ─── Background / Surface tiers ──────────────────────────────────────────
  /// Deepest AMOLED black — used for true "ink" moments.
  static const Color surfaceContainerLowest  = Color(0xFF0E0E0E);
  /// Base app background — slightly warmer than pure black.
  static const Color background              = Color(0xFF131313);
  /// Low-elevation container (list rows, input bg).
  static const Color surfaceContainerLow     = Color(0xFF1C1B1B);
  /// Mid-elevation container (cards, menus).
  static const Color surfaceContainer        = Color(0xFF201F1F);
  /// High-elevation container (sheets, overlays).
  static const Color surfaceContainerHigh    = Color(0xFF2A2A2A);
  /// Highest-elevation container (dialogs).
  static const Color surfaceContainerHighest = Color(0xFF353534);
  /// Slightly lighter surface for bright variants.
  static const Color surfaceBright           = Color(0xFF3A3939);

  // ─── Legacy aliases (mapped to canonical names above) ────────────────────
  static const Color backgroundBlack   = surfaceContainerLowest;
  static const Color backgroundDeep    = background;
  static const Color backgroundDark    = surfaceContainerLow;
  static const Color backgroundMuted   = surfaceContainer;
  static const Color backgroundPrimary = background;
  static const Color surfacePrimary    = surfaceContainer;
  static const Color surfaceSecondary  = surfaceContainerHigh;
  static const Color surfaceTertiary   = surfaceContainerHighest;

  // ─── Gold accent palette ─────────────────────────────────────────────────
  /// Primary gold — luminous, used for active states and key icons.
  static const Color primary          = Color(0xFFF2CA50);
  /// Dark brown — text/icons on gold surfaces (high contrast).
  static const Color onPrimary        = Color(0xFF3C2F00);
  /// Deeper gold — container backgrounds, e.g. badges.
  static const Color primaryContainer = Color(0xFFD4AF37);
  /// Dark amber — text on primaryContainer.
  static const Color onPrimaryContainer = Color(0xFF554300);
  /// Secondary accent gold — use sparingly for highlights.
  static const Color secondary        = Color(0xFFF0C12C);
  static const Color onSecondary      = Color(0xFF3D2E00);
  /// Surface tint (used by Material 3 elevation tinting).
  static const Color surfaceTint      = Color(0xFFE9C349);

  // Legacy accent aliases
  static const Color primaryAccent = primary;
  static const Color accentSoft    = secondary;

  // ─── Text ─────────────────────────────────────────────────────────────────
  /// Primary reading text — warm off-white.
  static const Color textPrimary   = Color(0xFFE5E2E1); // onSurface
  /// Secondary / meta text — muted golden-grey.
  static const Color textSecondary = Color(0xFFD0C5AF); // onSurfaceVariant

  // ─── Outlines ─────────────────────────────────────────────────────────────
  static const Color outline        = Color(0xFF99907C);
  static const Color outlineVariant = Color(0xFF4D4635);

  // ─── Interactive / state ──────────────────────────────────────────────────
  /// Subtle gold tint for highlighted transcript lines.
  static const Color focusedLine  = Color(0x26F2CA50); // gold @ 15 %
  /// Golden glow for playback head / active states.
  static const Color playbackGlow = Color(0x26F2CA50); // gold @ 15 %
  /// Faint white border for low-emphasis containers.
  static const Color borderSoft   = Color(0x1AFFFFFF); // white @ 10 %
  /// Subtle gold border for cards / tiles.
  static const Color borderGold   = Color(0x40F2CA50); // gold @ 25 %

  // ─── Error ────────────────────────────────────────────────────────────────
  static const Color error          = Color(0xFFFFB4AB);
  static const Color onError        = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
}
