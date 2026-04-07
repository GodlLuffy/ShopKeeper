import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/services/pin_service.dart';
import 'package:shop_keeper_project/services/biometric_auth_service.dart';
import 'package:shop_keeper_project/injection_container.dart';
import 'package:shop_keeper_project/features/auth/presentation/widgets/pin_dots_widget.dart';
import 'package:shop_keeper_project/features/auth/presentation/widgets/keypad_widget.dart';
import 'package:shop_keeper_project/features/auth/presentation/widgets/shake_animation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/widgets/premium_loader.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final List<int> _inputPin = [];
  bool _isError = false;
  bool _isShaking = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometric();
    });
  }

  Future<void> _tryBiometric() async {
    final bioService = sl<BiometricAuthService>();
    final success = await bioService.authenticate();
    if (success && mounted) {
      context.read<AuthCubit>().unlockApp();
      context.go('/dashboard');
    }
  }

  void _onNumberTap(int number) {
    if (_inputPin.length < 4 && !_isLoading) {
      setState(() {
        _inputPin.add(number);
        _isError = false;
      });

      if (_inputPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeleteTap() {
    if (_inputPin.isNotEmpty && !_isLoading) {
      setState(() {
        _inputPin.removeLast();
        _isError = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);
    final pinService = sl<PinService>();
    final enteredPin = _inputPin.join("");
    
    final isValid = await pinService.verifyPin(enteredPin);
    
    if (mounted) {
      if (isValid) {
        HapticFeedback.heavyImpact();
        context.read<AuthCubit>().unlockApp();
        context.go('/dashboard');
      } else {
        HapticFeedback.vibrate();
        setState(() {
          _isError = true;
          _isShaking = true;
          _isLoading = false;
        });
      }
    }
  }

  void _onAnimationComplete() {
    if (mounted) {
      setState(() {
        _isShaking = false;
        _inputPin.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
              AppColors.primary.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Identity Shield
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                      child: const Center(
                        child: Icon(
                          LucideIcons.shieldCheck, 
                          size: 36, 
                          color: Colors.white,
                        ),
                      ),
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 32),
                    
                    Text(
                      "IDENTITY VERIFICATION",
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 2.5),
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      "SECURE ACCESS TERMINAL",
                      style: GoogleFonts.outfit(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                    ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
                    
                    const SizedBox(height: 48),
                    
                    if (_isLoading)
                      const PremiumLoader(message: 'VALDIATING CREDENTIALS...')
                    else
                      ShakeAnimation(
                        shake: _isShaking,
                        onAnimationComplete: _onAnimationComplete,
                        child: PinDotsWidget(
                          pinLength: _inputPin.length,
                          isError: _isError,
                          primaryColor: AppColors.primary,
                        ),
                      ).animate().fade(delay: 400.ms),
                    
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      height: 20,
                      child: _isError
                          ? Text("INVALID ACCESS CODE", style: GoogleFonts.outfit(color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5))
                          : const SizedBox.shrink(),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    KeypadWidget(
                      onNumberTap: _onNumberTap,
                      onDeleteTap: _onDeleteTap,
                      onBiometricTap: _tryBiometric,
                    ).animate().slideY(begin: 0.1, curve: Curves.easeOut, duration: 500.ms).fade(),
                    
                    const SizedBox(height: 48),
                    
                    TextButton(
                      onPressed: () {
                        context.read<AuthCubit>().logout();
                        context.go('/login');
                      },
                      child: Text(
                        'RESET TERMINAL', 
                        style: GoogleFonts.outfit(color: AppColors.textMuted, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 2)
                      ),
                    ).animate().fade(delay: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
