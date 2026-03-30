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
import 'package:shop_keeper_project/core/theme/app_theme.dart';

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
      backgroundColor: AppTheme.darkBackgroundMain,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              AppTheme.primaryIndigo.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 80),
              
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryIndigo, AppTheme.accentTeal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryIndigo.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: const Icon(Icons.lock_rounded, size: 36, color: Colors.white),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 24),
              
              const Text(
                "Enter PIN",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textWhite, letterSpacing: -1),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 8),
              
              const Text(
                "Secure Access to ShopKeeper PRO",
                style: TextStyle(fontSize: 15, color: AppTheme.textGrey, fontWeight: FontWeight.w500),
              ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
              
              const Spacer(),
              
              if (_isLoading)
                const SizedBox(height: 24, child: CircularProgressIndicator(color: AppTheme.primaryIndigo))
              else
                ShakeAnimation(
                  shake: _isShaking,
                  onAnimationComplete: _onAnimationComplete,
                  child: PinDotsWidget(
                    pinLength: _inputPin.length,
                    isError: _isError,
                    primaryColor: AppTheme.primaryIndigo,
                  ),
                ).animate().fade(delay: 400.ms),
              
              const SizedBox(height: 24),
              
              SizedBox(
                height: 20,
                child: _isError
                    ? const Text("Incorrect PIN", style: TextStyle(color: AppTheme.dangerRose, fontWeight: FontWeight.bold))
                    : const SizedBox.shrink(),
              ),
              
              const Spacer(),
              
              KeypadWidget(
                onNumberTap: _onNumberTap,
                onDeleteTap: _onDeleteTap,
                onBiometricTap: _tryBiometric,
              ).animate().slideY(begin: 0.2, curve: Curves.easeOut, duration: 400.ms).fade(),
              
              const SizedBox(height: 32),
              
              TextButton(
                onPressed: () {
                  context.read<AuthCubit>().logout();
                  context.go('/login');
                },
                child: const Text('Forgot PIN? Logout', style: TextStyle(color: AppTheme.accentTeal, fontWeight: FontWeight.w700, fontSize: 15)),
              ).animate().fade(delay: 500.ms),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
