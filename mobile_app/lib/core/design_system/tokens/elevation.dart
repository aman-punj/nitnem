import 'package:flutter/material.dart';

import 'colors.dart';

class SacredElevation {
  static List<BoxShadow> soft = const [
    BoxShadow(
      color: SacredColors.playbackGlow,
      blurRadius: 14,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];
}
