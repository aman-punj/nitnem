import 'package:flutter/material.dart';

// Legacy utility — static constants kept for backward compatibility.
// New code should use SacredColors.of(context) instead.
class AppTheme {
  static const Color primaryGold = Color(0xFFF2CA50);
  static const Color accentSoft  = Color(0xFFF0C12C);

  static const Color textBrown  = Color(0xFFE5E2E1);
  static const Color lightCream = Color(0xFF0E0E0E);
  static const Color warmBeige  = Color(0xFF201F1F);

  static const TextStyle headingStyle = TextStyle(
    color: Color(0xFFE5E2E1),
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyStyle = TextStyle(
    color: Color(0xFFE5E2E1),
    fontSize: 16,
    height: 1.6,
    letterSpacing: 0.5,
  );

  static const TextStyle gurmukhiStyle = TextStyle(
    color: Color(0xFFF2CA50),
    fontSize: 20,
    height: 1.8,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle metaStyle = TextStyle(
    color: Color(0xFFD0C5AF),
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
  );
}
