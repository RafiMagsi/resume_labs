import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/failure.dart';
import 'error_dialog.dart';

abstract final class DialogManager {
  static Future<void> showMessage(
    BuildContext context, {
    required String title,
    required String message,
    String primaryText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
        ),
        icon: const Icon(Icons.info_outline_rounded),
        title: Text(title),
        content: Text(message),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        buttonPadding: const EdgeInsets.symmetric(horizontal: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(primaryText),
          ),
        ],
      ),
    );
  }

  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String primaryText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
        ),
        icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
        iconPadding: const EdgeInsets.only(top: 20, left: 24, right: 24),
        titlePadding: const EdgeInsets.only(top: 4, left: 24, right: 24),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
        title: Text(title),
        content: Text(message),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        buttonPadding: const EdgeInsets.symmetric(horizontal: 8),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(primaryText),
          ),
        ],
      ),
    );
  }

  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    String primaryText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
        ),
        icon: const Icon(Icons.error_outline_rounded, color: AppColors.error),
        iconPadding: const EdgeInsets.only(top: 20, left: 24, right: 24),
        titlePadding: const EdgeInsets.only(top: 4, left: 24, right: 24),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
        title: Text(title),
        content: Text(message),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        buttonPadding: const EdgeInsets.symmetric(horizontal: 8),
        actions: [
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(primaryText),
          ),
        ],
      ),
    );
  }

  static Future<void> showFailure(
    BuildContext context, {
    required Failure failure,
    VoidCallback? onRetry,
    String? title,
  }) {
    return ErrorDialog.show(
      context,
      failure: failure,
      onRetry: onRetry,
      title: title,
    );
  }

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String cancelText = AppStrings.cancel,
    String confirmText = 'Confirm',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        buttonPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          if (isDestructive)
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              child: Text(confirmText),
            )
          else
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<void> showBlockingLoader(
    BuildContext context, {
    String? message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
          ),
          backgroundColor: AppColors.screenSurface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                if (message != null) ...[
                  const SizedBox(width: 14),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
