import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/features/auth/presentation/screens/login_screen.dart';
import 'package:shop_keeper_project/features/auth/presentation/screens/pin_lock_screen.dart';
import 'package:shop_keeper_project/features/auth/presentation/screens/verify_email_page.dart';
import 'package:shop_keeper_project/features/auth/presentation/screens/forgot_password_page.dart';
import 'package:shop_keeper_project/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:shop_keeper_project/features/inventory/presentation/screens/product_list_screen.dart';
import 'package:shop_keeper_project/features/inventory/presentation/screens/add_product_screen.dart';
import 'package:shop_keeper_project/features/inventory/presentation/screens/product_detail_screen.dart';
import 'package:shop_keeper_project/features/inventory/presentation/screens/restock_calculator_screen.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'package:shop_keeper_project/features/sales/presentation/screens/sales_history_screen.dart';
import 'package:shop_keeper_project/features/sales/presentation/screens/add_sale_screen.dart';
import 'package:shop_keeper_project/features/expenses/presentation/screens/expense_list_screen.dart';
import 'package:shop_keeper_project/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:shop_keeper_project/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:shop_keeper_project/features/analytics/presentation/screens/profit_report_screen.dart';
import 'package:shop_keeper_project/features/auth/presentation/screens/otp_screen.dart';
import 'package:shop_keeper_project/features/auth/presentation/screens/register_screen.dart';
import 'package:shop_keeper_project/features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:shop_keeper_project/features/settings/presentation/screens/settings_screen.dart';
import 'package:shop_keeper_project/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:shop_keeper_project/features/billing/screen/billing_screen.dart';
import 'package:shop_keeper_project/features/customers/presentation/screens/customer_list_screen.dart';
import 'package:shop_keeper_project/features/customers/presentation/screens/customer_profile_screen.dart';
import 'package:shop_keeper_project/features/suppliers/presentation/screens/supplier_list_screen.dart';
import 'package:shop_keeper_project/features/inventory/presentation/screens/edit_product_screen.dart';
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
      final isRegistering = state.matchedLocation == '/register';
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isVerifyEmail = state.matchedLocation == '/verify-email';
      final isForgotPassword = state.matchedLocation == '/forgot-password';

      if (authState is Unauthenticated) {
        if (isLoggingIn || isRegistering || isOnboarding || isForgotPassword) {
          return null;
        }
        return '/login';
      }

      if (authState is EmailVerificationPending) {
        if (isVerifyEmail) return null;
        return '/verify-email';
      }

      if (authState is PinRequired) {
        return isPin ? null : '/pin';
      }

      if (authState is Authenticated) {
        if (isLoggingIn || isSplash || isPin || isVerifyEmail || state.matchedLocation == '/') {
          return '/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
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
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/pin',
        builder: (context, state) => const PinLockScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailPage(),
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
          GoRoute(
            path: 'edit/:id',
            builder: (context, state) {
              final productId = state.pathParameters['id'];
              if (productId == null || productId.isEmpty) {
                return const ProductListScreen();
              }
              return EditProductScreen(productId: productId);
            },
          ),
          GoRoute(
            path: 'restock',
            builder: (context, state) => const RestockCalculatorScreen(),
          ),
          GoRoute(
            path: 'detail',
            builder: (context, state) {
              final extra = state.extra;
              if (extra is ProductEntity) {
                return ProductDetailScreen(product: extra);
              }
              return const ProductListScreen();
            },
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
        path: '/profit-report',
        builder: (context, state) => const ProfitReportScreen(),
      ),
      GoRoute(
        path: '/ai-assistant',
        builder: (context, state) => const AIAssistantScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/billing',
        builder: (context, state) => const BillingScreen(),
      ),
      GoRoute(
        path: '/customers',
        builder: (context, state) => const CustomerListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final customerId = state.pathParameters['id']!;
              return CustomerProfileScreen(customerId: customerId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/suppliers',
        builder: (context, state) => const SupplierListScreen(),
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
