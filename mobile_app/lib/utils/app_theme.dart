import 'package:flutter/material.dart';
import '../core/design_system/tokens/colors.dart';

class AppTheme {
  // New AMOLED-first palette (mapped to SacredColors)
  static const Color primaryGold = SacredColors.primaryAccent;
  static const Color accentSoft = SacredColors.accentSoft;
  
  // Legacy color mappings (updated for dark theme compatibility)
  static const Color textBrown = SacredColors.textPrimary; // Was #8B4513
  static const Color lightCream = SacredColors.backgroundBlack; // Was #FFFDF7
  static const Color warmBeige = SacredColors.surfacePrimary; // Was #D4C19C

  static const TextStyle headingStyle = TextStyle(
    color: SacredColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyStyle = TextStyle(
    color: SacredColors.textPrimary,
    fontSize: 16,
    height: 1.6,
    letterSpacing: 0.5,
  );

  static const TextStyle gurmukhiStyle = TextStyle(
    color: SacredColors.primaryAccent,
    fontSize: 20,
    height: 1.8,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle metaStyle = TextStyle(
    color: SacredColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
  );
}