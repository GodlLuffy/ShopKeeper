import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/features/auth/presentation/screens/login_screen.dart';
import 'package:shop_keeper_project/features/auth/presentation/screens/pin_lock_screen.dart';
import 'package:shop_keeper_project/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:shop_keeper_project/features/inventory/presentation/screens/product_list_screen.dart';
import 'package:shop_keeper_project/features/inventory/presentation/screens/add_product_screen.dart';
import 'package:shop_keeper_project/features/sales/presentation/screens/sales_history_screen.dart';
import 'package:shop_keeper_project/features/sales/presentation/screens/add_sale_screen.dart';
import 'package:shop_keeper_project/features/expenses/presentation/screens/expense_list_screen.dart';
import 'package:shop_keeper_project/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:shop_keeper_project/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:shop_keeper_project/features/auth/presentation/screens/otp_screen.dart';
import 'package:shop_keeper_project/features/auth/presentation/screens/register_screen.dart';
import 'package:shop_keeper_project/features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:shop_keeper_project/main.dart';

class AppRouter {
  final AuthCubit authCubit;

  AppRouter(this.authCubit);

  late final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: AuthRouterNotifier(authCubit),
    redirect: (context, state) {
      final authState = authCubit.state;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/splash';
      final isPin = state.matchedLocation == '/pin';

      if (authState is Unauthenticated) {
        return isLoggingIn ? null : '/login';
      }

      if (authState is PinRequired) {
        return isPin ? null : '/pin';
      }

      if (authState is Authenticated) {
        if (isLoggingIn || isSplash || isPin) {
          return '/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'otp',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return OtpScreen(
                verificationId: extra['verificationId'] as String,
                phoneNumber: extra['phoneNumber'] as String,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/pin',
        builder: (context, state) => const PinLockScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const ProductListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddProductScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/sales',
        builder: (context, state) => const SalesHistoryScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddSaleScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/expenses',
        builder: (context, state) => const ExpenseListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddExpenseScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/ai-assistant',
        builder: (context, state) => const AIAssistantScreen(),
      ),
    ],
  );
}

class AuthRouterNotifier extends ChangeNotifier {
  final AuthCubit authCubit;

  AuthRouterNotifier(this.authCubit) {
    authCubit.stream.listen((state) {
      notifyListeners();
    });
  }
}
