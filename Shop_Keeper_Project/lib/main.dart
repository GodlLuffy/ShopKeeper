import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/injection_container.dart' as di;
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/features/expenses/presentation/bloc/expenses_cubit.dart';
import 'package:shop_keeper_project/features/ai_assistant/presentation/bloc/ai_assistant_cubit.dart';
import 'package:shop_keeper_project/features/billing/bloc/billing_bloc.dart';
import 'package:shop_keeper_project/features/customers/presentation/bloc/customer_cubit.dart';
import 'package:shop_keeper_project/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:shop_keeper_project/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:shop_keeper_project/core/localization/locale_cubit.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:shop_keeper_project/core/routing/app_router.dart';

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
  try {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await Firebase.initializeApp();
      firebaseInitialized = true;
    } else {
      debugPrint('Skipping default Firebase initialization on ${kIsWeb ? "Web" : "Desktop"} platform.');
    }
  } catch (e) {
    debugPrint('Firebase initialization skipped (Running in Demo Mode): $e');
  }

  try {
    debugPrint('STARTING APP INITIALIZATION...');
    await di.init(isDemoMode: !firebaseInitialized);
    
    debugPrint('CHECKING AUTH STATUS...');
    // Pre-check auth before UI starts
    await di.sl<AuthCubit>().checkAuth();
    
    debugPrint('INITIALIZATION COMPLETE ✅');
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
