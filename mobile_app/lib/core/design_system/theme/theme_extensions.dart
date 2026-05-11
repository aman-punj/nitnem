import 'package:flutter/material.dart';

import '../tokens/colors.dart';

@immutable
class SacredPalette extends ThemeExtension<SacredPalette> {
  const SacredPalette({
    required this.surfacePrimary,
    required this.surfaceSecondary,
  });

  final Color surfacePrimary;
  final Color surfaceSecondary;

  @override
  ThemeExtension<SacredPalette> copyWith({Color? surfacePrimary, Color? surfaceSecondary}) {
    return SacredPalette(
      surfacePrimary: surfacePrimary ?? this.surfacePrimary,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
    );
  }

  @override
  ThemeExtension<SacredPalette> lerp(covariant ThemeExtension<SacredPalette>? other, double t) {
    if (other is! SacredPalette) return this;
    return SacredPalette(
      surfacePrimary: Color.lerp(surfacePrimary, other.surfacePrimary, t) ?? surfacePrimary,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t) ?? surfaceSecondary,
    );
  }

  static const dark = SacredPalette(
    surfacePrimary: SacredColors.surfacePrimary,
    surfaceSecondary: SacredColors.surfaceSecondary,
  );
}
