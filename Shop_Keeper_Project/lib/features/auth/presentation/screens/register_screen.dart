import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/custom_text_field.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _shopNameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _shopNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackgroundMain,
      appBar: AppBar(
        title: Text(
          AppStrings.get('create_shop_account'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textWhite),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.toUpperCase()),
                backgroundColor: AppTheme.dangerRose,
                duration: const Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
          if (state is Authenticated) {
            context.go('/dashboard');
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              children: [
                // Header Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryIndigo.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryIndigo.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.add_business_rounded, size: 40, color: AppTheme.primaryIndigo),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 24),

                Text(
                  AppStrings.get('new_shop_hint'),
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 200.ms),

                const SizedBox(height: 32),

                GlassCard(
                  child: Column(
                    children: [
                      CustomTextField(
                        label: AppStrings.get('owner_name'),
                        controller: _nameController,
                        hintText: 'John Doe',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: AppStrings.get('shop_name'),
                        controller: _shopNameController,
                        hintText: 'My Amazing Store',
                        prefixIcon: Icons.storefront_rounded,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: AppStrings.get('email_address'),
                        controller: _emailController,
                        hintText: 'owner@example.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: AppStrings.get('password'),
                        controller: _passwordController,
                        hintText: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: const Icon(Icons.visibility_off_outlined, color: AppTheme.textMuted, size: 20),
                      ),
                      const SizedBox(height: 32),
                      
                      if (state is AuthLoading)
                        const Center(child: CircularProgressIndicator(color: AppTheme.primaryIndigo))
                      else
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryIndigo, AppTheme.accentTeal],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryIndigo.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_nameController.text.isEmpty || 
                                  _emailController.text.isEmpty || 
                                  _passwordController.text.isEmpty || 
                                  _shopNameController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('PLEASE FILL ALL FIELDS')),
                                );
                                return;
                              }
                              context.read<AuthCubit>().register(
                                    _nameController.text.trim(),
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                    _shopNameController.text.trim(),
                                  );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              AppStrings.get('create_shop'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ).animate().fade(delay: 300.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    AppStrings.get('already_have_account'),
                    style: const TextStyle(
                      color: AppTheme.primaryIndigo,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ).animate().fade(delay: 500.ms),
              ],
            ),
          );
        },
      ),
    );
  }
}
