import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/failure.dart';
import 'app_button.dart';

class ErrorDialog extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final String? title;

  const ErrorDialog({
    super.key,
    required this.failure,
    this.onRetry,
    this.onDismiss,
    this.title,
  });

  static Future<void> show(
    BuildContext context, {
    required Failure failure,
    VoidCallback? onRetry,
    String? title,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => ErrorDialog(
        failure: failure,
        title: title,
        onRetry: () {
          Navigator.of(context).pop();
          if (onRetry != null) {
            onRetry();
          }
        },
        onDismiss: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final message = _mapFailureToMessage(failure);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 34,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: AppStrings.dismiss,
                    variant: AppButtonVariant.secondary,
                    onPressed: onDismiss ??
                        () {
                          Navigator.of(context).pop();
                        },
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: AppStrings.retry,
                      icon: Icons.refresh_rounded,
                      onPressed: onRetry,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure.message.trim().isNotEmpty) return failure.message.trim();

    switch (failure) {
      case AuthFailure():
        return AppStrings.authError;
      case NetworkFailure():
        return AppStrings.networkError;
      case ServerFailure():
        return AppStrings.serverError;
      case CacheFailure():
        return AppStrings.cacheError;
      case ValidationFailure():
        return AppStrings.fieldRequired;
      case PdfFailure():
        return AppStrings.unexpectedError;
      case UnknownFailure():
        return AppStrings.unexpectedError;
    }
  }
}
