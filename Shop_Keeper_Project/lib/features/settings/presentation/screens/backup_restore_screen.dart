import 'package:flutter/material.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';

class BackupRestoreScreen extends StatelessWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Secure your data in the cloud. Your sales, stock, and expenses are protected.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            _buildSyncStatus(context, 'Last Synced: Today, 10:30 AM', Icons.cloud_done, AppTheme.successColor),
            const SizedBox(height: 24),
            _buildSyncStatus(context, 'Offline Changes: 5 items pending', Icons.cloud_off, AppTheme.accentColor),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.sync),
              label: const Text('Sync Now'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Data is also automatically synced in the background when connected to the internet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatus(BuildContext context, String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        ],
      ),
    );
  }
}
