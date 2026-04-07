import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_keeper_project/services/rating_service.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackgroundMain,
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
                  color: AppColors.primaryIndigo.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryIndigo.withOpacity(0.3)),
                ),
                child: const Icon(Icons.storefront, size: 100, color: AppColors.primaryIndigo),
              ),
              const SizedBox(height: 40),
              Text(
                'Setup Your Shop',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Bring your business online. Track sales, inventory, and expenses securely like a pro.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [AppColors.primaryIndigo, AppColors.accentTeal],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryIndigo.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    RatingService.instance.initSession();
                    context.go('/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
