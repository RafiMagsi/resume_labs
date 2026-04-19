import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF6D5EF8);
  static const Color primaryDark = Color(0xFF5243D8);
  static const Color secondary = Color(0xFF22C7A9);
  static const Color accent = Color(0xFF8B7CFF);

  // Neutrals
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // States
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // Shadows / overlays
  static const Color shadow = Color(0x140F172A);
  static const Color overlay = Color(0x660F172A);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6D5EF8), Color(0xFF8B7CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}