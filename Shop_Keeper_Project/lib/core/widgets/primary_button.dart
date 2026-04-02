import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';

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
                  AppTheme.primaryOrchid.withOpacity(0.1),
                  AppTheme.secondaryCyan.withOpacity(0.1),
                ],
              )
            : AppTheme.premiumGradient,
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: AppTheme.primaryOrchid.withOpacity(0.3),
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
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                text.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
      ),
    );
  }
}
