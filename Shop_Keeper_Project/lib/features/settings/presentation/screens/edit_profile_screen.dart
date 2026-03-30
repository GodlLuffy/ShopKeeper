import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
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
      AppErrorHandler.showSuccess(context, AppStrings.get('config_updated'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackgroundMain,
      appBar: AppBar(
        title: Text(AppStrings.get('edit_config'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  AppTheme.accentTeal.withOpacity(0.03),
                  Colors.transparent,
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryIndigo, AppTheme.accentTeal],
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 54,
                        backgroundColor: AppTheme.darkBackgroundLayer,
                        child: Icon(Icons.settings_suggest_rounded, size: 48, color: AppTheme.accentTeal),
                      ),
                    ),
                    const SizedBox(height: 48),
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.get('core_parameters'),
                              style: const TextStyle(
                                fontSize: 12, 
                                fontWeight: FontWeight.w900, 
                                color: AppTheme.accentTeal,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            CustomTextField(
                              controller: _shopNameController,
                              label: AppStrings.get('shop_designation'),
                              hintText: AppStrings.get('search_products'), // Reusing search as placeholder or generic
                              prefixIcon: Icons.storefront_rounded,
                              validator: (value) => (value == null || value.isEmpty) ? AppStrings.get('product_name_required') : null,
                            ),
                            const SizedBox(height: 24),
                            CustomTextField(
                              controller: _nameController,
                              label: AppStrings.get('operator_name'),
                              hintText: AppStrings.get('operator_name'),
                              prefixIcon: Icons.badge_outlined,
                              validator: (value) => (value == null || value.isEmpty) ? AppStrings.get('product_name_required') : null,
                            ),
                            const SizedBox(height: 24),
                            CustomTextField(
                              controller: _phoneController,
                              label: AppStrings.get('terminal_link'),
                              hintText: userPhoneNumberHint(), // Dummy helper
                              prefixIcon: Icons.phone_iphone_rounded,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 24),
                            CustomTextField(
                              controller: _emailController,
                              label: AppStrings.get('recovery_data'),
                              hintText: 'Enter email',
                              prefixIcon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    PrimaryButton(
                      onPressed: _saveProfile,
                      text: AppStrings.get('save_profile'),
                      isLoading: state is AuthLoading,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String userPhoneNumberHint() {
    return AppStrings.currentLanguage == AppLanguage.english ? 'Enter phone number' : 'फोन नंबर दर्ज करें';
  }
}
