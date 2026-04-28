import 'package:flutter/material.dart';

abstract class AppColors {
  const AppColors();

  Color get primary;
  Color get secondary;
  Color get background;
  Color get surface;
  Color get shadow;
  Color get textMain;
  Color get textSecondary;
  Color get border;
  Color get accent;
  Color get accentBackground;
  Color get iconPrimary;
  Color get iconSecondary;
  Color get success;
  Color get warning;
  Color get error;
}

class LightThemeColors extends AppColors {
  const LightThemeColors();

  @override
  Color get primary => const Color(0xFF667EEA);
  @override
  Color get secondary => const Color(0xFF764BA2);
  @override
  Color get background => const Color(0xFFF7FAFC);
  @override
  Color get surface => Colors.white;
  @override
  Color get shadow => Colors.black;
  @override
  Color get textMain => const Color(0xFF4A4A4A);
  @override
  Color get textSecondary => const Color(0xFF4A5568);
  @override
  Color get border => const Color(0xFFE2E8F0);
  @override
  Color get accent => const Color(0xFF3182CE);
  @override
  Color get accentBackground => const Color(0xFFEBF8FF);
  @override
  Color get iconPrimary => const Color(0xFF667EEA);
  @override
  Color get iconSecondary => Colors.grey;
  @override
  Color get success => const Color(0xFF48BB78); // Green
  @override
  Color get warning => const Color(0xFFED8936); // Amber/Orange
  @override
  Color get error => const Color(0xFFF56565); // Red
}

class DarkThemeColors extends AppColors {
  const DarkThemeColors();

  @override
  Color get primary => const Color(0xFF818CF8);
  @override
  Color get secondary => const Color(0xFFA78BFA);
  @override
  Color get background => const Color(0xFF0F172A);
  @override
  Color get surface => const Color(0xFF1E293B);
  @override
  Color get shadow => Colors.black;
  @override
  Color get textMain => const Color(0xFFF1F5F9);
  @override
  Color get textSecondary => const Color(0xFF94A3B8);
  @override
  Color get border => const Color(0xFF334155);
  @override
  Color get accent => const Color(0xFF60A5FA);
  @override
  Color get accentBackground => const Color(0xFF1E293B);
  @override
  Color get iconPrimary => const Color(0xFF818CF8);
  @override
  Color get iconSecondary => const Color(0xFF64748B);
  @override
  Color get success => const Color(0xFF68D391);
  @override
  Color get warning => const Color(0xFFF6AD55);
  @override
  Color get error => const Color(0xFFFC8181);
}
