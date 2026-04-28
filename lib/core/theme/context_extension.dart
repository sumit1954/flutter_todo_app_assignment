import 'package:flutter/material.dart';
import 'app_colors.dart';

extension AppThemeExtension on BuildContext {
  AppColors get colors {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.light
        ? const LightThemeColors()
        : const DarkThemeColors();
  }

  TextTheme get textTheme => Theme.of(this).textTheme;
}
