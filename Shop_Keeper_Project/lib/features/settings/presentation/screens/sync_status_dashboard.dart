import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shop_keeper_project/core/services/sync_engine.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/injection_container.dart';
import 'package:intl/intl.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SyncStatusDashboard extends StatefulWidget {
  const SyncStatusDashboard({super.key});

  @override
  State<SyncStatusDashboard> createState() => _SyncStatusDashboardState();
}

class _SyncStatusDashboardState extends State<SyncStatusDashboard> {
  final SyncEngine _syncEngine = sl<SyncEngine>();
  late final StreamSubscription<SyncStatus> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _syncEngine.statusStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingOps = _syncEngine.getPendingOperations();
    final stats = _syncEngine.getPendingStats();
    final totalPending = _syncEngine.pendingCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'SYNC EVOLUTION CENTER', 
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.refreshCw, size: 20, color: AppColors.primary),
            onPressed: () async {
              await _syncEngine.syncAll();
              if (mounted) setState(() {});
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildSummaryCard(totalPending, stats),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (pendingOps.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 80.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.success.withOpacity(0.05),
                              ),
                              child: Icon(LucideIcons.checkCircle2, color: AppColors.success, size: 48),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'CORE DATA SYNCHRONIZED',
                              style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Terminal is fully up-to-date with cloud vault',
                              style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn();
                  }
                  final op = pendingOps[index];
                  return _buildOperationTile(op).animate().fadeIn(delay: (index * 50).ms);
                },
                childCount: pendingOps.isEmpty ? 1 : pendingOps.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      bottomSheet: totalPending > 0 
          ? Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.95),
                border: const Border(top: BorderSide(color: AppColors.glassBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: AppColors.goldGradient,
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          await _syncEngine.syncAll();
                          if (mounted) setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'ACTIVATE SYNC'.toUpperCase(),
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    height: 56, width: 56,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.error.withOpacity(0.2)),
                    ),
                    child: IconButton(
                      icon: const Icon(LucideIcons.trash2, color: AppColors.error, size: 20),
                      onPressed: () => _showClearConfirmation(context),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildSummaryCard(int total, Map<String, int> stats) {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      backgroundOpacity: 0.05,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PENDING OPERATIONS',
                style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              Icon(LucideIcons.activity, color: AppColors.primary.withOpacity(0.5), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$total'.padLeft(2, '0'),
            style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 56, fontWeight: FontWeight.w900, height: 1),
          ),
          const SizedBox(height: 12),
          Text(
            'QUEUE CAPACITY AT STATUS OPTIMAL',
            style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stats.entries.map((e) => _buildStatChip(e.key.toUpperCase(), e.value)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationTile(Map<String, dynamic> op) {
    final typeIndex = op['type'] as int? ?? 0;
    final type = _getOperationTypeString(typeIndex);
    final collection = op['collection'] as String? ?? 'Data';
    final date = DateTime.fromMillisecondsSinceEpoch(op['createdAt'] as int? ?? 0);
    final timeStr = DateFormat('hh:mm:ss a').format(date);
    final color = _getTypeColor(typeIndex);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        backgroundOpacity: 0.03,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.1)),
              ),
              child: Icon(_getTypeIcon(typeIndex), color: color, size: 20),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.toUpperCase(),
                    style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${op['documentId']}',
                    style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    type, 
                    style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr, 
                  style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getOperationTypeString(int index) {
    switch (index) {
      case 0: return 'CREATE';
      case 1: return 'UPDATE';
      case 2: return 'DELETE';
      default: return 'ACTION';
    }
  }

  Color _getTypeColor(int index) {
    switch (index) {
      case 0: return AppColors.success;
      case 1: return AppColors.info;
      case 2: return AppColors.error;
      default: return AppColors.primary;
    }
  }

  IconData _getTypeIcon(int index) {
    switch (index) {
      case 0: return LucideIcons.plusCircle;
      case 1: return LucideIcons.fileEdit;
      case 2: return LucideIcons.trash2;
      default: return LucideIcons.zap;
    }
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: const BorderSide(color: AppColors.glassBorder)),
        title: Text(
          'PURGE SYNC QUEUE?', 
          style: GoogleFonts.outfit(color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
        ),
        content: Text(
          'This action will permanently discard all pending cloud updates. Local integrity remains intact.',
          style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text('CANCEL'.toUpperCase(), style: GoogleFonts.outfit(color: AppColors.textMuted, fontWeight: FontWeight.w900, fontSize: 12)),
          ),
          TextButton(
            onPressed: () async {
              await _syncEngine.clearPendingQueue();
              if (context.mounted) Navigator.pop(ctx);
              setState(() {});
            },
            child: Text(
              'DISCARD ALL'.toUpperCase(), 
              style: GoogleFonts.outfit(color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

