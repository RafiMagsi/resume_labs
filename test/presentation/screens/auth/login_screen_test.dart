import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:resume_labs/presentation/providers/auth/sign_in_provider.dart';
import 'package:resume_labs/presentation/providers/auth/sign_up_provider.dart';
import 'package:resume_labs/presentation/screens/auth/login_screen.dart';
import 'package:resume_labs/presentation/screens/auth/register_screen.dart';

class TestSignInNotifier extends SignInNotifier {
  @override
  Future<void> build() async {}
}

class TestSignUpNotifier extends SignUpNotifier {
  @override
  Future<void> build() async {}
}

void main() {
  GoRouter createRouter() => GoRouter(
        initialLocation: LoginScreen.routePath,
        routes: [
          GoRoute(
            path: '/',
            redirect: (_, __) => LoginScreen.routePath,
          ),
          GoRoute(
            path: LoginScreen.routePath,
            builder: (_, __) => const LoginScreen(),
          ),
          GoRoute(
            path: RegisterScreen.routePath,
            builder: (_, __) => const RegisterScreen(),
          ),
        ],
      );

  Widget buildApp(GoRouter router) {
    return ProviderScope(
      overrides: [
        signInProvider.overrideWith(TestSignInNotifier.new),
        signUpProvider.overrideWith(TestSignUpNotifier.new),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('renders core fields and buttons', (tester) async {
    final router = createRouter();
    await tester.pumpWidget(buildApp(router));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.byType(LoginScreen).evaluate().isNotEmpty) break;
    }
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.byKey(const ValueKey('loading-overlay-off')).evaluate().isNotEmpty) {
        break;
      }
    }
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.byKey(const ValueKey('loading-overlay')).evaluate().isEmpty) {
        break;
      }
    }

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('loading-overlay-off')), findsOneWidget);
    expect(find.byKey(const ValueKey('loading-overlay')), findsNothing);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });

  testWidgets('navigates to register screen', (tester) async {
    final router = createRouter();
    await tester.pumpWidget(buildApp(router));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.byType(LoginScreen).evaluate().isNotEmpty) break;
    }
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.byKey(const ValueKey('loading-overlay-off')).evaluate().isNotEmpty) {
        break;
      }
    }
    expect(find.byKey(const ValueKey('loading-overlay-off')), findsOneWidget);
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.byKey(const ValueKey('loading-overlay')).evaluate().isEmpty) {
        break;
      }
    }
    expect(find.byKey(const ValueKey('loading-overlay')), findsNothing);

    await router.push(RegisterScreen.routePath);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.byType(RegisterScreen).evaluate().isNotEmpty) break;
    }

    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}
