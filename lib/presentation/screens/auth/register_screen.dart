import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/input_validators.dart';
import '../../providers/auth/sign_up_provider.dart';
import '../../widgets/shared/app_button.dart';
import '../../widgets/shared/app_text_field.dart';
import '../../widgets/shared/loading_overlay.dart';
import '../history/history_screen.dart';
import '../../../core/errors/failure.dart';
import '../../widgets/shared/error_dialog.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  static const String routeName = 'register';
  static const String routePath = '/register';

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  late final FocusNode _confirmPasswordFocusNode;

  Failure _mapProviderErrorToFailure(Object error) {
    final message = error.toString().replaceFirst('AsyncError: ', '').trim();

    if (message.toLowerCase().contains('timeout')) {
      return const NetworkFailure('Request timed out. Please try again.');
    }

    if (message.toLowerCase().contains('internet') ||
        message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection')) {
      return NetworkFailure(message.isEmpty ? 'No internet connection.' : message);
    }

    if (message.toLowerCase().contains('auth')) {
      return AuthFailure(message.isEmpty ? 'Authentication failed.' : message);
    }

    if (message.toLowerCase().contains('password') ||
        message.toLowerCase().contains('email')) {
      return ValidationFailure(message);
    }

    return ServerFailure(
      message.isEmpty
          ? 'Unable to create your account right now. Please try again.'
          : message,
    );
  }
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();

    ref.listenManual(signUpProvider, (previous, next) {
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
            title: 'Registration Failed',
          );
        },
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (ref.read(signUpProvider).isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    await ref.read(signUpProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  String? _confirmPasswordValidator(String? value) {
    return InputValidators.confirmPassword(
      value,
      _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: signUpState.isLoading,
        message: 'Creating your account...',
        child: SafeArea(
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
                          'Create your account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start building and saving professional resumes',
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
                      hintText: 'Minimum 8 characters',
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      validator: InputValidators.password,
                      focusNode: _passwordFocusNode,
                      nextFocusNode: _confirmPasswordFocusNode,
                      autofillHints: const [AutofillHints.newPassword],
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: _confirmPasswordValidator,
                      focusNode: _confirmPasswordFocusNode,
                      autofillHints: const [AutofillHints.newPassword],
                      prefixIcon: const Icon(Icons.lock_outline),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      text: 'Create Account',
                      isLoading: signUpState.isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Back to Sign In',
                      variant: AppButtonVariant.secondary,
                      onPressed:
                          signUpState.isLoading ? null : () => context.pop(),
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
