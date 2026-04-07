import 'package:flutter/material.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            width: isFilled ? 18 : 14,
            height: isFilled ? 18 : 14,
            decoration: BoxDecoration(
              color: isError
                  ? AppColors.error
                  : isFilled
                      ? AppColors.primary
                      : Colors.transparent,
              boxShadow: isFilled && !isError
                  ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, spreadRadius: 1)]
                  : isError
                      ? [BoxShadow(color: AppColors.error.withOpacity(0.3), blurRadius: 10, spreadRadius: 1)]
                      : [],
              border: Border.all(
                color: isError
                    ? AppColors.error
                    : isFilled
                        ? AppColors.primary
                        : AppColors.glassBorder,
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
