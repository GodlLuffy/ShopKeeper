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
  
  static const Color primaryPurple = Color(0xFF5F259F);
  static const Color backgroundGrey = Color(0xFFF5F7FA);

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
      backgroundColor: backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),
            
            const Icon(Icons.lock_outline, size: 48, color: primaryPurple),
            const SizedBox(height: 16),
            
            const Text(
              "Enter PIN",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            
            const Text(
              "Unlock your shop",
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            
            const Spacer(),
            
            if (_isLoading)
              const SizedBox(height: 20, child: CircularProgressIndicator(color: primaryPurple))
            else
              ShakeAnimation(
                shake: _isShaking,
                onAnimationComplete: _onAnimationComplete,
                child: PinDotsWidget(
                  pinLength: _inputPin.length,
                  isError: _isError,
                  primaryColor: primaryPurple,
                ),
              ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              height: 20,
              child: _isError
                  ? const Text("Incorrect PIN", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500))
                  : const SizedBox.shrink(),
            ),
            
            const Spacer(),
            
            KeypadWidget(
              onNumberTap: _onNumberTap,
              onDeleteTap: _onDeleteTap,
              onBiometricTap: _tryBiometric,
            ),
            
            const SizedBox(height: 32),
            
            TextButton(
              onPressed: () {
                context.read<AuthCubit>().logout();
                context.go('/login');
              },
              child: const Text('Forgot PIN? Logout', style: TextStyle(color: primaryPurple, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
