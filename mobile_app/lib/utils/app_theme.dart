import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color secondaryGold = Color(0xFFB8860B);
  static const Color textBrown = Color(0xFF8B4513);
  static const Color lightCream = Color(0xFFFFFDF7);
  static const Color warmBeige = Color(0xFFD4C19C);

  static const TextStyle headingStyle = TextStyle(
    color: textBrown,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.4,
  );

  static const TextStyle bodyStyle = TextStyle(
    color: textBrown,
    fontSize: 16,
    height: 1.6,
    letterSpacing: 0.5,
  );

  static const TextStyle gurmukhiStyle = TextStyle(
    color: textBrown,
    fontSize: 18,
    height: 1.8,
    fontWeight: FontWeight.w500,
  );
}