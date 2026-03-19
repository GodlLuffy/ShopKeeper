import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [1, 2, 3].map(_buildButton).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [4, 5, 6].map(_buildButton).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [7, 8, 9].map(_buildButton).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (onBiometricTap != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onBiometricTap!();
                },
                child: Container(
                  width: 70,
                  height: 70,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: const Icon(Icons.fingerprint, size: 36, color: Color(0xFF5F259F)),
                ),
              )
            else
              const SizedBox(width: 70, height: 70),
              
            _buildButton(0),
            
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onDeleteTap();
              },
              child: Container(
                width: 70,
                height: 70,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: const Icon(Icons.backspace_outlined, size: 28, color: Color(0xFF64748B)),
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
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: const Color(0xFF5F259F).withOpacity(0.1),
        highlightColor: const Color(0xFF5F259F).withOpacity(0.05),
        child: Container(
          width: 70,
          height: 70,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ),
    );
  }
}
