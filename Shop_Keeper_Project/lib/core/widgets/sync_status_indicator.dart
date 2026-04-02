import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shop_keeper_project/core/services/sync_engine.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';

class SyncStatusIndicator extends StatefulWidget {
  final SyncEngine syncEngine;

  const SyncStatusIndicator({super.key, required this.syncEngine});

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator> {
  StreamSubscription? _statusSubscription;

  @override
  void initState() {
    super.initState();
    _statusSubscription = widget.syncEngine.statusStream.listen((status) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.syncEngine.status;
    
    return GestureDetector(
      onTap: () => widget.syncEngine.syncAll(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _getBackgroundColor(status),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _getBorderColor(status)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(status),
            const SizedBox(width: 6),
            Text(
              _getLabel(status),
              style: TextStyle(
                color: _getTextColor(status),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _getTextColor(status),
          ),
        );
      case SyncStatus.error:
        return const Icon(Icons.cloud_off_rounded, size: 14, color: AppTheme.dangerRose);
      case SyncStatus.offline:
        return const Icon(Icons.cloud_off_rounded, size: 14, color: AppTheme.warningAmber);
      case SyncStatus.idle:
        return const Icon(Icons.cloud_done_rounded, size: 14, color: AppTheme.successEmerald);
    }
  }

  Color _getBackgroundColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return AppTheme.primaryOrchid.withOpacity(0.1);
      case SyncStatus.error:
        return AppTheme.dangerRose.withOpacity(0.1);
      case SyncStatus.offline:
        return AppTheme.warningAmber.withOpacity(0.1);
      case SyncStatus.idle:
        return AppTheme.successEmerald.withOpacity(0.1);
    }
  }

  Color _getBorderColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return AppTheme.primaryOrchid.withOpacity(0.3);
      case SyncStatus.error:
        return AppTheme.dangerRose.withOpacity(0.3);
      case SyncStatus.offline:
        return AppTheme.warningAmber.withOpacity(0.3);
      case SyncStatus.idle:
        return AppTheme.successEmerald.withOpacity(0.3);
    }
  }

  Color _getTextColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return AppTheme.primaryOrchid;
      case SyncStatus.error:
        return AppTheme.dangerRose;
      case SyncStatus.offline:
        return AppTheme.warningAmber;
      case SyncStatus.idle:
        return AppTheme.successEmerald;
    }
  }

  String _getLabel(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.error:
        return 'Sync Error';
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.idle:
        return 'Synced';
    }
  }
}
