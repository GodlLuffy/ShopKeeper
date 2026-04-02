import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shop_keeper_project/core/services/sync_engine.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/injection_container.dart';
import 'package:intl/intl.dart';

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
      backgroundColor: AppTheme.darkBackgroundMain,
      appBar: AppBar(
        title: const Text('Sync Evolution Center', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.darkBackgroundLayer,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            onPressed: () async {
              await _syncEngine.syncAll();
              setState(() {});
            },
          ),
        ],
      ),
      body: CustomScrollView(
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
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 100.0),
                        child: Text(
                          'Everything is up to date 🚀',
                          style: TextStyle(color: AppTheme.textGrey, fontSize: 16),
                        ),
                      ),
                    );
                  }
                  final op = pendingOps[index];
                  return _buildOperationTile(op);
                },
                childCount: pendingOps.isEmpty ? 1 : pendingOps.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: totalPending > 0 
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrchid,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () async {
                          await _syncEngine.syncAll();
                          setState(() {});
                        },
                        child: const Text('SYNC NOW', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.dangerRose.withOpacity(0.1),
                        foregroundColor: AppTheme.dangerRose,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.delete_sweep_rounded),
                      onPressed: () => _showClearConfirmation(context),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSummaryCard(int total, Map<String, int> stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.premiumGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.orchidGlowShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PENDING SYNC',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          Text(
            '$total Operations',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
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
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count $label',
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildOperationTile(Map<String, dynamic> op) {
    final type = _getOperationTypeString(op['type'] as int? ?? 0);
    final collection = op['collection'] as String? ?? 'Data';
    final date = DateTime.fromMillisecondsSinceEpoch(op['createdAt'] as int? ?? 0);
    final timeStr = DateFormat('hh:mm:ss a').format(date);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkBackgroundLayer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getTypeColor(op['type'] as int? ?? 0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getTypeIcon(op['type'] as int? ?? 0), color: _getTypeColor(op['type'] as int? ?? 0), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  collection.toUpperCase(),
                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                Text(
                  'ID: ${op['documentId']}',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(type, style: TextStyle(color: _getTypeColor(op['type'] as int? ?? 0), fontWeight: FontWeight.w900, fontSize: 11)),
              Text(timeStr, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
            ],
          ),
        ],
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
      case 0: return AppTheme.successEmerald;
      case 1: return AppTheme.secondaryCyan;
      case 2: return AppTheme.dangerRose;
      default: return AppTheme.primaryOrchid;
    }
  }

  IconData _getTypeIcon(int index) {
    switch (index) {
      case 0: return Icons.add_circle_outline_rounded;
      case 1: return Icons.edit_note_rounded;
      case 2: return Icons.delete_outline_rounded;
      default: return Icons.bolt_rounded;
    }
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkBackgroundLayer,
        title: const Text('Clear Sync Queue?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This will permanently delete all pending cloud operations. Local data will remain, but cloud sync will be skipped for these changes.',
          style: TextStyle(color: AppTheme.textGrey),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              await _syncEngine.clearPendingQueue();
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('CLEAR ALL', style: TextStyle(color: AppTheme.dangerRose, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
