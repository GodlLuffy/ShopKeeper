import 'package:flutter/material.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final String? hintText;
  final bool readOnly;
  final bool obscureText;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.prefixIcon,
    this.hintText,
    this.readOnly = false,
    this.obscureText = false,
    this.onTap,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          onChanged: onChanged,
          style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: (isDark ? Colors.black : Colors.grey).withOpacity(0.05),
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primaryIndigo, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.dangerRose, width: 1),
            ),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.accentTeal, size: 20) : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
