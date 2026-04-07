import 'package:flutter/material.dart';

class AppColors {
  // 🌑 Premium Matte Backgrounds
  static const Color background = Color(0xFF0D0D0D); // Deepest carbon black
  static const Color surface = Color(0xFF1A1A1A);    // Graphite gray for cards
  static const Color cardGradientStart = Color(0xFF222222);
  static const Color cardGradientEnd = Color(0xFF1A1A1A);

  // 💎 Luxury Accents
  static const Color primary = Color(0xFFD4AF37);    // Classic Metallic Gold (Champagne)
  static const Color primaryGlow = Color(0xFFFFD700); // 24k Gold Glow
  static const Color secondary = Color(0xFF8A8A8A);  // Muted Platinum Gray

  // ✨ Status Colors (Semi-Muted Premium)
  static const Color success = Color(0xFF00C896);    // Emerald Green
  static const Color error = Color(0xFFFF4D4D);      // Ruby Red
  static const Color warning = Color(0xFFFFB84D);    // Deep Amber
  static const Color info = Color(0xFF4D94FF);       // Sapphire Blue

  // 📝 Typography Hierarchy
  static const Color textPrimary = Color(0xFFF5F5F5);   // Luxury Pearl White
  static const Color textSecondary = Color(0xFF8A8A8A); // Muted Silver
  static const Color textMuted = Color(0xFF4A4A4A);     // Dark Slate Grey

  // 🌫️ Glassmorphism & Borders
  static const Color glassWhite = Color(0x0FFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassGold = Color(0x33D4AF37);

  // 🌈 Premium Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF1D592), Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGlassGradient = LinearGradient(
    colors: [Color(0x1FFFFFFF), Color(0x0AFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Redirected Legacy Aliases (pointing to Luxury Palette)
  static const Color goldLight = primaryGlow;
  static const Color goldPrimary = primary;
  static const Color goldDark = primary;
  static const Color emeraldLight = success;
  static const Color emeraldSuccess = success;
  static const Color emeraldDark = success;
  static const Color sapphireLight = info;
  static const Color sapphireInfo = info;
  static const Color sapphireDark = info;
  static const Color amberLight = warning;
  static const Color amberWarning = warning;
  static const Color amberDark = warning;
  static const Color rubyLight = error;
  static const Color rubyError = error;
  static const Color rubyDark = error;
  static const Color primaryIndigo = primary;
  static const Color accentTeal = success;
  static const Color darkBackgroundMain = background;
  static const Color darkBackgroundLayer = surface;
  static const Color textWhite = textPrimary;
  static const Color textGrey = textSecondary;
  static const Color dangerRose = error;
  static const Color successEmerald = success;
  static const Color warningAmber = warning;
  static const Color lightBackgroundMain = Color(0xFFFBFBFB);
  static const Color textDarkGrey = Color(0xFF666666);
  static const Color textBlack = Color(0xFF121212);
  static const Color backgroundColor = background;
  static const Color primaryOrchid = primary;
  static const Color secondaryCyan = info;

  // Theme-specific text colors
  static const Color darkTextPrimary = textPrimary;
  static const Color darkTextSecondary = textSecondary;
  static const Color darkTextMuted = textMuted;
  static const Color lightTextPrimary = Color(0xFF121212);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightTextMuted = Color(0xFF999999);
}
