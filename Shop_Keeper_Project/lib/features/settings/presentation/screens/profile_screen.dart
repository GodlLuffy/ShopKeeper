import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/features/settings/presentation/screens/edit_profile_screen.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackgroundMain,
      appBar: AppBar(
        title: Text(AppStrings.get('shop_identity'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is Authenticated || state is PinRequired) {
            final user = (state is Authenticated) 
                ? state.user 
                : (state as PinRequired).user;
                
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomRight,
                  radius: 1.5,
                  colors: [
                    AppTheme.primaryIndigo.withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryIndigo, AppTheme.accentTeal],
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 54,
                        backgroundColor: AppTheme.darkBackgroundLayer,
                        child: Icon(Icons.storefront_rounded, size: 48, color: AppTheme.accentTeal),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      (user.shopName.isNotEmpty ? user.shopName : AppStrings.get('app_name')).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.w900, 
                        color: AppTheme.textWhite,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.successEmerald.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppTheme.successEmerald.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_user_rounded, color: AppTheme.successEmerald, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.get('encrypted_business'), 
                            style: const TextStyle(color: AppTheme.successEmerald, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _buildProfileItem(Icons.badge_outlined, AppStrings.get('operator_name'), user.name),
                          _buildDivider(),
                          _buildProfileItem(Icons.phone_iphone_rounded, AppStrings.get('terminal_id'), user.phoneNumber),
                          _buildDivider(),
                          _buildProfileItem(Icons.alternate_email_rounded, AppStrings.get('recovery_data'), user.email.isNotEmpty ? user.email : 'NOT CONFIGURED'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 64),
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(colors: [AppTheme.primaryIndigo, AppTheme.accentTeal]),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryIndigo.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
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
                          AppStrings.get('edit_profile'), 
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return const Center(child: Text('TERMINAL OFFLINE', style: TextStyle(color: AppTheme.dangerRose, fontWeight: FontWeight.w900)));
        },
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.white.withOpacity(0.05)),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryIndigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryIndigo, size: 20),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textMuted, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textWhite)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
