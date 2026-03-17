import 'package:flutter/material.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';

class ShopProfileScreen extends StatelessWidget {
  const ShopProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.store, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const GlassCard(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _InfoRow(label: 'Shop Name', value: 'Modern Kirana Store'),
                    Divider(),
                    _InfoRow(label: 'Owner Name', value: 'John Smith'),
                    Divider(),
                    _InfoRow(label: 'Phone', value: '+91 98765 43210'),
                    Divider(),
                    _InfoRow(label: 'Email', value: 'john@example.com'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
