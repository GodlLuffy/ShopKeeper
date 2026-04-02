import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isPhoneLogin = true;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundMain,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: const Color(0xFFEF4444)),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.successEmerald.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, size: 48, color: AppTheme.successEmerald),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Reset Link Sent!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Check your email for password reset instructions',
                    style: TextStyle(color: AppTheme.textDarkGrey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.read<AuthCubit>().checkAuth(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryIndigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text('Back to Login'),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3B1A7A), Color(0xFF5F259F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.storefront_rounded, size: 48, color: Colors.white),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'ShopKeeper PRO',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textBlack, letterSpacing: -0.5),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Sign in to manage your retail business',
                    style: TextStyle(fontSize: 15, color: AppTheme.textDarkGrey),
                    textAlign: TextAlign.center,
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
                  
                  const SizedBox(height: 48),
                  
                  // Login Box
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8))],
                    ),
                    child: Column(
                      children: [
                        // Toggle Login Type
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isPhoneLogin = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _isPhoneLogin ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: _isPhoneLogin ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
                                    ),
                                    child: Center(
                                      child: Text('Phone OTP', style: TextStyle(fontWeight: FontWeight.w600, color: _isPhoneLogin ? const Color(0xFF1E293B) : const Color(0xFF64748B))),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isPhoneLogin = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !_isPhoneLogin ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: !_isPhoneLogin ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
                                    ),
                                    child: Center(
                                      child: Text('Email Auth', style: TextStyle(fontWeight: FontWeight.w600, color: !_isPhoneLogin ? const Color(0xFF1E293B) : const Color(0xFF64748B))),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),

                        if (_isPhoneLogin) ...[
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Mobile Number',
                            hint: '+91 98765 43210',
                            icon: Icons.phone_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                        ] else ...[
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'owner@shop.com',
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: '••••••••',
                            icon: Icons.lock_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: const Color(0xFF94A3B8), size: 22),
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Password reset link sent to your email!')),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF5F259F),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('Forgot Password?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                        
                        if (state is AuthLoading)
                          const CircularProgressIndicator(color: Color(0xFF5F259F))
                        else
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_isPhoneLogin) {
                                  context.read<AuthCubit>().loginWithPhone(_phoneController.text);
                                } else {
                                  context.read<AuthCubit>().loginWithEmail(_emailController.text, _passwordController.text);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5F259F),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text(_isPhoneLogin ? 'GET OTP' : 'LOGIN', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            ),
                          ),
                      ],
                    ),
                  ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 32),
                  
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('New Shop? Create Account', style: TextStyle(color: AppTheme.primaryIndigo, fontWeight: FontWeight.bold, fontSize: 16)),
                  ).animate().fade(delay: 500.ms),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 22),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF5F259F), width: 1.5)),
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
