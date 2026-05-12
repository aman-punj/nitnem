import 'package:flutter/material.dart';

import '../models/app_tokens.dart';
import '../models/theme_config.dart';
import 'sacred_dark_theme.dart';

class AppTheme {
  AppTheme._();

  /// Resolve a [ThemeData] from [config].
  ///
  /// Base tokens come from the [ThemeConfig.themeId] preset.
  /// If [ThemeConfig.tokenOverrides] is provided (e.g. fetched from
  /// Firebase Remote Config), those values are patched on top before building.
  static ThemeData resolve(ThemeConfig config) {
    AppTokens tokens = _baseTokens(config.themeId);

    if (config.tokenOverrides != null && config.tokenOverrides!.isNotEmpty) {
      tokens = tokens.mergeFromJson(config.tokenOverrides!);
    }

    return buildThemeFromTokens(tokens);
  }

  static AppTokens _baseTokens(String themeId) {
    switch (themeId) {
      // Future presets go here — e.g. 'sacred_radiance_light', 'gurpurab_special'
      case 'sacred_radiance_dark':
      default:
        return AppTokens.sacredRadianceDark();
    }
  }
}
