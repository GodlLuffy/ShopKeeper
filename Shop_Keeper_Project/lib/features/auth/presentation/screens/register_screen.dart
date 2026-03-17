import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _shopNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Shop Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Owner Name', hintText: 'John Doe')),
            const SizedBox(height: 16),
            TextField(controller: _shopNameController, decoration: const InputDecoration(labelText: 'Shop Name', hintText: 'Best Kirana Store')),
            const SizedBox(height: 16),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email Address', hintText: 'john@example.com')),
            const SizedBox(height: 16),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 32),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state is AuthLoading 
                    ? null 
                    : () => context.read<AuthCubit>().register(
                        _nameController.text,
                        _emailController.text,
                        _passwordController.text,
                        _shopNameController.text,
                      ),
                  child: state is AuthLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Shop'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
