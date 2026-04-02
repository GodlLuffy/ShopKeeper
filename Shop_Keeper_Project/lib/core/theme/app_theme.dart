import 'package:flutter/material.dart';

class AppTheme {
  // 🌌 Cyber Orchid Dark Mode (Midnight/Violet Deep)
  static const Color darkBackgroundMain = Color(0xFF030014); // Deep space black
  static const Color darkBackgroundLayer = Color(0xFF0B0815); // Deep violet shelf
  
  // ☀️ Cyber Orchid Light Mode (Pure Pearl/Cloud)
  static const Color lightBackgroundMain = Color(0xFFFDFDFF);
  static const Color lightBackgroundLayer = Color(0xFFFFFFFF);
  
  // 💎 Cyber Orchid Accents (Neon Fuchsia & Electric Cyan)
  static const Color primaryOrchid = Color(0xFFD946EF); // Fuchsia 500
  static const Color secondaryCyan = Color(0xFF06B6D4); // Cyan 500
  static const Color softOrchidGlow = Color(0xFFE879F9); // Fuchsia 400
  static const Color neonCyanGlow = Color(0xFF22D3EE); // Cyan 400

  // ⚡ Status Colors (Vivid Palette)
  static const Color successEmerald = Color(0xFF10B981);
  static const Color dangerRose = Color(0xFFF43F5E);
  static const Color warningAmber = Color(0xFFF59E0B);
  
  // Legacy Aliases for compatibility
  static const Color warningColor = warningAmber;
  static const Color backgroundColor = darkBackgroundMain;
  static const Color accentColor = secondaryCyan;
  static const Color primaryIndigo = primaryOrchid; // Transitioning legacy name
  static const Color accentTeal = secondaryCyan; // Transitioning legacy name
  static const Color softIndigoGlow = softOrchidGlow; // Transitioning legacy name

  // ✨ Modern Design System Tokens
  static const Gradient premiumGradient = LinearGradient(
    colors: [Color(0xFFD946EF), Color(0xFFA855F7), Color(0xFF6366F1)], // Orchid -> Purple -> Indigo
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient cyberPulseGradient = LinearGradient(
    colors: [primaryOrchid, secondaryCyan],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static BoxDecoration glassDecoration({required bool isDark}) => BoxDecoration(
    color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.01),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
      width: 0.8,
    ),
  );

  static List<BoxShadow> get premiumShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.35),
      blurRadius: 50,
      offset: const Offset(0, 25),
      spreadRadius: -15,
    ),
  ];

  static List<BoxShadow> get orchidGlowShadow => [
    BoxShadow(
      color: primaryOrchid.withOpacity(0.2),
      blurRadius: 30,
      spreadRadius: -5,
    ),
  ];
  
  // 📝 Dark Mode Text Hierarchy
  static const Color textWhite = Color(0xFFFDFDFF);
  static const Color textGrey = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF475569);

  // 📝 Light Mode Text Hierarchy
  static const Color textBlack = Color(0xFF030014);
  static const Color textDarkGrey = Color(0xFF1E1B4B);
  static const Color textLightMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryOrchid,
      scaffoldBackgroundColor: darkBackgroundMain, 
      
      colorScheme: const ColorScheme.dark(
        primary: primaryOrchid,
        secondary: secondaryCyan,
        error: dangerRose,
        surface: darkBackgroundLayer,
        onSurface: textWhite,
        onSurfaceVariant: textGrey,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: textWhite, letterSpacing: -1.2),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textWhite, letterSpacing: -0.5),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textWhite),
        bodyLarge: TextStyle(fontSize: 18, color: textWhite, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontSize: 16, color: textWhite),
        bodySmall: TextStyle(fontSize: 14, color: textGrey),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textWhite),
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textWhite, letterSpacing: 2),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkBackgroundLayer,
        contentTextStyle: const TextStyle(color: textWhite, fontWeight: FontWeight.w700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: primaryOrchid.withOpacity(0.2))),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBackgroundLayer.withOpacity(0.8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: primaryOrchid, width: 1.5)),
        labelStyle: const TextStyle(color: textGrey, fontWeight: FontWeight.w600),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryOrchid,
      scaffoldBackgroundColor: lightBackgroundMain,
      
      colorScheme: const ColorScheme.light(
        primary: primaryOrchid,
        secondary: secondaryCyan,
        error: dangerRose,
        surface: lightBackgroundLayer,
        onSurface: textBlack,
        onSurfaceVariant: textDarkGrey,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: textBlack, letterSpacing: -1.2),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textBlack, letterSpacing: -0.5),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textBlack),
        bodyLarge: TextStyle(fontSize: 18, color: textBlack, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontSize: 16, color: textBlack),
        bodySmall: TextStyle(fontSize: 14, color: textDarkGrey),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackgroundMain,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textBlack),
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textBlack, letterSpacing: 2),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightBackgroundLayer,
        contentTextStyle: const TextStyle(color: textBlack, fontWeight: FontWeight.w700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: primaryOrchid.withOpacity(0.1))),
        elevation: 15,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.black.withOpacity(0.05))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: primaryOrchid, width: 1.5)),
        labelStyle: const TextStyle(color: textDarkGrey, fontWeight: FontWeight.w600),
      ),
    );
  }
}

