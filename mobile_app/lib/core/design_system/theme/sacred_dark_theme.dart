import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/app_tokens.dart';
import 'theme_extensions.dart';

/// Builds a [ThemeData] entirely from [AppTokens].
/// This is the single function that turns raw token values into Flutter's
/// material theme. Swap the tokens → entire theme changes.
ThemeData buildThemeFromTokens(AppTokens t) {
  final colorScheme = ColorScheme(
    brightness: Brightness.dark,
    // Primary gold
    primary:             t.primary,
    onPrimary:           t.onPrimary,
    primaryContainer:    t.primaryContainer,
    onPrimaryContainer:  t.onPrimaryContainer,
    // Secondary gold
    secondary:           t.secondary,
    onSecondary:         t.onSecondary,
    secondaryContainer:  t.surfaceContainerHigh,
    onSecondaryContainer: t.onSurfaceVariant,
    // Tertiary — neutral warm (reuse onSurfaceVariant palette)
    tertiary:            t.onSurfaceVariant,
    onTertiary:          t.surfaceContainerLowest,
    tertiaryContainer:   t.surfaceContainerHigh,
    onTertiaryContainer: t.onSurface,
    // Surface tier (Material 3)
    surface:             t.surface,
    onSurface:           t.onSurface,
    onSurfaceVariant:    t.onSurfaceVariant,
    surfaceContainerLowest:  t.surfaceContainerLowest,
    surfaceContainerLow:     t.surfaceContainerLow,
    surfaceContainer:        t.surfaceContainer,
    surfaceContainerHigh:    t.surfaceContainerHigh,
    surfaceContainerHighest: t.surfaceContainerHighest,
    // Misc
    outline:             t.outline,
    outlineVariant:      t.outlineVariant,
    surfaceTint:         t.surfaceTint,
    error:               t.error,
    onError:             t.onError,
    errorContainer:      const Color(0xFF93000A),
    onErrorContainer:    const Color(0xFFFFDAD6),
    inverseSurface:      t.onSurface,
    onInverseSurface:    t.surfaceContainerLowest,
    inversePrimary:      const Color(0xFF735C00),
    scrim:               Colors.black,
    shadow:              Colors.black,
  );

  // Google Fonts text theme — Playfair Display headings + Inter body
  final textTheme = GoogleFonts.interTextTheme(
    TextTheme(
      // Display
      displayLarge:  GoogleFonts.playfairDisplay(fontSize: 57, fontWeight: FontWeight.w400, color: t.onSurface),
      displayMedium: GoogleFonts.playfairDisplay(fontSize: 45, fontWeight: FontWeight.w400, color: t.onSurface),
      displaySmall:  GoogleFonts.playfairDisplay(fontSize: 36, fontWeight: FontWeight.w400, color: t.onSurface),
      // Headline — used for screen/section titles
      headlineLarge:  GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w600, color: t.onSurface),
      headlineMedium: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w600, color: t.onSurface),
      headlineSmall:  GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w500, color: t.onSurface),
      // Title — used inside cards and app bars
      titleLarge:  GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w600, color: t.onSurface),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: t.onSurface, letterSpacing: 0.15),
      titleSmall:  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: t.onSurface, letterSpacing: 0.1),
      // Body — main reading text
      bodyLarge:   GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w400, height: 1.7, color: t.onSurface),
      bodyMedium:  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, height: 1.6, color: t.onSurface),
      bodySmall:   GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: t.onSurfaceVariant),
      // Label — metadata, chips, navigation items
      labelLarge:  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: t.onSurface),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: t.onSurfaceVariant),
      labelSmall:  GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: t.onSurfaceVariant),
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: t.background,
    textTheme: textTheme,

    // ── AppBar ────────────────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: t.background,
      foregroundColor: t.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: t.onSurface,
      ),
      iconTheme: IconThemeData(color: t.primary),
      actionsIconTheme: IconThemeData(color: t.primary),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    ),

    // ── Cards ─────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: t.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.radiusLg),
        side: BorderSide(color: t.outlineVariant.withValues(alpha: 0.3), width: 1),
      ),
    ),

    // ── ListTile ──────────────────────────────────────────────────────────
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      iconColor: t.primary,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: t.onSurface,
      ),
      subtitleTextStyle: GoogleFonts.inter(
        fontSize: 13,
        color: t.onSurfaceVariant,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: t.spaceGutter, vertical: 4),
      minLeadingWidth: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radiusMd)),
    ),

    // ── Input ─────────────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.radiusDef),
        borderSide: BorderSide(color: t.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.radiusDef),
        borderSide: BorderSide(color: t.outlineVariant.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.radiusDef),
        borderSide: BorderSide(color: t.primary, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(fontSize: 15, color: t.onSurfaceVariant),
    ),

    // ── Buttons ───────────────────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: t.primary,
        foregroundColor: t.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radiusDef)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: t.primary,
        side: BorderSide(color: t.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radiusDef)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: t.primary,
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),

    // ── Divider ───────────────────────────────────────────────────────────
    dividerTheme: DividerThemeData(
      color: t.outlineVariant.withValues(alpha: 0.4),
      thickness: 1,
      space: 0,
    ),

    // ── Drawer ────────────────────────────────────────────────────────────
    drawerTheme: DrawerThemeData(
      backgroundColor: t.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),

    // ── Popup / Dialog ────────────────────────────────────────────────────
    popupMenuTheme: PopupMenuThemeData(
      color: t.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.radiusMd),
        side: BorderSide(color: t.outlineVariant.withValues(alpha: 0.3)),
      ),
      textStyle: GoogleFonts.inter(fontSize: 14, color: t.onSurface),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: t.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radiusLg)),
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 20, fontWeight: FontWeight.w600, color: t.onSurface,
      ),
      contentTextStyle: GoogleFonts.inter(fontSize: 15, color: t.onSurfaceVariant, height: 1.5),
    ),

    // ── Slider (audio scrubber) ───────────────────────────────────────────
    sliderTheme: SliderThemeData(
      trackHeight: 2,
      activeTrackColor: t.primary,
      inactiveTrackColor: t.outlineVariant.withValues(alpha: 0.4),
      thumbColor: t.primary,
      overlayColor: t.primary.withValues(alpha: 0.1),
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
    ),

    // ── Progress ─────────────────────────────────────────────────────────
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: t.primary,
      circularTrackColor: t.outlineVariant.withValues(alpha: 0.3),
    ),

    // ── Icon ─────────────────────────────────────────────────────────────
    iconTheme: IconThemeData(color: t.onSurface, size: 24),

    // ── Text Selection ────────────────────────────────────────────────────
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: t.primary,
      selectionColor: t.primary.withValues(alpha: 0.3),
      selectionHandleColor: t.primary,
    ),

    // ── Scroll behaviour ─────────────────────────────────────────────────
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(t.outlineVariant),
    ),

    // ── Sacred Palette extension ─────────────────────────────────────────
    extensions: [
      SacredPalette.fromTokens(t),
    ],
  );
}
