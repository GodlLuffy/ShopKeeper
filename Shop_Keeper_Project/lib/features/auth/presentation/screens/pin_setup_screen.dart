import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/services/pin_service.dart';
import 'package:shop_keeper_project/injection_container.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _inputPin = "";
  String _confirmPin = "";
  bool _isConfirmStep = false;
  bool _isError = false;

  void _onNumberTap(String number) {
    if (_inputPin.length < 4) {
      HapticFeedback.lightImpact();
      setState(() {
        _inputPin += number;
        _isError = false;
      });

      if (_inputPin.length == 4) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!_isConfirmStep) {
            setState(() {
              _confirmPin = _inputPin;
              _inputPin = "";
              _isConfirmStep = true;
            });
          } else {
            _checkPinsMatch();
          }
        });
      }
    }
  }

  void _checkPinsMatch() async {
    if (_inputPin == _confirmPin) {
      final pinService = sl<PinService>();
      await pinService.setPin(_inputPin);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN successfully set!')));
        Navigator.pop(context);
      }
    } else {
      HapticFeedback.vibrate();
      setState(() {
        _isError = true;
        _inputPin = "";
      });
    }
  }

  void _onBackspace() {
    if (_inputPin.isNotEmpty) {
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
        color: filled ? AppColors.primaryIndigo : Colors.white,
        border: Border.all(color: filled ? AppColors.primaryIndigo : const Color(0xFFCBD5E1), width: 2),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _numberButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberTap(number),
      child: Container(
        margin: const EdgeInsets.all(12),
        height: 70, // explicitly making it large
        width: 70,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
        ),
        alignment: Alignment.center,
        child: Text(number, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: ["1", "2", "3"].map(_numberButton).toList()),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: ["4", "5", "6"].map(_numberButton).toList()),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: ["7", "8", "9"].map(_numberButton).toList()),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80, height: 80),
            _numberButton("0"),
            GestureDetector(
              onTap: _onBackspace,
              child: Container(
                width: 80, height: 80,
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
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_isConfirmStep ? Icons.check_circle_outline : Icons.lock_outline, size: 64, color: AppColors.primaryIndigo),
              const SizedBox(height: 20),
              Text(
                _isConfirmStep ? "Confirm Your PIN" : "Protect Your App",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              Text(
                _isConfirmStep ? "Enter the 4-digit PIN again" : "Set a secure 4-digit PIN",
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              const Spacer(),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, _buildDot)),
              const SizedBox(height: 32),
              SizedBox(
                height: 24,
                child: _isError 
                  ? const Text("PINs do not match. Try again.", style: TextStyle(color: AppColors.dangerRose, fontWeight: FontWeight.w500)) 
                  : const SizedBox.shrink(),
              ),
              const Spacer(),
              _buildKeypad(),
            ],
          ),
        ),
      ),
    );
  }
}
