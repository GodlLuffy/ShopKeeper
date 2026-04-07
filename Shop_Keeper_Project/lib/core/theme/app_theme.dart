import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppSpacing {
  AppSpacing._();
  
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;
  static const double radiusXxl = 28.0;
  static const double radiusFull = 100.0;
  
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: base, vertical: lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 20);
  
  static const double buttonHeight = 60.0;
  static const double buttonHeightSm = 48.0;
  
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
}

class AppGradients {
  AppGradients._();
  
  static const LinearGradient goldPremium = LinearGradient(
    colors: [Color(0xFFE8C969), Color(0xFFD4AF37), Color(0xFFB8962E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient emeraldSuccess = LinearGradient(
    colors: [AppColors.success, Color(0xFF34D4A1), AppColors.success],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient sapphireInfo = LinearGradient(
    colors: [AppColors.info, Color(0xFF63A4FF), AppColors.info],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkSurface = LinearGradient(
    colors: [Color(0xFF1F1F1F), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient lightSurface = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  AppTheme._();

  static List<BoxShadow> get premiumShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.35),
      blurRadius: 40,
      offset: const Offset(0, 20),
      spreadRadius: -10,
    ),
  ];

  static List<BoxShadow> get goldGlow => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.2),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  static BoxDecoration glassDecoration({
    double borderRadius = 24,
    bool isDark = true,
  }) =>
      BoxDecoration(
        color: isDark 
            ? AppColors.surface.withOpacity(0.4) 
            : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark ? AppColors.glassBorder : Colors.black.withOpacity(0.05),
          width: 0.8,
        ),
      );

  static BoxDecoration statCardDecoration({
    required bool isDark,
    Color? accentColor,
  }) {
    final bgColor = isDark ? AppColors.surface : Colors.white;
    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      border: Border.all(
        color: isDark ? AppColors.glassBorder : Colors.black.withOpacity(0.05),
        width: 0.8,
      ),
      boxShadow: [
        BoxShadow(
          color: (accentColor ?? AppColors.primary).withOpacity(isDark ? 0.08 : 0.04),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.background,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimaryContainer: AppColors.primary,
        onSecondaryContainer: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.glassBorder,
        outlineVariant: Color(0x0FFFFFFF),
      ),

      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          letterSpacing: -1.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -1.0,
        ),
        displaySmall: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.outfit(
          fontSize: 36,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          letterSpacing: -1.0,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        bodySmall: GoogleFonts.outfit(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          letterSpacing: 1.5,
        ),
      ),

      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          side: const BorderSide(color: AppColors.glassBorder, width: 0.8),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 4,
        shape: CircleBorder(),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: AppSpacing.inputPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.glassBorder, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: GoogleFonts.outfit(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: GoogleFonts.outfit(
          color: AppColors.textMuted,
        ),
        errorStyle: GoogleFonts.outfit(
          color: AppColors.error,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        prefixIconColor: AppColors.primary,
        suffixIconColor: AppColors.textSecondary,
      ),

      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 1,
        space: 1,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withOpacity(0.15),
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            );
          }
          return GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 24);
        }),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withOpacity(0.15),
        labelStyle: GoogleFonts.outfit(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        side: const BorderSide(color: AppColors.glassBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),

      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        ),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXxl)),
        ),
        dragHandleColor: AppColors.textSecondary,
        dragHandleSize: Size(40, 4),
      ),

      tabBarTheme: TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        labelStyle: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.glassBorder,
        circularTrackColor: AppColors.glassBorder,
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.glassBorder,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.12),
        trackHeight: 4,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withOpacity(0.3);
          }
          return AppColors.glassBorder;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.background),
        side: const BorderSide(color: AppColors.glassBorder, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.glassBorder),
        ),
        textStyle: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // Legacy color getters forwarding to AppColors
  static Color get primaryIndigo => AppColors.primary;
  static Color get accentTeal => AppColors.success;
  static Color get darkBackgroundMain => AppColors.background;
  static Color get darkBackgroundLayer => AppColors.surface;
  static Color get textWhite => AppColors.textPrimary;
  static Color get textMuted => AppColors.textSecondary;
  static Color get textGrey => AppColors.textSecondary;
  static Color get dangerRose => AppColors.error;
  static Color get successEmerald => AppColors.success;
  static Color get warningAmber => AppColors.warning;
  static Color get primaryOrchid => AppColors.primaryOrchid;
  static Color get secondaryCyan => AppColors.secondaryCyan;
  static Color get lightBackgroundMain => AppColors.lightBackgroundMain;
  static Color get textDarkGrey => AppColors.textDarkGrey;
  static Color get textBlack => AppColors.textBlack;
  static Color get backgroundColor => AppColors.background;
  static LinearGradient get premiumGradient => AppColors.goldGradient;
  static List<BoxShadow> get orchidGlowShadow => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme(ThemeData.light().textTheme);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(0xFFFBFBFB),
      
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        surface: Colors.white,
        error: AppColors.error,
        onPrimaryContainer: AppColors.primary,
        onSecondaryContainer: Color(0xFF121212),
        onSurface: Color(0xFF121212),
        onSurfaceVariant: Color(0xFF666666),
        outline: Color(0xFFE5E5E5),
        outlineVariant: Color(0xFFF0F0F0),
      ),

      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF121212),
          letterSpacing: -1.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF121212),
          letterSpacing: -1.0,
        ),
        displaySmall: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF121212),
          letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.outfit(
          fontSize: 36,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF121212),
          letterSpacing: -1.0,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF121212),
          letterSpacing: -0.5,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF121212),
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF121212),
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF121212),
        ),
        titleSmall: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF666666),
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF121212),
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 15,
          color: const Color(0xFF121212),
        ),
        bodySmall: GoogleFonts.outfit(
          fontSize: 13,
          color: const Color(0xFF666666),
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF121212),
          letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF666666),
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF999999),
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: Color(0xFF121212), size: 24),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Color(0xFF121212),
          letterSpacing: 1.5,
        ),
      ),

      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          side: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        contentPadding: AppSpacing.inputPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: GoogleFonts.outfit(
          color: const Color(0xFF666666),
          fontWeight: FontWeight.w600,
        ),
        hintStyle: GoogleFonts.outfit(
          color: const Color(0xFF999999),
        ),
        errorStyle: GoogleFonts.outfit(
          color: AppColors.error,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        prefixIconColor: AppColors.primary,
        suffixIconColor: const Color(0xFF666666),
      ),

      iconTheme: const IconThemeData(
        color: Color(0xFF666666),
        size: 24,
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E5E5),
        thickness: 1,
        space: 1,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: const Color(0xFF666666),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withOpacity(0.1),
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            );
          }
          return GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF666666),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: Color(0xFF666666), size: 24);
        }),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF3F4F6),
        selectedColor: AppColors.primary.withOpacity(0.1),
        labelStyle: GoogleFonts.outfit(
          color: const Color(0xFF666666),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF121212),
        contentTextStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),

      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        ),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF121212),
        ),
        contentTextStyle: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF666666),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXxl)),
        ),
        dragHandleColor: Color(0xFF666666),
        dragHandleSize: Size(40, 4),
      ),

      tabBarTheme: TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: const Color(0xFF666666),
        indicatorColor: AppColors.primary,
        labelStyle: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: Color(0xFFE5E5E5),
        circularTrackColor: Color(0xFFE5E5E5),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: const Color(0xFFE5E5E5),
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.12),
        trackHeight: 4,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return const Color(0xFF666666);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withOpacity(0.3);
          }
          return const Color(0xFFE5E5E5);
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: Color(0xFFE5E5E5), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return const Color(0xFF666666);
        }),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
