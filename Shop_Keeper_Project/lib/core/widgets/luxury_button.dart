import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class LuxuryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;

  const LuxuryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<LuxuryButton> createState() => _LuxuryButtonState();
}

class _LuxuryButtonState extends State<LuxuryButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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
    final bool isDisabled = widget.onPressed == null || widget.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: Container(
          width: widget.width ?? double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: widget.isOutlined || isDisabled
                ? null
                : const LinearGradient(
                    colors: [Color(0xFFE8C969), Color(0xFFD4AF37), Color(0xFFB8962E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: widget.isOutlined
                ? Colors.transparent
                : (isDisabled
                    ? (isDark
                        ? AppColors.surface.withOpacity(0.5)
                        : const Color(0xFFF3F4F6))
                    : (widget.backgroundColor ?? AppColors.primary)),
            border: widget.isOutlined
                ? Border.all(
                    color: isDisabled
                        ? AppColors.glassBorder
                        : (widget.textColor ?? AppColors.primary),
                    width: 1.5,
                  )
                : null,
            boxShadow: widget.isOutlined || isDisabled
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: -2,
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      widget.onPressed?.call();
                    },
              borderRadius: BorderRadius.circular(20),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.isOutlined
                                ? (widget.textColor ?? AppColors.primary)
                                : AppColors.background,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: 20,
                              color: widget.isOutlined
                                  ? (widget.textColor ?? AppColors.primary)
                                  : AppColors.background,
                            ),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            widget.text.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: widget.isOutlined
                                  ? (widget.textColor ?? AppColors.primary)
                                  : (widget.textColor ?? AppColors.background),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return LuxuryButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final LinearGradient? gradient;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isDisabled
            ? LinearGradient(
                colors: [
                  (isDark ? AppColors.surface : const Color(0xFFF3F4F6))
                      .withOpacity(0.5),
                  (isDark ? AppColors.surface : const Color(0xFFF3F4F6))
                      .withOpacity(0.3),
                ],
              )
            : (gradient ?? AppColors.goldGradient),
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -2,
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onPressed?.call();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.background,
                  strokeWidth: 3,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppColors.background, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    text.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.background,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
