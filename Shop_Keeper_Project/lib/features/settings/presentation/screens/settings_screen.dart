import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/settings/presentation/screens/profile_screen.dart';
import 'package:shop_keeper_project/features/settings/presentation/screens/about_screen.dart';
import 'package:shop_keeper_project/features/auth/presentation/screens/pin_setup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_keeper_project/services/sync_service.dart';
import 'package:shop_keeper_project/injection_container.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Account'),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'Update your shop details',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'App Lock Config',
            subtitle: 'Change your 4-digit PIN',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PinSetupScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Data & Sync'),
          _buildSettingsTile(
            icon: Icons.cloud_sync_outlined,
            title: 'Sync Now',
            subtitle: 'Manually backup data to cloud',
            onTap: () async {
              try {
                await sl<SyncService>().syncAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Syncing data to cloud...')),
                  );
                }
              } catch (_) {
                // Ignore sync errors here
              }
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('System'),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About App',
            subtitle: 'Version 1.0.0',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Log out',
            subtitle: 'Sign out of your account',
            color: AppTheme.errorColor,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.read<AuthCubit>().logout(); // Cleanup auth cubit state properly
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? AppTheme.primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color ?? AppTheme.primaryColor),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color ?? const Color(0xFF1E293B))),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFCBD5E1)),
        onTap: onTap,
      ),
    );
  }
}
