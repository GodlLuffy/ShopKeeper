import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shop_keeper_project/core/services/sync_engine.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getColor(status).withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _getColor(status).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(status),
            const SizedBox(width: 8),
            Text(
              _getLabel(status).toUpperCase(),
              style: GoogleFonts.outfit(
                color: _getColor(status),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(SyncStatus status) {
    if (status == SyncStatus.syncing) {
      return SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _getColor(status),
        ),
      );
    }
    
    IconData iconData;
    switch (status) {
      case SyncStatus.error:
        iconData = LucideIcons.cloudOff;
        break;
      case SyncStatus.offline:
        iconData = LucideIcons.wifiOff;
        break;
      case SyncStatus.idle:
      default:
        iconData = LucideIcons.cloud;
        break;
    }
    
    return Icon(iconData, size: 14, color: _getColor(status));
  }

  Color _getColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return AppColors.info;
      case SyncStatus.error:
        return AppColors.error;
      case SyncStatus.offline:
        return AppColors.warning;
      case SyncStatus.idle:
      default:
        return AppColors.success;
    }
  }

  String _getLabel(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return 'Syncing';
      case SyncStatus.error:
        return 'Error';
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.idle:
      default:
        return 'Synced';
    }
  }
}
