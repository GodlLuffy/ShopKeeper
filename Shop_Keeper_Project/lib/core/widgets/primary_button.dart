import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isDisabled
            ? LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                ],
              )
            : AppColors.goldGradient,
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                  spreadRadius: -5,
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled
            ? null
            : () {
                HapticFeedback.mediumImpact();
                if (onPressed != null) onPressed!();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 3,
                ),
              )
            : Text(
                text.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 2,
                ),
              ),
      ),
    );
  }
}

