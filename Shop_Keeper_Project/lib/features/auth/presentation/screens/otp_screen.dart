import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with CodeAutoFill {
  String _otpCode = "";
  int _seconds = 30;
  Timer? _timer;
  bool _shake = false;

  @override
  void initState() {
    super.initState();
    listenForCode(); // Auto read OTP
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_seconds == 0) {
        timer.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void codeUpdated() {
    if (!mounted) return;
    setState(() {
      _otpCode = code ?? "";
    });
    if (_otpCode.length == 6) {
      _verifyOTP(_otpCode);
    }
  }

  @override
  void dispose() {
    cancel();
    _timer?.cancel();
    super.dispose();
  }

  void _verifyOTP(String otp) {
    if (otp.length != 6) {
      _triggerShake();
      return;
    }
    context.read<AuthCubit>().verifyOtp(widget.verificationId, otp);
  }

  void _triggerShake() {
    setState(() => _shake = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _shake = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          _triggerShake();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.dangerRose),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  transform: Matrix4.translationValues(_shake ? 10 : 0, 0, 0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.lock, size: 60, color: AppColors.primaryIndigo),
                        const SizedBox(height: 16),
                        const Text(
                          "Secure Verification",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enter the OTP sent to\n${widget.phoneNumber}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 32),
                        PinFieldAutoFill(
                          codeLength: 6,
                          currentCode: _otpCode,
                          onCodeChanged: (val) {
                            setState(() {
                              _otpCode = val ?? "";
                            });
                            if (_otpCode.length == 6) {
                              _verifyOTP(_otpCode);
                            }
                          },
                          decoration: BoxLooseDecoration(
                            strokeColorBuilder: const FixedColorBuilder(Color(0xFFE2E8F0)),
                            bgColorBuilder: const FixedColorBuilder(Colors.white),
                            textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 32),
                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            return ElevatedButton(
                              onPressed: isLoading || _otpCode.length != 6
                                  ? null
                                  : () => _verifyOTP(_otpCode),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryIndigo,
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: isLoading
                                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text("Verify OTP", style: TextStyle(fontSize: 18, color: Colors.white)),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (_seconds > 0)
                  Text(
                    "Waiting for auto-detect... $_seconds""s",
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                  )
                else
                  TextButton(
                    onPressed: () {
                      setState(() => _seconds = 30);
                      _startTimer();
                      context.read<AuthCubit>().loginWithPhone(widget.phoneNumber);
                    },
                    child: const Text(
                      "Didn't receive OTP? Resend",
                      style: TextStyle(color: AppColors.primaryIndigo, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
