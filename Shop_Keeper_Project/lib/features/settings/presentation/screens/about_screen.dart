import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.get('labs_info').toUpperCase(), 
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.goldGradient,
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 10))
                  ],
                ),
                child: CircleAvatar(
                  radius: 64,
                  backgroundColor: Colors.black,
                  child: Icon(LucideIcons.terminal, size: 56, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              AppStrings.get('app_name').toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Text(
                'STABLE RELEASE v1.2.4'.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 64),
            GlassCard(
              padding: const EdgeInsets.all(32.0),
              backgroundOpacity: 0.05,
              child: Column(
                children: [
                  Text(
                    'Empowering modern retail with an executive-grade terminal for high-precision inventory and sales optimization.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      height: 1.6,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildInfoRow(LucideIcons.shieldCheck, 'FINTECH GRADE SECURITY'),
                  const SizedBox(height: 24),
                  _buildInfoRow(LucideIcons.cloud, 'QUANTUM CLOUD SYNC'),
                  const SizedBox(height: 24),
                  _buildInfoRow(LucideIcons.barChart, 'BUSINESS INTELLIGENCE'),
                ],
              ),
            ),
            const SizedBox(height: 64),
            Text(
              'DEVELOPED BY ANUP',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            const SizedBox(height: 32),
            Text(
              '© 2026 SHOPKEEPER PRO INC.',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.textMuted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ENGINEERED WITH '.toUpperCase(),
                  style: GoogleFonts.outfit(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w800, letterSpacing: 1),
                ),
                Icon(LucideIcons.heart, size: 10, color: AppColors.error.withOpacity(0.5)),
                Text(
                  ' FOR GLOBAL RETAIL'.toUpperCase(),
                  style: GoogleFonts.outfit(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w800, letterSpacing: 1),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 20),
        Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

