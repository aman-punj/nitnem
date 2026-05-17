import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';

/// Context-resolved Sacred Radiance colors.
///
/// Add `final c = SacredColors.of(context);` at the top of any build method,
/// then use `c.textPrimary`, `c.primaryAccent`, etc. — all names match the
/// old static constants so the diff in each widget is minimal.
class SacredColors {
  const SacredColors._({
    required this.background,
    required this.backgroundPrimary,
    required this.backgroundBlack,
    required this.backgroundDeep,
    required this.backgroundDark,
    required this.backgroundMuted,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.surfaceBright,
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.surfaceTertiary,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.surfaceTint,
    required this.primaryAccent,
    required this.accentSoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.outline,
    required this.outlineVariant,
    required this.focusedLine,
    required this.playbackGlow,
    required this.borderSoft,
    required this.borderGold,
    required this.error,
    required this.onError,
    required this.errorContainer,
  });

  static SacredColors of(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<SacredPalette>()!;
    return SacredColors._(
      background:              cs.surface,
      backgroundPrimary:       cs.surface,
      backgroundBlack:         ext.surfaceContainerLowest,
      backgroundDeep:          cs.surface,
      backgroundDark:          ext.surfaceContainerLow,
      backgroundMuted:         ext.surfaceContainer,
      surfaceContainerLowest:  ext.surfaceContainerLowest,
      surfaceContainerLow:     ext.surfaceContainerLow,
      surfaceContainer:        ext.surfaceContainer,
      surfaceContainerHigh:    ext.surfaceContainerHigh,
      surfaceContainerHighest: ext.surfaceContainerHighest,
      surfaceBright:           ext.surfaceContainerHighest,
      surfacePrimary:          ext.surfaceContainer,
      surfaceSecondary:        ext.surfaceContainerHigh,
      surfaceTertiary:         ext.surfaceContainerHighest,
      primary:                 cs.primary,
      onPrimary:               cs.onPrimary,
      primaryContainer:        cs.primaryContainer,
      onPrimaryContainer:      cs.onPrimaryContainer,
      secondary:               cs.secondary,
      onSecondary:             cs.onSecondary,
      surfaceTint:             cs.surfaceTint,
      primaryAccent:           cs.primary,
      accentSoft:              cs.secondary,
      textPrimary:             cs.onSurface,
      textSecondary:           cs.onSurfaceVariant,
      outline:                 cs.outline,
      outlineVariant:          cs.outlineVariant,
      focusedLine:             ext.focusGlow,
      playbackGlow:            ext.focusGlow,
      borderSoft:              ext.borderSoft,
      borderGold:              ext.borderGold,
      error:                   cs.error,
      onError:                 cs.onError,
      errorContainer:          cs.errorContainer,
    );
  }

  // ─── Instance fields ─────────────────────────────────────────────────────
  final Color background;
  final Color backgroundPrimary;
  final Color backgroundBlack;
  final Color backgroundDeep;
  final Color backgroundDark;
  final Color backgroundMuted;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color surfaceBright;
  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color surfaceTertiary;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color surfaceTint;
  final Color primaryAccent;
  final Color accentSoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color outline;
  final Color outlineVariant;
  final Color focusedLine;
  final Color playbackGlow;
  final Color borderSoft;
  final Color borderGold;
  final Color error;
  final Color onError;
  final Color errorContainer;
}
