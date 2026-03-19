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
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'App Error: ${details.exceptionAsString()}\nPlease restart the app.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  };

  bool firebaseInitialized = false;
  try {
    if (!kIsWeb) {
      await Firebase.initializeApp();
      firebaseInitialized = true;
    } else {
      debugPrint('Web/Edge skipping default Firebase initialization (requires options)');
    }
  } catch (e) {
    debugPrint('Firebase initialization failed (Running in Demo Mode): $e');
  }

  try {
      debugPrint('STARTING APP INITIALIZATION...');
      await di.init(isDemoMode: !firebaseInitialized);
      
      debugPrint('CHECKING AUTH STATUS...');
      // Pre-check auth before UI starts to avoid splash hang
      await di.sl<AuthCubit>().checkAuth();
      
      debugPrint('INITIALIZATION COMPLETE ✅');
    } catch (e) {
      debugPrint('CRITICAL INITIALIZATION FAILURE: $e');
      // Fallback error screen if injection fails completely
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
        if (difference.inSeconds >= 30) {
          di.sl<AuthCubit>().requirePin();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()), // No ..checkAuth here, already done in main
        BlocProvider(create: (_) => di.sl<InventoryCubit>()),
        BlocProvider(create: (_) => di.sl<SalesCubit>()),
        BlocProvider(create: (_) => di.sl<ExpensesCubit>()),
        BlocProvider(create: (_) => di.sl<AIAssistantCubit>()),
      ],
      child: MaterialApp.router(
        title: 'ShopKeeper',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: di.sl<AppRouter>().router,
      ),
    );
  }
}


// Minimal placeholders if they don't exist yet to avoid breakages
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}
