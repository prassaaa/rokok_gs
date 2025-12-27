import 'package:flutter/material.dart';

/// Application color constants
class AppColors {
  AppColors._();

  // ==================== Primary Colors ====================
  static const Color primary = Color(0xFF2563EB); // Blue 600
  static const Color primaryLight = Color(0xFF3B82F6); // Blue 500
  static const Color primaryDark = Color(0xFF1D4ED8); // Blue 700
  static const Color primarySurface = Color(0xFFDBEAFE); // Blue 100

  // ==================== Secondary Colors ====================
  static const Color secondary = Color(0xFF10B981); // Emerald 500
  static const Color secondaryLight = Color(0xFF34D399); // Emerald 400
  static const Color secondaryDark = Color(0xFF059669); // Emerald 600

  // ==================== Accent Colors ====================
  static const Color accent = Color(0xFFF59E0B); // Amber 500
  static const Color accentLight = Color(0xFFFBBF24); // Amber 400
  static const Color accentDark = Color(0xFFD97706); // Amber 600

  // ==================== Neutral Colors ====================
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // ==================== Text Colors ====================
  static const Color textPrimary = Color(0xFF1E293B); // Slate 800
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color textDisabled = Color(0xFFCBD5E1); // Slate 300
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ==================== Border Colors ====================
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderLight = Color(0xFFF1F5F9); // Slate 100
  static const Color borderDark = Color(0xFFCBD5E1); // Slate 300
  static const Color divider = Color(0xFFE2E8F0); // Slate 200

  // ==================== Status Colors ====================
  static const Color success = Color(0xFF22C55E); // Green 500
  static const Color successLight = Color(0xFFDCFCE7); // Green 100
  static const Color successDark = Color(0xFF16A34A); // Green 600

  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFEF3C7); // Amber 100
  static const Color warningDark = Color(0xFFD97706); // Amber 600

  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorLight = Color(0xFFFEE2E2); // Red 100
  static const Color errorDark = Color(0xFFDC2626); // Red 600

  static const Color info = Color(0xFF3B82F6); // Blue 500
  static const Color infoLight = Color(0xFFDBEAFE); // Blue 100
  static const Color infoDark = Color(0xFF2563EB); // Blue 600

  // ==================== Commission Status Colors ====================
  static const Color pending = Color(0xFFF59E0B); // Amber
  static const Color approved = Color(0xFF3B82F6); // Blue
  static const Color paid = Color(0xFF22C55E); // Green

  // ==================== Stock Colors ====================
  static const Color stockLow = Color(0xFFEF4444); // Red
  static const Color stockNormal = Color(0xFF22C55E); // Green
  static const Color stockWarning = Color(0xFFF59E0B); // Amber

  // ==================== Shimmer Colors ====================
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF1F5F9);

  // ==================== Gradient ====================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondary],
  );
}
