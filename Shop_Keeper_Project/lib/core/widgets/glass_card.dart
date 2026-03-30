import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final double borderOpacity;
  final double backgroundOpacity;
  final double sigma;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius = 24,
    this.borderOpacity = 0.1,
    this.backgroundOpacity = 0.05,
    this.sigma = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black;
    final glassColor = isDark 
        ? Colors.white.withOpacity(backgroundOpacity) 
        : Colors.white.withOpacity(0.7); // Light mode glass is more opaque white

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: glassColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: baseColor.withOpacity(isDark ? borderOpacity : 0.05), 
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppTheme.primaryIndigo : Colors.black).withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 10),
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
              highlightColor: baseColor.withOpacity(0.05),
              splashColor: AppTheme.primaryIndigo.withOpacity(0.1),
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
