import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';

import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lucide_icons/lucide_icons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isPhoneLogin = _shouldDefaultToEmailAuth();
  bool _obscurePassword = true;

  static bool _shouldDefaultToEmailAuth() {
    if (kIsWeb) return false;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) return false;
    return true;
  }

  static bool _isPhoneAuthSupported() {
    if (kIsWeb) return true;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message), 
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is Authenticated) {
            context.go('/dashboard');
          }
          if (state is OtpSent) {
            context.push('/login/otp', extra: {
              'verificationId': state.verificationId,
              'phoneNumber': _phoneController.text,
            });
          }
        },
        builder: (context, state) {
          if (state is PasswordResetSent) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: GlassCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.success.withOpacity(0.2)),
                        ),
                        child: const Icon(LucideIcons.checkCircle2, size: 48, color: AppColors.success),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'RESET LINK SENT!',
                        style: GoogleFonts.outfit(
                          fontSize: 22, 
                          fontWeight: FontWeight.w900, 
                          color: AppColors.textPrimary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Check your email for password reset instructions',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        text: 'BACK TO LOGIN', 
                        onPressed: () => context.read<AuthCubit>().checkAuth(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return Stack(
            children: [
              // Subtle background glow
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ).animate().fade(duration: 2.seconds),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Luxury Logo Container
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: -5,
                            )
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.shoppingBag, 
                            size: 42, 
                            color: Colors.white,
                          ),
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        'SHOPKEEPER PRO',
                        style: GoogleFonts.outfit(
                          fontSize: 32, 
                          fontWeight: FontWeight.w900, 
                          color: AppColors.textPrimary, 
                          letterSpacing: -0.5,
                        ),
                      ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Executive Retail Management Suite',
                        style: GoogleFonts.outfit(
                          fontSize: 16, 
                          color: AppColors.textSecondary,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
                      
                      const SizedBox(height: 48),
                      
                      // Glass Login Box
                      GlassCard(
                        padding: const EdgeInsets.all(28),
                        backgroundOpacity: 0.12,
                        child: Column(
                          children: [
                            if (_isPhoneAuthSupported()) ...[
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.glassBorder),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildAuthToggleItem('PHONE OTP', _isPhoneLogin, () => setState(() => _isPhoneLogin = true)),
                                    ),
                                    Expanded(
                                      child: _buildAuthToggleItem('EMAIL AUTH', !_isPhoneLogin, () => setState(() => _isPhoneLogin = false)),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.lock, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      'ENTERPRISE EMAIL AUTH', 
                                      style: GoogleFonts.outfit(
                                        fontSize: 11, 
                                        fontWeight: FontWeight.w900, 
                                        color: AppColors.textSecondary,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 32),

                            if (_isPhoneLogin) ...[
                              _buildLuxuryField(
                                controller: _phoneController,
                                label: 'MOBILE NUMBER',
                                hint: '+91 98765 43210',
                                icon: LucideIcons.smartphone,
                                keyboardType: TextInputType.phone,
                              ),
                            ] else ...[
                              _buildLuxuryField(
                                controller: _emailController,
                                label: 'EMAIL ADDRESS',
                                hint: 'owner@shop.com',
                                icon: LucideIcons.mail,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 20),
                              _buildLuxuryField(
                                controller: _passwordController,
                                label: 'PASSWORD',
                                hint: '••••••••',
                                icon: LucideIcons.shieldCheck,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye, 
                                    color: AppColors.textSecondary, 
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    if (_emailController.text.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please enter your email first.')),
                                      );
                                      return;
                                    }
                                    context.read<AuthCubit>().sendPasswordResetEmail(_emailController.text);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'FORGOT PASSWORD?', 
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.0),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 40),
                            
                            if (state is AuthLoading)
                              const Center(child: CircularProgressIndicator(color: AppColors.primary))
                            else
                              PrimaryButton(
                                text: _isPhoneLogin ? 'GET OTP' : 'LOGIN TO SUITE',
                                onPressed: () {
                                  if (_isPhoneLogin) {
                                    context.read<AuthCubit>().loginWithPhone(_phoneController.text);
                                  } else {
                                    context.read<AuthCubit>().loginWithEmail(_emailController.text, _passwordController.text);
                                  }
                                },
                              ),
                          ],
                        ),
                      ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: 32),
                      
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.outfit(
                              fontSize: 16, 
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              const TextSpan(text: "New Shop? "),
                              TextSpan(
                                text: 'Create Suite Account', 
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fade(delay: 500.ms),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAuthToggleItem(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
          border: isActive ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 0.5) : null,
        ),
        child: Center(
          child: Text(
            label, 
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w900, 
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLuxuryField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900, 
            fontSize: 11, 
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary.withOpacity(0.5), size: 18),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

