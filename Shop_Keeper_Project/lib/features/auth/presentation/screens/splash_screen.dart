import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted || _hasNavigated) return;
    
    context.read<AuthCubit>().checkAuth();
    
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && !_hasNavigated) {
        debugPrint('SPLASH: Safety timeout reached, navigating to Login');
        _hasNavigated = true;
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (_hasNavigated) return;
        
        if (state is Authenticated) {
          _hasNavigated = true;
          context.go('/dashboard');
        } else if (state is Unauthenticated || state is AuthError) {
          _hasNavigated = true;
          context.go('/login');
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.storefront_rounded,
                size: 100,
                color: Colors.white,
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
              const SizedBox(height: 24),
              const Text(
                'Shopkeeper Manager',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 24),
              const Text(
                'Loading...',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
