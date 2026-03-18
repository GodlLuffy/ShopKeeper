import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';

import 'package:go_router/go_router.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.errorColor),
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
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.storefront, size: 80, color: AppTheme.primaryColor),
                  const SizedBox(height: 16),
                  Text('ShopKeeper Login', style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 32),
                  
                  // Toggle Login Type
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Phone OTP')),
                          selected: _isPhoneLogin,
                          onSelected: (val) => setState(() => _isPhoneLogin = true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Email')),
                          selected: !_isPhoneLogin,
                          onSelected: (val) => setState(() => _isPhoneLogin = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (_isPhoneLogin) ...[
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        prefixIcon: Icon(Icons.phone),
                        hintText: '+91 XXXXX XXXXX',
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  
                  if (state is AuthLoading)
                    const CircularProgressIndicator()
                  else ...[
                    ElevatedButton(
                      onPressed: () {
                        if (_isPhoneLogin) {
                          context.read<AuthCubit>().loginWithPhone(_phoneController.text);
                        } else {
                          context.read<AuthCubit>().loginWithEmail(
                            _emailController.text,
                            _passwordController.text,
                          );
                        }
                      },
                      child: Text(_isPhoneLogin ? 'GET OTP' : 'LOGIN'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('New Shop? Create Account'),
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
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
