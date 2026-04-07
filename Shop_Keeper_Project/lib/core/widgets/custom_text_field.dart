import 'package:flutter/material.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
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
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primary.withOpacity(0.5), size: 18) : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

