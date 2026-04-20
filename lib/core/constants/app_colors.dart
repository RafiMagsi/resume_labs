import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5B4DD8);
  static const Color primaryLight = Color(0xFFEDE9FE);
  static const Color primarySoft = Color(0xFFF5F3FF);

  // Background / surfaces
  static const Color appBackground = Color(0xFFF5F5F7);
  static const Color screenSurface = Color(0xFFFFFFFF);
  static const Color secondarySurface = Color(0xFFF8F8FA);

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders / dividers / inactive
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFEBEDF0);
  static const Color inactive = Color(0xFFD1D5DB);

  // Semantic
  static const Color error = Color(0xFFEF4444);
  static const Color errorSoft = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  // Overlay / shadows
  static const Color modalBarrier = Color(0x990F172A);
  static const Color modalOverlay = Color(0xFF8D919B);
  static const Color shadowCard = Color(0x12000000);
  static const Color shadowDialog = Color(0x18000000);

  // Utilities
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;

  // Template accents (resume templates)
  static const Color templateClassic = textSecondary; // 0xFF6B7280
  static const Color templateModern = Color(0xFF6D5EF8);
  static const Color templateModernClean = Color(0xFF8B5CF6);
  static const Color templateModernSidebar = Color(0xFF7C3AED);
  static const Color templateMinimal = Color(0xFF059669);
  static const Color templateExecutive = Color(0xFF1F2937);

  // Password strength (Material defaults)
  static const Color passwordWeak = Colors.red;
  static const Color passwordFair = Colors.orange;
  static const Color passwordGood = Colors.amber;
  static const Color passwordStrong = Colors.green;

  // Premium / paywall
  static const Color premiumGold = Color(0xFFFFB800);
  static const Color premiumGradientStart = Color(0xFFFFB800);
  static const Color premiumGradientEnd = Color(0xFFFFA500);

  // Backwards-compatible aliases (prefer the new names in new code).
  static const Color background = appBackground;
  static const Color surface = screenSurface;
  static const Color surfaceAlt = secondarySurface;
  static const Color textMuted = textTertiary;
  static const Color textOnDark = textOnPrimary;
}
