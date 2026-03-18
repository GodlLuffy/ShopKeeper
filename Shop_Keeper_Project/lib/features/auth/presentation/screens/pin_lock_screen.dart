import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import '../../../../injection_container.dart';
import '../../../../services/security_service.dart';

class PinLockScreen extends StatefulWidget {
  final bool isSetup;
  
  const PinLockScreen({super.key, this.isSetup = false});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> with SingleTickerProviderStateMixin {
  String _inputPin = "";
  bool _isError = false;
  bool _isLoading = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Shake animation values
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNumberTap(String number) {
    if (_inputPin.length < 4 && !_isLoading) {
      HapticFeedback.lightImpact(); // Pro Upgrade: Haptic Feedback
      setState(() {
        _inputPin += number;
        _isError = false; // clear error text upon typing
      });

      if (_inputPin.length == 4) {
        _checkPin();
      }
    }
  }

  void _checkPin() async {
    setState(() => _isLoading = true);
    final securityService = sl<SecurityService>();
    final authState = context.read<AuthCubit>().state;
    
    String uid = "";
    if (authState is PinRequired) {
      uid = authState.user.uid;
    } else if (authState is Authenticated) {
      uid = authState.user.uid;
    } else {
      setState(() {
        _isError = true;
        _isLoading = false;
        _inputPin = "";
      });
      _controller.forward(from: 0);
      return;
    }

    if (widget.isSetup) {
      await securityService.setPin(uid, _inputPin);
      if (mounted) context.go('/'); // Assuming root is Dashboard
    } else {
      final isValid = await securityService.verifyPin(uid, _inputPin);
      if (mounted) {
        if (isValid) {
          context.go('/'); 
        } else {
          setState(() {
            _isError = true;
            _inputPin = "";
            _isLoading = false;
          });
          HapticFeedback.vibrate(); // Vibrate on error
          _controller.forward(from: 0); // Shake animation
        }
      }
    }
  }

  void _onBackspace() {
    if (_inputPin.isNotEmpty && !_isLoading) {
      HapticFeedback.lightImpact();
      setState(() => _inputPin = _inputPin.substring(0, _inputPin.length - 1));
    }
  }

  Widget _buildDot(int index) {
    bool filled = index < _inputPin.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: filled ? AppTheme.primaryColor : Colors.white,
        border: Border.all(
          color: filled ? AppTheme.primaryColor : const Color(0xFFCBD5E1),
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _numberButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberTap(number),
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          number,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ["1", "2", "3"].map((e) => _numberButton(e)).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ["4", "5", "6"].map((e) => _numberButton(e)).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ["7", "8", "9"].map((e) => _numberButton(e)).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80, height: 80), // Empty space for alignment
            _numberButton("0"),
            GestureDetector(
              onTap: _onBackspace,
              child: Container(
                width: 80,
                height: 80,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: const Icon(Icons.backspace_outlined, size: 28, color: Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Icon(widget.isSetup ? Icons.lock_person : Icons.lock, size: 64, color: AppTheme.primaryColor),
              const SizedBox(height: 20),
              Text(
                widget.isSetup ? "Secure Your App" : "Welcome Back",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isSetup ? "Set a 4-Digit PIN to protect your business" : "Enter your PIN to access your shop",
                style: const TextStyle(color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              
              if (_isLoading)
                const CircularProgressIndicator()
              else
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_animation.value, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, _buildDot),
                      ),
                    );
                  },
                ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                height: 24,
                child: _isError 
                  ? const Text("Incorrect PIN. Try again.", style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w500)) 
                  : const SizedBox.shrink(),
              ),

              const Spacer(),
              _buildKeypad(),
              
              const SizedBox(height: 16),
              
              if (!widget.isSetup)
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Forgot PIN? Login with Phone/Email', style: TextStyle(color: AppTheme.primaryColor)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
