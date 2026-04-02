import 'package:flutter/material.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('About App', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryIndigo.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.store_mall_directory_rounded,
                  size: 80,
                  color: AppTheme.primaryIndigo,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ShopKeeper',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Empowering modern retail with smart inventory and sales management.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        height: 1.5,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildInfoRow(Icons.security, 'FinTech Grade Security'),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.cloud_sync, 'Real-time Cloud Sync'),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.analytics_outlined, 'Advanced Analytics'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            Text(
              '© 2026 ShopKeeper Inc.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Made with ❤️ for Shopkeepers',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFCBD5E1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryIndigo),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
