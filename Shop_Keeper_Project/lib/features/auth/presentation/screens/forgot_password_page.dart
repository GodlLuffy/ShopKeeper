import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Timer? _resendTimer;
  int _resendCountdown = 0;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  void _sendResetEmail() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().sendPasswordResetEmail(
        _emailController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackgroundMain,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetSent) {
            setState(() => _emailSent = true);
            _startResendTimer();
            _showSuccessSnackBar(context, state.email);
          }
          if (state is AuthError) {
            _showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              _buildBackground(),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildHeader(),
                        const SizedBox(height: 48),
                        _emailSent ? _buildSuccessCard() : _buildEmailForm(state),
                      ],
                    ),
                  ),
                ),
              ),
              if (state is AuthLoading) _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryIndigo.withOpacity(0.05),
            AppColors.primaryIndigo.withOpacity(0.02),
            Colors.white,
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppColors.primaryIndigo,
              ),
              const SizedBox(height: 16),
              Text(
                'Sending reset link...',
                style: TextStyle(
                  color: AppColors.textDarkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryIndigo,
                AppColors.primaryIndigo.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryIndigo.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            size: 32,
            color: Colors.white,
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                  letterSpacing: -0.5,
                ),
              ).animate().fade(delay: 100.ms).slideX(begin: 0.1),
              const SizedBox(height: 4),
              Text(
                'We\'ll help you get back in',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textDarkGrey.withOpacity(0.8),
                ),
              ).animate().fade(delay: 200.ms),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm(AuthState state) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryIndigo.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email Address',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDarkGrey,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'name@shop.com',
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryIndigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      color: AppColors.primaryIndigo,
                      size: 20,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.lightBackgroundMain,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ).animate().fade(delay: 300.ms),
            ],
          ),
        ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: state is AuthLoading ? null : _sendResetEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryIndigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_rounded, size: 22),
                SizedBox(width: 10),
                Text(
                  'Send Reset Link',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
        const SizedBox(height: 32),
        _buildSecurityNote(),
      ],
    );
  }

  Widget _buildSuccessCard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.successEmerald.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.successEmerald.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  size: 40,
                  color: AppColors.successEmerald,
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              const Text(
                'Check Your Inbox!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ).animate().fade(delay: 200.ms),
              const SizedBox(height: 12),
              Text(
                'We sent a password reset link to:\n${_emailController.text.trim()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textDarkGrey,
                  height: 1.5,
                ),
              ).animate().fade(delay: 300.ms),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryIndigo.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primaryIndigo,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Click the link in the email to reset your password. The link expires in 1 hour.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textDarkGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fade(delay: 400.ms),
            ],
          ),
        ).animate().fade(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
        const SizedBox(height: 24),
        _buildResendSection(),
        const SizedBox(height: 16),
        _buildBackToLogin(),
      ],
    );
  }

  Widget _buildResendSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Didn\'t receive the email?',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textDarkGrey,
            ),
          ),
          const SizedBox(height: 12),
          if (_resendCountdown > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.textDarkGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Resend available in ${_resendCountdown}s',
                style: TextStyle(
                  color: AppColors.textDarkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _sendResetEmail,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Resend Email',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryIndigo,
              ),
            ),
        ],
      ),
    ).animate().fade(delay: 500.ms);
  }

  Widget _buildBackToLogin() {
    return TextButton.icon(
      onPressed: () => context.pop(),
      icon: const Icon(Icons.arrow_back_rounded, size: 20),
      label: const Text('Back to Login'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textDarkGrey,
      ),
    ).animate().fade(delay: 600.ms);
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryIndigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryIndigo.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryIndigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.security_rounded,
              color: AppColors.primaryIndigo,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure & Private',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your email is only used for password recovery',
                  style: TextStyle(
                    color: AppColors.textDarkGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 500.ms);
  }

  void _showSuccessSnackBar(BuildContext context, String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Reset link sent to ${email.substring(0, 3)}***${email.substring(email.indexOf('@'))}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.successEmerald,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.dangerRose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _sendResetEmail,
        ),
      ),
    );
  }
}
