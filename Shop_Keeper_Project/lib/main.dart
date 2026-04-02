import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/firebase_options.dart';
import 'package:shop_keeper_project/injection_container.dart' as di;
import 'package:shop_keeper_project/core/services/sync_engine.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/features/expenses/presentation/bloc/expenses_cubit.dart';
import 'package:shop_keeper_project/features/ai_assistant/presentation/bloc/ai_assistant_cubit.dart';
import 'package:shop_keeper_project/features/billing/bloc/billing_bloc.dart';
import 'package:shop_keeper_project/features/customers/presentation/bloc/customer_cubit.dart';
import 'package:shop_keeper_project/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:shop_keeper_project/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:shop_keeper_project/features/suppliers/presentation/bloc/supplier_cubit.dart';
import 'package:shop_keeper_project/core/localization/locale_cubit.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:shop_keeper_project/core/routing/app_router.dart';
import 'package:shop_keeper_project/services/seed_data_service.dart';
import 'package:shop_keeper_project/core/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Global Flutter Error Catcher
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('GLOBAL FLUTTER ERROR: ${details.exception}');
  };

  // Asynchronous Error Catcher
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('GLOBAL ASYNC ERROR: $error');
    return true;
  };

  // Custom Error Widget to prevent black screen on build errors
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.darkBackgroundMain,
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.dangerRose.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.dangerRose.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppTheme.dangerRose, size: 48),
              const SizedBox(height: 16),
              const Text(
                'SYSTEM EXCEPTION',
                style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textWhite, letterSpacing: 2, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Text(
                details.exceptionAsString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  };

  bool firebaseInitialized = false;
  String firebaseInitMessage = 'Demo Mode (Initialization skipped)';

  try {
    debugPrint('INITIALIZING FIREBASE (10s Timeout)...');
    
    // Skip Firebase on Windows for now (can be enabled later)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      debugPrint('Desktop platform detected - skipping Firebase, using Demo Mode');
      firebaseInitMessage = 'Demo Mode (Desktop platform)';
    } else {
      // Initialize Firebase with a timeout to prevent infinite loading
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Firebase connection timed out. Falling back to Demo Mode.');
      });
      firebaseInitialized = true;
      firebaseInitMessage = 'Firebase connected successfully ✅';
      
      // Set background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }
  } catch (e) {
    debugPrint('Firebase initialization failed or timed out: $e');
    firebaseInitMessage = 'Demo Mode (Error: ${e is TimeoutException ? "Connection Timeout" : e})';
  }

  debugPrint('--- APP CONFIGURATION ---');
  debugPrint('Platform: ${Platform.operatingSystem}');
  debugPrint('Status: $firebaseInitMessage');
  debugPrint('-------------------------');

  try {
    debugPrint('STARTING APP INITIALIZATION...');
    await di.init(isDemoMode: !firebaseInitialized).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        debugPrint('INIT: DI initialization timed out');
        throw TimeoutException('App initialization timed out');
      },
    );

    // Initialize Notifications if Firebase is active
    if (firebaseInitialized) {
      await di.sl<NotificationService>().initialize();
      debugPrint('NOTIFICATIONS: Initialized successfully');
    }
    
    debugPrint('CHECKING AUTH STATUS...');
    // Pre-check auth before UI starts
    await di.sl<AuthCubit>().checkAuth().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('INIT: Auth check timed out, continuing...');
      },
    );
    
    debugPrint('INITIALIZATION COMPLETE ✅');
    
    debugPrint('SEEDING DEMO DATA...');
    try {
      await di.sl<SeedDataService>().seedDemoDataIfNeeded();
    } catch (e) {
      debugPrint('SEED: Error during demo data seeding: $e');
    }
  } catch (e) {
    debugPrint('CRITICAL INITIALIZATION FAILURE: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Critical Initialization Error:\n$e\n\nPlease check your internet connection and restart.'),
          ),
        ),
      ),
    ));
    return;
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DateTime? _lastBackgroundTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _lastBackgroundTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_lastBackgroundTime != null) {
        final difference = DateTime.now().difference(_lastBackgroundTime!);
        if (difference.inSeconds >= 300) {
          di.sl<AuthCubit>().requirePin();
        }
      }
      // Trigger sync on resume
      _triggerBackgroundSync();
    }
  }

  void _triggerBackgroundSync() async {
    try {
      // Trigger the new Senior-Level Sync Engine
      if (di.sl.isRegistered<SyncEngine>()) {
        await di.sl<SyncEngine>().syncAll();
      }
    } catch (e) {
      debugPrint('BACKGROUND SYNC ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
        BlocProvider(create: (_) => di.sl<InventoryCubit>()),
        BlocProvider(create: (_) => di.sl<SalesCubit>()),
        BlocProvider(create: (_) => di.sl<ExpensesCubit>()),
        BlocProvider(create: (_) => di.sl<AIAssistantCubit>()),
        BlocProvider(create: (_) => di.sl<BillingBloc>()),
        BlocProvider(create: (_) => di.sl<CustomerCubit>()),
        BlocProvider(create: (_) => di.sl<SupplierCubit>()),
        BlocProvider(create: (_) => di.sl<DashboardCubit>()),
        BlocProvider(create: (_) => di.sl<SettingsCubit>()),
        BlocProvider(create: (_) => di.sl<LocaleCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return BlocBuilder<LocaleCubit, AppLanguage>(
            builder: (context, locale) {
              return MaterialApp.router(
                title: 'ShopKeeper PRO',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                routerConfig: di.sl<AppRouter>().router,
              );
            },
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}
