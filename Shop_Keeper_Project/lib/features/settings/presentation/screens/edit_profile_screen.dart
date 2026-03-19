import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/custom_text_field.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/primary_button.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Edit Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                   const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(Icons.edit_note, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 32),
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Business Information',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            controller: _shopNameController,
                            label: 'Shop Name',
                            hintText: 'Enter shop name',
                            prefixIcon: Icons.storefront,
                            validator: (value) => (value == null || value.isEmpty) ? 'Please enter shop name' : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _nameController,
                            label: 'Owner Name',
                            hintText: 'Enter owner name',
                            prefixIcon: Icons.person_outline,
                            validator: (value) => (value == null || value.isEmpty) ? 'Please enter owner name' : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            hintText: 'Enter phone number',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hintText: 'Enter email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  PrimaryButton(
                    onPressed: _saveProfile,
                    text: 'Save Changes',
                    isLoading: state is AuthLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
