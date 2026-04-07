import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();
  
  // ═══════════════════════════════════════════════════════════════════
  // 💛 PREMIUM GOLD GRADIENTS - Luxury CTA & Primary Actions
  // ═══════════════════════════════════════════════════════════════════
  
  static const LinearGradient goldPremium = LinearGradient(
    colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldShimmer = LinearGradient(
    colors: [AppColors.goldDark, AppColors.goldPrimary, AppColors.goldLight, AppColors.goldPrimary],
    stops: [0.0, 0.35, 0.65, 1.0],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );
  
  static const LinearGradient goldVertical = LinearGradient(
    colors: [AppColors.goldLight, AppColors.goldPrimary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // 💚 EMERALD SUCCESS GRADIENTS - Positive Actions & Stats
  // ═══════════════════════════════════════════════════════════════════
  
  static const LinearGradient emeraldPremium = LinearGradient(
    colors: [AppColors.emeraldLight, AppColors.emeraldSuccess, AppColors.emeraldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient emeraldVertical = LinearGradient(
    colors: [AppColors.emeraldLight, AppColors.emeraldDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // 🎨 DARK SURFACE GRADIENTS - Cards & Elevated Surfaces
  // ═══════════════════════════════════════════════════════════════════
  
  static const LinearGradient darkSurface = LinearGradient(
    colors: [Color(0xFF1F1F1F), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGlass = LinearGradient(
    colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkElevated = LinearGradient(
    colors: [Color(0xFF252525), Color(0xFF1F1F1F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // ☀️ LIGHT SURFACE GRADIENTS - Light Mode Cards
  // ═══════════════════════════════════════════════════════════════════
  
  static const LinearGradient lightSurface = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient lightElevated = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAFBFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // 💜 PURPLE ACCENT GRADIENTS - Special Features
  // ═══════════════════════════════════════════════════════════════════
  
  static const LinearGradient purplePremium = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // 🔵 SAPPHIRE INFO GRADIENTS - Information & Analytics
  // ═══════════════════════════════════════════════════════════════════
  
  static const LinearGradient sapphirePremium = LinearGradient(
    colors: [AppColors.sapphireLight, AppColors.sapphireInfo, AppColors.sapphireDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // 📊 CHART & ANALYTICS GRADIENTS
  // ═══════════════════════════════════════════════════════════════════
  
  static const List<LinearGradient> chartGradients = [
    LinearGradient(
      colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [AppColors.emeraldLight, AppColors.emeraldSuccess, AppColors.emeraldDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [AppColors.sapphireLight, AppColors.sapphireInfo, AppColors.sapphireDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [AppColors.amberLight, AppColors.amberWarning, AppColors.amberDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];
  
  // ═══════════════════════════════════════════════════════════════════
  // 🔥 RICH CARD BACKGROUNDS
  // ═══════════════════════════════════════════════════════════════════
  
  static LinearGradient statCardGold(bool isDark) => LinearGradient(
    colors: isDark 
        ? [const Color(0xFF2A2418), const Color(0xFF1F1A12)]
        : [const Color(0xFFFFF8E7), const Color(0xFFFFF3D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient statCardEmerald(bool isDark) => LinearGradient(
    colors: isDark 
        ? [const Color(0xFF0D2D25), const Color(0xFF08201A)]
        : [const Color(0xFFE8FFF5), const Color(0xFFD9FFF0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient statCardBlue(bool isDark) => LinearGradient(
    colors: isDark 
        ? [const Color(0xFF0D1F3C), const Color(0xFF081528)]
        : [const Color(0xFFE7F0FF), const Color(0xFFD9E8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient statCardPurple(bool isDark) => LinearGradient(
    colors: isDark 
        ? [const Color(0xFF1F1842), const Color(0xFF181230)]
        : [const Color(0xFFF0EBFF), const Color(0xFFE5DFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // ✨ BUTTON GRADIENTS
  // ═══════════════════════════════════════════════════════════════════
  
  static const LinearGradient buttonPrimary = goldPremium;
  
  static const LinearGradient buttonSecondary = LinearGradient(
    colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient buttonSuccess = emeraldPremium;
  
  static const LinearGradient buttonDanger = LinearGradient(
    colors: [AppColors.rubyLight, AppColors.rubyError, AppColors.rubyDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ═══════════════════════════════════════════════════════════════════
  // 🎭 AUTH SCREEN GRADIENTS
  // ═══════════════════════════════════════════════════════════════════
  
  static const LinearGradient authBackground = LinearGradient(
    colors: [Color(0xFF0D0D0D), Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient authCard = LinearGradient(
    colors: [Color(0xFF1F1F1F), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient authLogo = LinearGradient(
    colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
