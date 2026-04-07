import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';

import 'package:shop_keeper_project/core/widgets/custom_text_field.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/primary_button.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:shop_keeper_project/core/utils/app_error_handler.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _shopNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthCubit>().state;
    if (state is Authenticated) {
      _nameController = TextEditingController(text: state.user.name);
      _shopNameController = TextEditingController(text: state.user.shopName);
      _phoneController = TextEditingController(text: state.user.phoneNumber);
      _emailController = TextEditingController(text: state.user.email);
    } else if (state is PinRequired) {
      _nameController = TextEditingController(text: state.user.name);
      _shopNameController = TextEditingController(text: state.user.shopName);
      _phoneController = TextEditingController(text: state.user.phoneNumber);
      _emailController = TextEditingController(text: state.user.email);
    } else {
      _nameController = TextEditingController();
      _shopNameController = TextEditingController();
      _phoneController = TextEditingController();
      _emailController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shopNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().updateUserProfile(
            name: _nameController.text.trim(),
            shopName: _shopNameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            email: _emailController.text.trim(),
          );
      Navigator.pop(context);
      AppErrorHandler.showSuccess(context, 'BUSINESS CONFIGURATION UPDATED');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.get('edit_config').toUpperCase(), 
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.goldGradient,
                    ),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.black,
                      child: Icon(LucideIcons.settings2, size: 48, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 48),
                  GlassCard(
                    padding: const EdgeInsets.all(24.0),
                    backgroundOpacity: 0.05,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.get('core_parameters').toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 10, 
                            fontWeight: FontWeight.w900, 
                            color: AppColors.primary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 32),
                        CustomTextField(
                          controller: _shopNameController,
                          label: AppStrings.get('shop_designation').toUpperCase(),
                          hintText: 'Enter Business Name',
                          prefixIcon: LucideIcons.store,
                          validator: (value) => (value == null || value.isEmpty) ? AppStrings.get('product_name_required') : null,
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          controller: _nameController,
                          label: AppStrings.get('operator_name').toUpperCase(),
                          hintText: 'Enter Operator Name',
                          prefixIcon: LucideIcons.user,
                          validator: (value) => (value == null || value.isEmpty) ? AppStrings.get('product_name_required') : null,
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          controller: _phoneController,
                          label: AppStrings.get('terminal_link').toUpperCase(),
                          hintText: 'Enter Terminal Contact',
                          prefixIcon: LucideIcons.smartphone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          controller: _emailController,
                          label: AppStrings.get('recovery_data').toUpperCase(),
                          hintText: 'Enter Recovery Email',
                          prefixIcon: LucideIcons.mail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  PrimaryButton(
                    onPressed: _saveProfile,
                    text: AppStrings.get('save_config'),
                    isLoading: state is AuthLoading,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

