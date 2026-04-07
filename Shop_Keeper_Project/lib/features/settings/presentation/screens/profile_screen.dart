import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';

import 'package:shop_keeper_project/features/settings/presentation/screens/edit_profile_screen.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:shop_keeper_project/core/security/terminal_id_service.dart';
import 'package:shop_keeper_project/injection_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _terminalId = 'Loading...';
  
  @override
  void initState() {
    super.initState();
    _loadTerminalId();
  }
  
  Future<void> _loadTerminalId() async {
    try {
      final authState = context.read<AuthCubit>().state;
      String? uid;
      if (authState is Authenticated) {
        uid = authState.user.uid;
      } else if (authState is PinRequired) {
        uid = authState.user.uid;
      }

      final service = sl<TerminalIdService>();
      final id = await service.getTerminalId(uid);
      if (mounted) {
        setState(() => _terminalId = id);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _terminalId = 'NOT AVAILABLE');
      }
    }
  }
  
  void _copyTerminalId() {
    Clipboard.setData(ClipboardData(text: _terminalId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('TERMINAL ID COPIED', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 12, letterSpacing: 1)),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.get('shop_identity').toUpperCase(), 
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
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is Authenticated || state is PinRequired) {
            final user = (state is Authenticated) 
                ? state.user 
                : (state as PinRequired).user;
                
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.goldGradient,
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.black,
                      child: Icon(LucideIcons.store, size: 48, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    (user.shopName.isNotEmpty ? user.shopName : AppStrings.get('app_name')).toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 24, 
                      fontWeight: FontWeight.w900, 
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.success.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.shieldCheck, color: AppColors.success, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.get('encrypted_business').toUpperCase(), 
                          style: GoogleFonts.outfit(color: AppColors.success, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundOpacity: 0.05,
                    child: Column(
                      children: [
                        _buildProfileItem(LucideIcons.user, AppStrings.get('operator_name'), user.name),
                        _buildDivider(),
                        _buildTerminalIdItem(LucideIcons.monitor, AppStrings.get('terminal_id'), _terminalId),
                        _buildDivider(),
                        _buildProfileItem(LucideIcons.mail, AppStrings.get('recovery_data'), user.email.isNotEmpty ? user.email : 'NOT CONFIGURED'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 64),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: AppColors.goldGradient,
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          AppStrings.get('edit_profile').toUpperCase(), 
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return Center(
            child: Text(
              'TERMINAL OFFLINE', 
              style: GoogleFonts.outfit(color: AppColors.error, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Divider(height: 1, color: Colors.white.withOpacity(0.05)),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(), 
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 1),
                ),
                const SizedBox(height: 6),
                Text(
                  value, 
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalIdItem(IconData icon, String label, String value) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _copyTerminalId,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(), 
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 1),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.copy,
                color: AppColors.primary.withOpacity(0.5),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

