import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;
  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void init() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _isOnline = results.any((r) => r != ConnectivityResult.none);
    });

    // Initial check
    _connectivity.checkConnectivity().then((results) {
      _isOnline = results.any((r) => r != ConnectivityResult.none);
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}

/// Widget that shows a banner when offline
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final isOffline = snapshot.hasData && snapshot.data!.every((r) => r == ConnectivityResult.none);
        if (!isOffline) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          color: AppTheme.warningAmber.withOpacity(0.9),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                'OFFLINE MODE — Data will sync when connection restores',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
              ),
            ],
          ),
        );
      },
    );
  }
}
