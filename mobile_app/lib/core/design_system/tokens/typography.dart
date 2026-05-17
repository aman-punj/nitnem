import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:nitnem/controllers/font_size_controller.dart';

class SacredTypography {
  SacredTypography._();

  static double get _scale => Get.find<FontSizeController>().fontSizeScale;

  // ─── Heading roles — Playfair Display ────────────────────────────────────

  static TextStyle get displayLg => GoogleFonts.playfairDisplay(
    fontSize: 40 * _scale,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.8,
  );

  static TextStyle get headlineLg => GoogleFonts.playfairDisplay(
    fontSize: 32 * _scale,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  /// Mobile-first headline — used in app bars and section titles.
  static TextStyle get headlineLgMobile => GoogleFonts.playfairDisplay(
    fontSize: 22 * _scale,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle get headlineMd => GoogleFonts.playfairDisplay(
    fontSize: 24 * _scale,
    fontWeight: FontWeight.w500,
    height: 1.33,
  );

  // ─── Body roles — Inter ──────────────────────────────────────────────────

  static TextStyle get bodyLg => GoogleFonts.inter(
    fontSize: 18 * _scale,
    fontWeight: FontWeight.w400,
    height: 1.7,
  );

  static TextStyle get bodyMd => GoogleFonts.inter(
    fontSize: 16 * _scale,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle get bodySm => GoogleFonts.inter(
    fontSize: 14 * _scale,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Small uppercase label — navigation metadata, chips.
  static TextStyle get labelSm => GoogleFonts.inter(
    fontSize: 12 * _scale,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
  );

  static TextStyle get meta => GoogleFonts.inter(
    fontSize: 13 * _scale,
    fontWeight: FontWeight.w500,
  );

  // ─── Gurmukhi — Mukta (local asset font) ─────────────────────────────────

  static const String _gurmukhiFamily = 'Mukta';

  /// Primary Gurbani reading text. Large, airy line-height for immersive reading.
  static TextStyle get transcript => TextStyle(
    fontFamily: _gurmukhiFamily,
    fontSize: 22 * _scale,
    fontWeight: FontWeight.w500,
    height: 1.8,
  );

  /// Compact Gurmukhi — sub-lines, transliterations.
  static TextStyle get transcriptSm => TextStyle(
    fontFamily: _gurmukhiFamily,
    fontSize: 18 * _scale,
    fontWeight: FontWeight.w400,
    height: 1.7,
  );

  // ─── Legacy aliases ───────────────────────────────────────────────────────
  static TextStyle get title => headlineLgMobile;
  static TextStyle get body  => bodyMd;
}
