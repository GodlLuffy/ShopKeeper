import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();
  
  // ═══════════════════════════════════════════════════════════════════
  // 📐 BASE SPACING UNIT (4px grid system)
  // ═══════════════════════════════════════════════════════════════════
  
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 48.0;
  static const double massive = 64.0;
  
  // ═══════════════════════════════════════════════════════════════════
  // 📐 PADDING PRESETS
  // ═══════════════════════════════════════════════════════════════════
  
  static const EdgeInsets paddingXxs = EdgeInsets.all(xxs);
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingBase = EdgeInsets.all(base);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);
  static const EdgeInsets paddingXxxl = EdgeInsets.all(xxxl);
  
  // ═══════════════════════════════════════════════════════════════════
  // 📐 HORIZONTAL PADDING
  // ═══════════════════════════════════════════════════════════════════
  
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalBase = EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets horizontalXxl = EdgeInsets.symmetric(horizontal: xxl);
  
  // ═══════════════════════════════════════════════════════════════════
  // 📐 VERTICAL PADDING
  // ═══════════════════════════════════════════════════════════════════
  
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalBase = EdgeInsets.symmetric(vertical: base);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets verticalXxl = EdgeInsets.symmetric(vertical: xxl);
  
  // ═══════════════════════════════════════════════════════════════════
  // 📐 SCREEN PADDING (with safe area awareness)
  // ═══════════════════════════════════════════════════════════════════
  
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: base, vertical: lg);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets screenPaddingVertical = EdgeInsets.symmetric(vertical: lg);
  
  // ═══════════════════════════════════════════════════════════════════
  // 📐 CARD PADDING
  // ═══════════════════════════════════════════════════════════════════
  
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingSm = EdgeInsets.all(md);
  static const EdgeInsets cardPaddingLg = EdgeInsets.all(xl);
  static const EdgeInsets cardInnerPadding = EdgeInsets.all(base);
  
  // ═══════════════════════════════════════════════════════════════════
  // 📐 INPUT FIELD PADDING
  // ═══════════════════════════════════════════════════════════════════
  
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: base, vertical: md);
  static const EdgeInsets inputPaddingLg = EdgeInsets.symmetric(horizontal: lg, vertical: xl);
  
  // ═══════════════════════════════════════════════════════════════════
  // 📐 LIST ITEM SPACING
  // ═══════════════════════════════════════════════════════════════════
  
  static const double listItemSpacing = md;
  static const double listSectionSpacing = xxl;
  
  // ═══════════════════════════════════════════════════════════════════
  // 📐 BUTTON SPACING
  // ═══════════════════════════════════════════════════════════════════
  
  static const double buttonHeightSm = 40.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;
  static const double buttonHeightXl = 64.0;
  
  static const double buttonRadiusSm = 8.0;
  static const double buttonRadiusMd = 12.0;
  static const double buttonRadiusLg = 16.0;
  static const double buttonRadiusXl = 24.0;
  
  // ═══════════════════════════════════════════════════════════════════
  // 📐 CARD RADII
  // ═══════════════════════════════════════════════════════════════════
  
  static const double radiusXxs = 4.0;
  static const double radiusXs = 8.0;
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;
  static const double radiusXxl = 28.0;
  static const double radiusFull = 100.0;
  
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius cardRadiusSm = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius cardRadiusLg = BorderRadius.all(Radius.circular(radiusXxl));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(radiusFull));
  
  // ═══════════════════════════════════════════════════════════════════
  // 📐 ICON SIZES
  // ═══════════════════════════════════════════════════════════════════
  
  static const double iconXxs = 12.0;
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 40.0;
  static const double iconXxl = 48.0;
  
  // ═══════════════════════════════════════════════════════════════════
  // 📐 AVATAR SIZES
  // ═══════════════════════════════════════════════════════════════════
  
  static const double avatarXs = 24.0;
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 72.0;
  static const double avatarXxl = 96.0;
  
  // ═══════════════════════════════════════════════════════════════════
  // 📐 ELEVATION LEVELS
  // ═══════════════════════════════════════════════════════════════════
  
  static const double elevationNone = 0.0;
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;
  static const double elevationXxl = 24.0;
}
