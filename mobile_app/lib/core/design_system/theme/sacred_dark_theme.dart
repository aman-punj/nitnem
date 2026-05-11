import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/typography.dart';
import 'theme_extensions.dart';

ThemeData buildSacredDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: SacredColors.backgroundPrimary,
    colorScheme: const ColorScheme.dark(
      primary: SacredColors.primaryAccent,
      secondary: SacredColors.accentSoft,
      surface: SacredColors.surfacePrimary,
    ),
    textTheme: const TextTheme(
      titleLarge: SacredTypography.title,
      bodyLarge: SacredTypography.body,
      bodyMedium: SacredTypography.body,
      labelMedium: SacredTypography.meta,
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: SacredColors.primaryAccent),
    inputDecorationTheme: const InputDecorationTheme(
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: SacredColors.primaryAccent),
      ),
    ),
    extensions: const [SacredPalette.dark],
  );
}
