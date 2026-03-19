import 'package:flutter/material.dart';

class PinDotsWidget extends StatelessWidget {
  final int pinLength;
  final bool isError;
  final Color primaryColor;

  const PinDotsWidget({
    super.key,
    required this.pinLength,
    this.isError = false,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final bool isFilled = index < pinLength;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutBack,
            width: isFilled ? 18 : 16,
            height: isFilled ? 18 : 16,
            decoration: BoxDecoration(
              color: isError
                  ? Colors.red
                  : isFilled
                      ? primaryColor
                      : Colors.transparent,
              border: Border.all(
                color: isError
                    ? Colors.red
                    : isFilled
                        ? primaryColor
                        : Colors.grey.shade300,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
