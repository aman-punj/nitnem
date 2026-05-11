import 'package:flutter/material.dart';

class SacredColors {
  // Backgrounds - AMOLED-first
  static const Color backgroundBlack = Color(0xFF000000);
  static const Color backgroundDeep = Color(0xFF050505);
  static const Color backgroundDark = Color(0xFF090909);
  static const Color backgroundMuted = Color(0xFF0D0D0D);

  // Surfaces
  static const Color surfacePrimary = Color(0xFF111111);
  static const Color surfaceSecondary = Color(0xFF151515);
  static const Color surfaceTertiary = Color(0xFF1A1A1A);

  // Legacy mappings for compatibility
  static const Color backgroundPrimary = backgroundBlack;

  // Accents
  static const Color primaryAccent = Color(0xFFD4AF37); // Muted warm gold
  static const Color accentSoft = Color(0xFFE6CC7A); // Soft champagne
  
  // Text
  static const Color textPrimary = Color(0xFFF5EED8); // Soft warm white
  static const Color textSecondary = Color(0xFFB8AE92); // Muted gold/grey
  
  // Interactive / State
  static const Color focusedLine = Color(0x33D4AF37);
  static const Color playbackGlow = Color(0x66D4AF37);
  static const Color borderSoft = Color(0x1AFFFFFF); // Very subtle white border
  static const Color borderGold = Color(0x33D4AF37); // Subtle gold border
}
