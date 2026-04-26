import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/domain/enums/user_role.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/user/presentation/user_home_page.dart';
import '../../features/home/caregiver/presentation/caregiver_home_page.dart';
import '../../features/home/admin/presentation/admin_home_page.dart';
import '../../features/home/user/presentation/pages/add_medication_page.dart';
import '../../features/home/user/presentation/pages/low_stock_detail_page.dart';
import '../../features/home/user/presentation/pages/history_page.dart';
import '../../features/home/user/presentation/pages/settings_page.dart';
import 'app_routes.dart';

GoRouter createRouter(AuthController authController) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authController,
    redirect: (BuildContext context, GoRouterState state) {
      final status = authController.status;
      final location = state.matchedLocation;

      if (status == AuthStatus.initial) return AppRoutes.splash;

      const publicRoutes = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
      ];

      if (status == AuthStatus.unauthenticated || status == AuthStatus.error) {
        if (publicRoutes.contains(location)) return null;
        return authController.onboardingCompleted
            ? AppRoutes.login
            : AppRoutes.onboarding;
      }

      if (status == AuthStatus.authenticated) {
        if (!publicRoutes.contains(location)) return null;

        final role = authController.currentUser?.role ?? UserRole.usuario;
        return switch (role) {
          UserRole.admin => AppRoutes.adminHome,
          UserRole.cuidador => AppRoutes.caregiverHome,
          UserRole.usuario => AppRoutes.userHome,
        };
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.userHome,
        builder: (context, state) => const UserHomePage(),
      ),
      GoRoute(
        path: AppRoutes.caregiverHome,
        builder: (context, state) => const CaregiverHomePage(),
      ),
      GoRoute(
        path: AppRoutes.adminHome,
        builder: (context, state) => const AdminHomePage(),
      ),
      GoRoute(
        path: AppRoutes.addMedication,
        builder: (context, state) => const AddMedicationPage(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.lowStockDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return LowStockDetailPage(
            medName: extra['medName'] as String? ?? '',
            dose: extra['dose'] as String? ?? '',
            remaining: extra['remaining'] as int? ?? 0,
            estimatedTotal: extra['estimatedTotal'] as int? ?? 30,
          );
        },
      ),
    ],
  );
}
