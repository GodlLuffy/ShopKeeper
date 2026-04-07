import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/primary_button.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ConflictResolutionScreen extends StatefulWidget {
  const ConflictResolutionScreen({super.key});

  @override
  State<ConflictResolutionScreen> createState() => _ConflictResolutionScreenState();
}

class _ConflictResolutionScreenState extends State<ConflictResolutionScreen> {
  final Box pendingOpsBox = Hive.box('pending_operations');

  List<Map<String, dynamic>> _getConflicts() {
    return pendingOpsBox.values
        .where((e) => e['type'] == 'conflict' && e['status'] == 'pending')
        .cast<Map<String, dynamic>>()
        .toList();
  }

  void _resolveConflict(String conflictId, Map<String, dynamic> keptData) {
    final conflict = pendingOpsBox.get(conflictId);
    if (conflict != null) {
      pendingOpsBox.put(conflictId, {
        ...Map<String, dynamic>.from(conflict as Map),
        'status': 'resolved',
      });
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final conflicts = _getConflicts();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'CONFLICT RESOLUTION CENTER', 
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
      body: conflicts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success.withOpacity(0.05),
                    ),
                    child: Icon(LucideIcons.shieldCheck, color: AppColors.success, size: 48),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'INTEGRITY VERIFIED',
                    style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No data conflicts detected in the current queue',
                    style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ).animate().fadeIn()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              physics: const BouncingScrollPhysics(),
              itemCount: conflicts.length,
              itemBuilder: (context, index) {
                final conflict = conflicts[index];
                final localData = conflict['localData'] as Map<dynamic, dynamic>;
                final remoteData = conflict['remoteData'] as Map<dynamic, dynamic>;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: GlassCard(
                    padding: const EdgeInsets.all(24.0),
                    backgroundOpacity: 0.05,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.alertTriangle, color: AppColors.warning, size: 16),
                            const SizedBox(width: 12),
                            Text(
                              '${conflict['collection'].toString().toUpperCase()} - ${conflict['documentId']}',
                              style: GoogleFonts.outfit(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 48, color: AppColors.glassBorder),
                        Row(
                          children: [
                            Expanded(
                              child: _buildVersionBox(
                                title: 'TERMINAL DATA',
                                data: localData,
                                color: AppColors.secondary,
                                icon: LucideIcons.smartphone,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildVersionBox(
                                title: 'CLOUD DATA',
                                data: remoteData,
                                color: AppColors.primary,
                                icon: LucideIcons.cloud,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                text: 'KEEP TERMINAL',
                                onPressed: () {
                                  _resolveConflict(conflict['id'], Map<String, dynamic>.from(localData));
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.glassBorder),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    _resolveConflict(conflict['id'], Map<String, dynamic>.from(remoteData));
                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: Text(
                                    'KEEP CLOUD',
                                    style: GoogleFonts.outfit(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.1, end: 0);
              },
            ),
    );
  }

  Widget _buildVersionBox({
    required String title,
    required Map<dynamic, dynamic> data,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 8),
              Text(
                title, 
                style: GoogleFonts.outfit(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _summarizeData(data), 
            style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11, height: 1.6, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _summarizeData(Map<dynamic, dynamic> data) {
    if (data.containsKey('name')) return 'PRODUCT: ${data['name']}\nSTOCK: ${data['stockQuantity']}\nPRICE: ₹${data['sellPrice']}';
    if (data.containsKey('quantitySold')) return 'QTY: ${data['quantitySold']}\nTOTAL: ₹${data['totalAmount']}';
    return data.entries.take(3).map((e) => '${e.key.toString().toUpperCase()}: ${e.value}').join('\n');
  }
}

