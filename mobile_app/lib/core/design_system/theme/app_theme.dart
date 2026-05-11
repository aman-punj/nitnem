import 'package:flutter/material.dart';

import '../models/theme_config.dart';
import 'sacred_dark_theme.dart';

class AppTheme {
  static ThemeData resolve(ThemeConfig config) {
    return buildSacredDarkTheme();
  }
}
