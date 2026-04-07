import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/custom_text_field.dart';
import 'package:shop_keeper_project/core/widgets/primary_button.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
  bool _obscurePassword = true;

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.get('create_shop_account').toUpperCase(),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900, 
            fontSize: 14, 
            letterSpacing: 2,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary, size: 22),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.toUpperCase()),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is Authenticated) {
            context.go('/dashboard');
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Subtle background glow
              Positioned(
                bottom: -150,
                left: -100,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.04),
                    shape: BoxShape.circle,
                  ),
                ).animate().fade(duration: 2.seconds),
              ),

              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Header Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: -2,
                          )
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.store, 
                          size: 32, 
                          color: Colors.white,
                        ),
                      ),
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 24),

                    Text(
                      'ESTABLISH YOUR FRANCHISE',
                      style: GoogleFonts.outfit(
                        fontSize: 22, 
                        fontWeight: FontWeight.w900, 
                        color: AppColors.textPrimary,
                        letterSpacing: 1.0,
                      ),
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

                    const SizedBox(height: 8),

                    Text(
                      AppStrings.get('new_shop_hint'),
                      style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14),
                      textAlign: TextAlign.center,
                    ).animate().fade(delay: 300.ms),

                    const SizedBox(height: 40),

                    GlassCard(
                      padding: const EdgeInsets.all(28),
                      backgroundOpacity: 0.12,
                      child: Column(
                        children: [
                          CustomTextField(
                            label: AppStrings.get('owner_name'),
                            controller: _nameController,
                            hintText: 'John Doe',
                            prefixIcon: LucideIcons.user,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            label: AppStrings.get('shop_name'),
                            controller: _shopNameController,
                            hintText: 'My Amazing Store',
                            prefixIcon: LucideIcons.store,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            label: AppStrings.get('email_address'),
                            controller: _emailController,
                            hintText: 'owner@example.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: LucideIcons.mail,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            label: AppStrings.get('password'),
                            controller: _passwordController,
                            hintText: '••••••••',
                            prefixIcon: LucideIcons.shieldCheck,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye, color: AppColors.textSecondary, size: 20),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          const SizedBox(height: 40),
                          
                          if (state is AuthLoading)
                            const Center(child: CircularProgressIndicator(color: AppColors.primary))
                          else
                            PrimaryButton(
                              text: 'INITIALIZE SUITE',
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
                            ),
                        ],
                      ),
                    ).animate().fade(delay: 400.ms).slideY(begin: 0.1),

                    const SizedBox(height: 32),

                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.outfit(
                            fontSize: 15, 
                            color: AppColors.textSecondary,
                          ),
                          children: const [
                            TextSpan(text: "Already a member? "),
                            TextSpan(
                              text: 'Access Suite', 
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fade(delay: 500.ms),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

