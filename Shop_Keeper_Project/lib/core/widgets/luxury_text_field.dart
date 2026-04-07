import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class LuxuryTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? hintText;
  final bool readOnly;
  final bool obscureText;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final int? maxLines;
  final int? maxLength;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;

  const LuxuryTextField({
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
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.textInputAction,
    this.focusNode,
    this.onEditingComplete,
  });

  @override
  State<LuxuryTextField> createState() => _LuxuryTextFieldState();
}

class _LuxuryTextFieldState extends State<LuxuryTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textSecondary : const Color(0xFF666666),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          validator: widget.validator,
          onChanged: widget.onChanged,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          autofocus: widget.autofocus,
          textInputAction: widget.textInputAction,
          focusNode: _focusNode,
          onEditingComplete: widget.onEditingComplete,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textPrimary : const Color(0xFF121212),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppColors.surface : const Color(0xFFF3F4F6),
            hintText: widget.hintText,
            hintStyle: GoogleFonts.outfit(
              fontSize: 15,
              color: isDark ? AppColors.textMuted : const Color(0xFF999999),
              fontWeight: FontWeight.w400,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? AppColors.glassBorder : Colors.black.withOpacity(0.05),
                width: 0.8,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
          ),
        ),
      ],
    );
  }
}

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
    return LuxuryTextField(
      label: label,
      controller: controller,
      keyboardType: keyboardType,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.primary, size: 20)
          : null,
      hintText: hintText,
      readOnly: readOnly,
      obscureText: obscureText,
      onTap: onTap,
      validator: validator,
      onChanged: onChanged,
    );
  }
}

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final bool readOnly;
  final Widget? suffixIcon;

  const SearchField({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onTap,
    this.onClear,
    this.readOnly = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.glassBorder : Colors.black.withOpacity(0.05),
          width: 0.8,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textPrimary : const Color(0xFF121212),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.outfit(
            fontSize: 15,
            color: isDark ? AppColors.textMuted : const Color(0xFF999999),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? AppColors.textSecondary : const Color(0xFF666666),
            size: 22,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? AppColors.textSecondary : const Color(0xFF666666),
                    size: 20,
                  ),
                  onPressed: () {
                    controller.clear();
                    onClear?.call();
                  },
                )
              : suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
