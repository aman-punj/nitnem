import 'package:flutter/material.dart';

import 'colors.dart';

/// Elevation via tonal layering and golden halos — no harsh drop shadows.
class SacredElevation {
  SacredElevation._();

  /// Subtle card lift — dark ambient shadow.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x4D000000), // black @ 30 %
      blurRadius: 10,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  /// Soft golden ambient for lightly elevated surfaces.
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x1FF2CA50), // gold @ 12 %
      blurRadius: 20,
      spreadRadius: -4,
      offset: Offset(0, 4),
    ),
  ];

  /// Sacred glow — active / "now reading" elements radiate light.
  static const List<BoxShadow> sacredGlow = [
    BoxShadow(
      color: SacredColors.focusedLine, // gold @ 15 %
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 0),
    ),
  ];
}
