import 'package:flutter/material.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const GradientButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Center(
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.background,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
