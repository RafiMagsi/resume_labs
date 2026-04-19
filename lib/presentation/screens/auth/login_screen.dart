import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resume_labs/presentation/providers/auth/sign_in_provider.dart';
import 'package:resume_labs/presentation/widgets/shared/loading_overlay.dart';

import '../../../app/router/app_router.dart';
import '../history/history_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  static const String routeName = 'login';
  static const String routePath = '/login';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: ref.watch(signInProvider).isLoading,
        message: 'Signing you in...',
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(isAuthenticatedProvider.notifier).state = true;
                  context.go(HistoryScreen.routePath);
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.push(RegisterScreen.routePath),
                child: const Text('Create account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}