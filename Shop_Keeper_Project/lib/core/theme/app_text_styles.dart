import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();
  
  // ═══════════════════════════════════════════════════════════════════
  // 📝 DISPLAY STYLES - Hero headlines
  // ═══════════════════════════════════════════════════════════════════
  
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.5,
    height: 1.1,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    height: 1.15,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // 📝 HEADLINE STYLES - Section titles
  // ═══════════════════════════════════════════════════════════════════
  
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.25,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.35,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // 📝 TITLE STYLES - Card & list titles
  // ═══════════════════════════════════════════════════════════════════
  
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // 📝 BODY STYLES - Content text
  // ═══════════════════════════════════════════════════════════════════
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.5,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // 📝 LABEL STYLES - UI labels & buttons
  // ═══════════════════════════════════════════════════════════════════
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.4,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    height: 1.4,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // 📝 SPECIALTY STYLES
  // ═══════════════════════════════════════════════════════════════════
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
    height: 1.2,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.4,
  );
  
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    height: 1.4,
  );
  
  static const TextStyle mono = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.5,
    fontFamily: 'monospace',
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // 📝 DARK THEME TEXT UTILITIES
  // ═══════════════════════════════════════════════════════════════════
  
  static TextStyle darkPrimary([TextStyle? style]) => (style ?? bodyLarge).copyWith(
    color: AppColors.darkTextPrimary,
  );
  
  static TextStyle darkSecondary([TextStyle? style]) => (style ?? bodyMedium).copyWith(
    color: AppColors.darkTextSecondary,
  );
  
  static TextStyle darkMuted([TextStyle? style]) => (style ?? bodySmall).copyWith(
    color: AppColors.darkTextMuted,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // 📝 LIGHT THEME TEXT UTILITIES
  // ═══════════════════════════════════════════════════════════════════
  
  static TextStyle lightPrimary([TextStyle? style]) => (style ?? bodyLarge).copyWith(
    color: AppColors.lightTextPrimary,
  );
  
  static TextStyle lightSecondary([TextStyle? style]) => (style ?? bodyMedium).copyWith(
    color: AppColors.lightTextSecondary,
  );
  
  static TextStyle lightMuted([TextStyle? style]) => (style ?? bodySmall).copyWith(
    color: AppColors.lightTextMuted,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // 📝 GOLD ACCENT TEXT UTILITIES
  // ═══════════════════════════════════════════════════════════════════
  
  static TextStyle goldText([TextStyle? style]) => (style ?? bodyLarge).copyWith(
    color: AppColors.goldPrimary,
  );
  
  static TextStyle goldBold([TextStyle? style]) => (style ?? titleMedium).copyWith(
    color: AppColors.goldPrimary,
    fontWeight: FontWeight.w800,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // 📝 NUMERIC DISPLAY (for prices, stats)
  // ═══════════════════════════════════════════════════════════════════
  
  static const TextStyle numericLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  
  static const TextStyle numericMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  
  static const TextStyle numericSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
