import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class LuxuryCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final bool enableGlassmorphism;
  final Color? accentColor;
  final bool showBorder;

  const LuxuryCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius = 24,
    this.enableGlassmorphism = false,
    this.accentColor,
    this.showBorder = true,
  });

  @override
  State<LuxuryCard> createState() => _LuxuryCardState();
}

class _LuxuryCardState extends State<LuxuryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.accentColor ?? AppColors.primary;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: widget.showBorder
              ? Border.all(
                  color: isDark ? AppColors.glassBorder : Colors.black.withOpacity(0.05),
                  width: 0.8,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(isDark ? 0.08 : 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: widget.enableGlassmorphism
              ? BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: _buildContent(isDark, accent),
                )
              : _buildContent(isDark, accent),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark, Color accent) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        highlightColor: accent.withOpacity(0.05),
        splashColor: accent.withOpacity(0.1),
        child: Padding(
          padding: widget.padding ?? const EdgeInsets.all(20),
          child: widget.child,
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? accentColor;
  final String? subtitle;
  final Widget? trend;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.accentColor,
    this.subtitle,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? AppColors.primary;

    return LuxuryCard(
      accentColor: accent,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withOpacity(isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 24,
                ),
              ),
              if (trend != null) trend!,
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondary : const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimary : const Color(0xFF121212),
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: accent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius = 24,
    this.blur = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (isDark ? Colors.white : Colors.white).withOpacity(isDark ? 0.05 : 0.6),
            (isDark ? Colors.white : Colors.white).withOpacity(isDark ? 0.02 : 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark
              ? AppColors.glassBorder
              : Colors.black.withOpacity(0.05),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(isDark ? 0.04 : 0.02),
            blurRadius: 40,
            spreadRadius: -10,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              highlightColor: Colors.white.withOpacity(0.05),
              splashColor: AppColors.primary.withOpacity(0.1),
              child: Padding(
                padding: padding ?? const EdgeInsets.all(20),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? glowColor;

  const PremiumGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = glowColor ?? AppColors.primary;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (isDark ? const Color(0xFF252525) : Colors.white)
                .withOpacity(0.9),
            (isDark ? AppColors.surface : const Color(0xFFFAFAFA))
                .withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? accent.withOpacity(0.2)
              : accent.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}
