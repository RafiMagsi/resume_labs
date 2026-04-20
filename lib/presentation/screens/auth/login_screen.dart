import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/input_validators.dart';
import '../../providers/auth/sign_in_provider.dart';
import '../../widgets/shared/app_button.dart';
import '../../widgets/shared/app_text_field.dart';
import '../../widgets/shared/loading_overlay.dart';
import '../history/history_screen.dart';
import 'password_reset_screen.dart';
import 'register_screen.dart';
import '../../../core/errors/failure.dart';
import '../../widgets/shared/error_dialog.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = 'login';
  static const String routePath = '/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;

  Failure _mapProviderErrorToFailure(Object error) {
    if (error is Failure) return error;

    final message = error.toString().replaceFirst('AsyncError: ', '').trim();

    if (message.toLowerCase().contains('timeout')) {
      return const NetworkFailure('Request timed out. Please try again.');
    }

    if (message.toLowerCase().contains('internet') ||
        message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection')) {
      return NetworkFailure(
          message.isEmpty ? 'No internet connection.' : message);
    }

    if (message.toLowerCase().contains('auth')) {
      return AuthFailure(message.isEmpty ? 'Authentication failed.' : message);
    }

    return ServerFailure(
      message.isEmpty
          ? 'Unable to sign in right now. Please try again.'
          : message,
    );
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();

    ref.listenManual(signInProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (!mounted) return;
          context.go(HistoryScreen.routePath);
        },
        error: (error, _) async {
          if (!mounted) return;

          await ErrorDialog.show(
            context,
            failure: _mapProviderErrorToFailure(error),
            onRetry: _submit,
            title: 'Sign In Failed',
          );
        },
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (ref.read(signInProvider).isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    await ref.read(signInProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final signInState = ref.watch(signInProvider);

    return LoadingOverlay(
      isLoading: signInState.isLoading,
      message: 'Signing you in...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign In'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(20),
              child: FocusTraversalGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Semantics(
                        header: true,
                        child: Text(
                          'Welcome back',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to continue building your resume',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      AppTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: InputValidators.email,
                        focusNode: _emailFocusNode,
                        nextFocusNode: _passwordFocusNode,
                        autofillHints: const [AutofillHints.email],
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: InputValidators.password,
                        focusNode: _passwordFocusNode,
                        autofillHints: const [AutofillHints.password],
                        prefixIcon: const Icon(Icons.lock_outline),
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: AppButton(
                          text: 'Forgot Password?',
                          variant: AppButtonVariant.text,
                          expand: false,
                          onPressed: signInState.isLoading
                              ? null
                              : () {
                                  context.push(PasswordResetScreen.routePath);
                                },
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        text: 'Sign In',
                        isLoading: signInState.isLoading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'Create Account',
                        variant: AppButtonVariant.secondary,
                        onPressed: signInState.isLoading
                            ? null
                            : () {
                                context.push(RegisterScreen.routePath);
                              },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
