import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/password_reset_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/history/history_screen.dart';
import '../../presentation/screens/resume_builder/builder_screen.dart';
import '../../presentation/screens/resume_builder/preview_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: SplashScreen.routePath,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: SplashScreen.routePath,
        name: SplashScreen.routeName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: LoginScreen.routePath,
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RegisterScreen.routePath,
        name: RegisterScreen.routeName,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: PasswordResetScreen.routePath,
        name: PasswordResetScreen.routeName,
        builder: (context, state) => const PasswordResetScreen(),
      ),
      GoRoute(
        path: HistoryScreen.routePath,
        name: HistoryScreen.routeName,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: BuilderScreen.routePath,
        name: BuilderScreen.routeName,
        builder: (context, state) => const BuilderScreen(),
      ),
      GoRoute(
        path: PreviewScreen.routePath,
        name: PreviewScreen.routeName,
        builder: (context, state) => const PreviewScreen(),
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

      final isGoingToPublicRoute = publicPaths.contains(location);

      return authState.when(
        loading: () {
          // While auth state is resolving, keep the user on splash.
          if (location == SplashScreen.routePath) return null;
          return SplashScreen.routePath;
        },
        error: (_, __) {
          // If auth stream fails, force user to login unless already on public page.
          if (location == LoginScreen.routePath ||
              location == RegisterScreen.routePath ||
              location == PasswordResetScreen.routePath) {
            return null;
          }
          return LoginScreen.routePath;
        },
        data: (user) {
          final isAuthenticated = user != null;

          if (!isAuthenticated) {
            // Unauthenticated users can only access public routes.
            if (isGoingToPublicRoute) {
              // Do not keep them on splash forever once auth is resolved.
              if (location == SplashScreen.routePath) {
                return LoginScreen.routePath;
              }
              return null;
            }

            return LoginScreen.routePath;
          }

          // Authenticated users should not stay on auth screens or splash.
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
      body: Center(
        child: Text('Route not found: ${state.error}'),
      ),
    ),
  );
});