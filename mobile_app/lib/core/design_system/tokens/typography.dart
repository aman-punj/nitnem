import 'package:flutter/material.dart';

import 'colors.dart';

class SacredTypography {
  static const String bodyFont = 'Inter';
  static const String gurmukhiFont = 'Mukta';

  static const TextStyle title = TextStyle(
    fontFamily: bodyFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: SacredColors.textPrimary,
    letterSpacing: 0.2,
  );

  static const TextStyle body = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: SacredColors.textPrimary,
    height: 1.6,
  );

  static const TextStyle transcript = TextStyle(
    fontFamily: gurmukhiFont,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: SacredColors.textPrimary,
    height: 1.8,
  );

  static const TextStyle meta = TextStyle(
    fontFamily: bodyFont,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: SacredColors.textSecondary,
  );
}
