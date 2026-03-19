import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront, size: 100, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 40),
              Text(
                'Setup Your Shop',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Bring your business online. Track sales, inventory, and expenses securely like a pro.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Finalize setup or go to dashboard
                  context.go('/dashboard');
                },
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
