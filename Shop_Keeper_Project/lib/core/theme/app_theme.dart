import 'package:flutter/material.dart';

class AppTheme {
  // 🌌 Dark Mode Backgrounds
  static const Color darkBackgroundMain = Color(0xFF030303);
  static const Color darkBackgroundLayer = Color(0xFF0F172A);
  
  // ☀️ Light Mode Backgrounds
  static const Color lightBackgroundMain = Color(0xFFF8FAFC);
  static const Color lightBackgroundLayer = Color(0xFFFFFFFF);
  
  // 💎 Shared Accents (Royal Indigo & Modern Teal)
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color softIndigoGlow = Color(0xFF818CF8);

  // ⚡ Status Colors
  static const Color successEmerald = Color(0xFF10B981);
  static const Color dangerRose = Color(0xFFF43F5E);
  static const Color warningAmber = Color(0xFFF59E0B);
  
  static const Color primaryColor = primaryIndigo;
  static const Color errorColor = dangerRose;
  static const Color successColor = successEmerald;
  static const Color warningColor = warningAmber;
  static const Color backgroundColor = darkBackgroundMain;
  static const Color accentColor = accentTeal;
  
  // 📝 Dark Mode Text
  static const Color textWhite = Color(0xFFF9FAFB);
  static const Color textGrey = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // 📝 Light Mode Text
  static const Color textBlack = Color(0xFF0F172A);
  static const Color textDarkGrey = Color(0xFF475569);
  static const Color textLightMuted = Color(0xFF94A3B8);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryIndigo,
      scaffoldBackgroundColor: darkBackgroundMain, 
      
      colorScheme: const ColorScheme.dark(
        primary: primaryIndigo,
        secondary: accentTeal,
        error: dangerRose,
        surface: darkBackgroundLayer,
        onSurface: textWhite,
        onSurfaceVariant: textGrey,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textWhite, letterSpacing: -1),
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textWhite),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textWhite),
        bodyLarge: TextStyle(fontSize: 18, color: textWhite),
        bodyMedium: TextStyle(fontSize: 16, color: textWhite),
        bodySmall: TextStyle(fontSize: 14, color: textGrey),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textWhite),
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textWhite, letterSpacing: 1.5),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkBackgroundLayer,
        contentTextStyle: const TextStyle(color: textWhite, fontWeight: FontWeight.w600),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBackgroundLayer.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        labelStyle: const TextStyle(color: textGrey, fontWeight: FontWeight.w500),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryIndigo,
      scaffoldBackgroundColor: lightBackgroundMain,
      
      colorScheme: const ColorScheme.light(
        primary: primaryIndigo,
        secondary: accentTeal,
        error: dangerRose,
        surface: lightBackgroundLayer,
        onSurface: textBlack,
        onSurfaceVariant: textDarkGrey,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textBlack, letterSpacing: -1),
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textBlack),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textBlack),
        bodyLarge: TextStyle(fontSize: 18, color: textBlack),
        bodyMedium: TextStyle(fontSize: 16, color: textBlack),
        bodySmall: TextStyle(fontSize: 14, color: textDarkGrey),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackgroundMain,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textBlack),
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textBlack, letterSpacing: 1.5),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightBackgroundLayer,
        contentTextStyle: const TextStyle(color: textBlack, fontWeight: FontWeight.w600),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 10,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9), // Slate 100
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.black.withOpacity(0.05))),
        labelStyle: const TextStyle(color: textDarkGrey, fontWeight: FontWeight.w500),
      ),
    );
  }
}
