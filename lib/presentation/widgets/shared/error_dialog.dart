import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/failure.dart';

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

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
      ),
      icon: const Icon(Icons.error_outline_rounded, color: AppColors.error),
      iconPadding: const EdgeInsets.only(top: 20, left: 24, right: 24),
      titlePadding: const EdgeInsets.only(top: 4, left: 24, right: 24),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      title: Text(title ?? 'Something went wrong'),
      content: Text(message),
      actionsAlignment: MainAxisAlignment.end,
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      buttonPadding: const EdgeInsets.symmetric(horizontal: 8),
      actions: [
        TextButton(
          onPressed: onDismiss ??
              () {
                Navigator.of(context).pop();
              },
          child: const Text(AppStrings.dismiss),
        ),
        if (onRetry != null)
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Text(AppStrings.retry),
          ),
      ],
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
      case DocxFailure():
        return AppStrings.unexpectedError;
      case UnknownFailure():
        return AppStrings.unexpectedError;
    }
  }
}
