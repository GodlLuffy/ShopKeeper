import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final double borderOpacity;
  final double backgroundOpacity;
  final double sigma;
  final Color? color;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius = 24,
    this.borderOpacity = 0.1,
    this.backgroundOpacity = 0.1,
    this.sigma = 20,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor = color ?? (isDark 
        ? AppColors.surface.withOpacity(backgroundOpacity) 
        : Colors.white.withOpacity(0.7));

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: glassColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? (isDark ? AppColors.glassBorder : Colors.black.withOpacity(0.08)), 
          width: 0.8,
        ),
        boxShadow: isDark ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: -10,
            offset: const Offset(0, 15),
          )
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              highlightColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
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

