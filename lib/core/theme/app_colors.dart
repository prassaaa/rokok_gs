import 'package:flutter/material.dart';

/// Application color constants - Gunung Sari Brand Identity
class AppColors {
  AppColors._();

  // ==================== Primary Colors (Maroon/Deep Red) ====================
  // Diambil dari warna latar belakang lingkaran logo
  static const Color primary = Color(0xFF9E1C22); 
  static const Color primaryLight = Color(0xFFC64448); 
  static const Color primaryDark = Color(0xFF6B0000); 
  static const Color primarySurface = Color(0xFFFDECEA); 

  // ==================== Secondary Colors (Tobacco Gold / Leaf) ====================
  // Diambil dari warna daun tembakau dan aksen "ALAMI"
  static const Color secondary = Color(0xFFB68D40); 
  static const Color secondaryLight = Color(0xFFD4A76A); 
  static const Color secondaryDark = Color(0xFF7D5A1A); 

  // ==================== Accent Colors (Dark Contrast) ====================
  // Diambil dari elemen kotak hitam "GS"
  static const Color accent = Color(0xFF1A1A1A); 
  static const Color accentLight = Color(0xFF424242); 
  static const Color accentDark = Color(0xFF000000); 

  // ==================== Neutral Colors ====================
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFFDFBFA); 
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // ==================== Text Colors ====================
  static const Color textPrimary = Color(0xFF2D2D2D); 
  static const Color textSecondary = Color(0xFF6A6A6A); 
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFCBD5E1);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ==================== Border Colors ====================
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderDark = Color(0xFFCBD5E1);
  static const Color divider = Color(0xFFE2E8F0);

  // ==================== Status Colors ====================
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF16A34A);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF2563EB);

  // ==================== Commission Status Colors ====================
  static const Color pending = Color(0xFFF59E0B);
  static const Color approved = Color(0xFF3B82F6);
  static const Color paid = Color(0xFF22C55E);

  // ==================== Stock Colors ====================
  static const Color stockLow = Color(0xFFEF4444);
  static const Color stockNormal = Color(0xFF22C55E);
  static const Color stockWarning = Color(0xFFF59E0B);

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