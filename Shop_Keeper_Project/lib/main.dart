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
import 'package:shop_keeper_project/features/auth/presentation/screens/pin_lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
    await di.init(isDemoMode: !firebaseInitialized);
  } catch (e) {
    debugPrint('Dependency injection failed: $e');
    // Fallback error screen if injection fails completely
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Critical Initialization Error:\n$e')),
      ),
    ));
    return;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
        BlocProvider(create: (_) => di.sl<InventoryCubit>()),
        BlocProvider(create: (_) => di.sl<SalesCubit>()),
        BlocProvider(create: (_) => di.sl<ExpensesCubit>()),
        BlocProvider(create: (_) => di.sl<AIAssistantCubit>()),
      ],
      child: MaterialApp(
        title: 'ShopKeeper',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const PinLockScreen(),
      ),
    );
  }
}
