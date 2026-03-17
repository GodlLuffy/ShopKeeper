import 'package:flutter/material.dart';
import 'package:shop_keeper_project/features/auth/presentation/screens/splash_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSection('Business', [
            _buildTile(Icons.store, 'Shop Profile', 'Edit shop name and contact', () {}),
            _buildTile(Icons.backup, 'Backup & Restore', 'Sync with cloud storage', () {}),
          ]),
          _buildSection('Security', [
            _buildTile(Icons.lock, 'Change Password', 'Update your login credentials', () {}),
            _buildTile(Icons.fingerprint, 'Biometric Lock', 'Secure app with fingerprint', () {}, isSwitch: true),
          ]),
          _buildSection('Account', [
            _buildTile(Icons.logout, 'Logout', 'Sign out from this device', () {
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (_) => const SplashScreen()),
                (route) => false,
              );
            }, isDestructive: true),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
        ),
        ...children,
      ],
    );
  }

  Widget _buildTile(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isSwitch = false, bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : null),
      title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : null)),
      subtitle: Text(subtitle),
      trailing: isSwitch ? Switch(value: false, onChanged: (v) {}) : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
