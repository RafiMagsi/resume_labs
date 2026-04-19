import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/history/history_screen.dart';
import '../../presentation/screens/resume_builder/builder_screen.dart';
import '../../presentation/screens/resume_builder/preview_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';

final isAuthenticatedProvider = StateProvider<bool>((ref) => false);

final appRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: SplashScreen.routePath,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: SplashScreen.routePath,
        name: SplashScreen.routeName,
        builder: (context, state) {
          debugPrint("Router Splash");
          return const SplashScreen();
        },
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
    redirect: (BuildContext context, GoRouterState state) {
      final location = state.matchedLocation;

      const authPaths = <String>{
        SplashScreen.routePath,
        LoginScreen.routePath,
        RegisterScreen.routePath,
      };

      if (!isAuthenticated && !authPaths.contains(location)) {
        return LoginScreen.routePath;
      }

      if (isAuthenticated &&
          (location == LoginScreen.routePath ||
              location == RegisterScreen.routePath)) {
        return HistoryScreen.routePath;
      }

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.error}'),
      ),
    ),
  );
});