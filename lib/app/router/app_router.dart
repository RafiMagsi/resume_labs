import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../presentation/providers/auth/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/password_reset_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/resume_optimizer/resume_optimizer_screen.dart';
import '../../presentation/screens/history/history_screen.dart';
import '../../presentation/screens/resume_builder/builder_screen.dart';
import '../../presentation/screens/resume_builder/preview_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  CustomTransitionPage<T> buildPageWithDefaultTransition<T>({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        final fade = FadeTransition(opacity: curved, child: child);
        final slide = SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.02, 0.0),
            end: Offset.zero,
          ).animate(curved),
          child: fade,
        );

        return slide;
      },
    );
  }

  return GoRouter(
    initialLocation: SplashScreen.routePath,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: SplashScreen.routePath,
        name: SplashScreen.routeName,
        pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: LoginScreen.routePath,
        name: LoginScreen.routeName,
        pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: RegisterScreen.routePath,
        name: RegisterScreen.routeName,
        pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
          state: state,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: PasswordResetScreen.routePath,
        name: PasswordResetScreen.routeName,
        pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
          state: state,
          child: const PasswordResetScreen(),
        ),
      ),
      GoRoute(
        path: HistoryScreen.routePath,
        name: HistoryScreen.routeName,
        pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
          state: state,
          child: const HistoryScreen(),
        ),
      ),
      GoRoute(
        path: BuilderScreen.routePath,
        name: BuilderScreen.routeName,
        pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
          state: state,
          child: const BuilderScreen(),
        ),
      ),
      GoRoute(
        path: PreviewScreen.routePath,
        name: PreviewScreen.routeName,
        pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
          state: state,
          child: const PreviewScreen(),
        ),
      ),
      GoRoute(
        path: ResumeOptimizerScreen.routePath,
        name: ResumeOptimizerScreen.routeName,
        pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
          state: state,
          child: const ResumeOptimizerScreen(),
        ),
      ),
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;

      const publicPaths = <String>{
        SplashScreen.routePath,
        LoginScreen.routePath,
        RegisterScreen.routePath,
        PasswordResetScreen.routePath,
      };

      final isPublicRoute = publicPaths.contains(location);

      return authState.when(
        loading: () {
          if (location == SplashScreen.routePath) return null;
          return SplashScreen.routePath;
        },
        error: (_, __) {
          if (isPublicRoute && location != SplashScreen.routePath) {
            return null;
          }
          return LoginScreen.routePath;
        },
        data: (user) {
          final isAuthenticated = user != null;

          if (!isAuthenticated) {
            if (location == SplashScreen.routePath) {
              return LoginScreen.routePath;
            }

            if (isPublicRoute) {
              return null;
            }

            return LoginScreen.routePath;
          }

          // Default authenticated landing screen
          if (location == SplashScreen.routePath ||
              location == LoginScreen.routePath ||
              location == RegisterScreen.routePath ||
              location == PasswordResetScreen.routePath) {
            return HistoryScreen.routePath;
          }

          return null;
        },
      );
    },
    errorBuilder: (context, state) => Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Page not found',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.error?.toString() ??
                        'The requested route is unavailable.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => context.go(HistoryScreen.routePath),
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
});
