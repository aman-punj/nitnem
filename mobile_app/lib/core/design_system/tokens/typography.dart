import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Sacred Radiance typography tokens.
///
/// Heading roles → Playfair Display (editorial, timeless).
/// Body / UI roles → Inter (clean, legible).
/// Gurmukhi roles  → Mukta (bundled locally; handles Punjabi script).
///
/// NOTE: Google Fonts styles are non-const; use static final fields.
/// Pass [color] explicitly only when you need a non-default colour;
/// otherwise rely on the ThemeData textTheme for colour inheritance.
class SacredTypography {
  SacredTypography._();

  // ─── Heading roles — Playfair Display ────────────────────────────────────

  static final TextStyle displayLg = GoogleFonts.playfairDisplay(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.8,
    color: SacredColors.textPrimary,
  );

  static final TextStyle headlineLg = GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: SacredColors.textPrimary,
  );

  /// Mobile-first headline — used in app bars and section titles.
  static final TextStyle headlineLgMobile = GoogleFonts.playfairDisplay(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: SacredColors.textPrimary,
  );

  static final TextStyle headlineMd = GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.33,
    color: SacredColors.textPrimary,
  );

  // ─── Body roles — Inter ──────────────────────────────────────────────────

  static final TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.7,
    color: SacredColors.textPrimary,
  );

  static final TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: SacredColors.textPrimary,
  );

  static final TextStyle bodySm = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: SacredColors.textSecondary,
  );

  /// Small uppercase label — navigation metadata, chips.
  static final TextStyle labelSm = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    color: SacredColors.textSecondary,
  );

  static final TextStyle meta = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: SacredColors.textSecondary,
  );

  // ─── Gurmukhi — Mukta (local asset font) ─────────────────────────────────

  static const String _gurmukhiFamily = 'Mukta';

  /// Primary Gurbani reading text. Large, airy line-height for immersive reading.
  static const TextStyle transcript = TextStyle(
    fontFamily: _gurmukhiFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.8,
    color: SacredColors.textPrimary,
  );

  /// Compact Gurmukhi — sub-lines, transliterations.
  static const TextStyle transcriptSm = TextStyle(
    fontFamily: _gurmukhiFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.7,
    color: SacredColors.textSecondary,
  );

  // ─── Legacy aliases — keep widgets compiling without change ──────────────
  static final TextStyle title = headlineLgMobile;
  static final TextStyle body  = bodyMd;
}
