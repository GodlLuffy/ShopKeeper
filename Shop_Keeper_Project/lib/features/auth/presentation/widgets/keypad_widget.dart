import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';

class KeypadWidget extends StatelessWidget {
  final Function(int) onNumberTap;
  final VoidCallback onDeleteTap;
  final VoidCallback? onBiometricTap;

  const KeypadWidget({
    super.key,
    required this.onNumberTap,
    required this.onDeleteTap,
    this.onBiometricTap,
  });

  Widget _buildButton(int number) {
    return PinKeypadButton(
      text: number.toString(),
      onTap: () {
        HapticFeedback.lightImpact();
        onNumberTap(number);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [1, 2, 3].map((n) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildButton(n),
          )).toList(),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [4, 5, 6].map((n) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildButton(n),
          )).toList(),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [7, 8, 9].map((n) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildButton(n),
          )).toList(),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 70,
                height: 70,
                child: onBiometricTap != null
                    ? IconButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          onBiometricTap!();
                        },
                        icon: const Icon(LucideIcons.fingerprint, size: 28, color: AppColors.primary),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildButton(0),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 70,
                height: 70,
                child: IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onDeleteTap();
                  },
                  icon: const Icon(LucideIcons.delete, size: 24, color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PinKeypadButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const PinKeypadButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
