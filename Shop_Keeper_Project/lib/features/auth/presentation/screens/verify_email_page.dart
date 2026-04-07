import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      context.read<AuthCubit>().refreshEmailVerification();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackgroundMain,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            _pollingTimer?.cancel();
            context.go('/dashboard');
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.dangerRose),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.warningAmber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    size: 64,
                    color: AppColors.warningAmber,
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                
                const SizedBox(height: 32),
                
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    color: AppColors.textBlack, 
                    letterSpacing: -0.5,
                  ),
                ).animate().fade(delay: 200.ms),
                
                const SizedBox(height: 16),
                
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final email = state is EmailVerificationPending 
                        ? state.user.email 
                        : '';
                    return Text(
                      'We\'ve sent a verification link to\n$email',
                      style: const TextStyle(
                        fontSize: 15, 
                        color: AppColors.textDarkGrey,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fade(delay: 300.ms);
                  },
                ),
                
                const SizedBox(height: 32),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryIndigo.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryIndigo.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.primaryIndigo, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'What to do next?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: AppColors.primaryIndigo,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildStep('1', 'Check your inbox for the verification email'),
                      const SizedBox(height: 8),
                      _buildStep('2', 'Click the verification link inside'),
                      const SizedBox(height: 8),
                      _buildStep('3', 'Return here and we\'ll auto-log you in'),
                    ],
                  ),
                ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
                
                const Spacer(),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.read<AuthCubit>().logout(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Sign Out'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.textMuted),
                          foregroundColor: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return ElevatedButton.icon(
                            onPressed: () => context.read<AuthCubit>().resendVerificationEmail(),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Resend Email'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.primaryIndigo,
                              foregroundColor: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ).animate().fade(delay: 500.ms),
                
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () => context.read<AuthCubit>().refreshEmailVerification(),
                  child: const Text(
                    'I\'ve verified - Refresh Now',
                    style: TextStyle(
                      color: AppColors.accentTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primaryIndigo.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.primaryIndigo,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textDarkGrey,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
