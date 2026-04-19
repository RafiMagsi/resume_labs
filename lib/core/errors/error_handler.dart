import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'presentation/app_error_view.dart';

abstract final class ErrorHandler {
  static void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);

      if (kDebugMode) {
        debugPrint('Flutter framework error: ${details.exception}');
        debugPrintStack(stackTrace: details.stack);
      }
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      if (kDebugMode) {
        debugPrint('Uncaught async error: $error');
        debugPrintStack(stackTrace: stack);
      }
      return true;
    };

    ErrorWidget.builder = (FlutterErrorDetails details) {
      return AppErrorView(
        error: details.exception,
        stackTrace: details.stack,
        title: 'UI crashed',
        message: 'A widget failed while building. This custom screen replaced the default Flutter red error screen.',
        onRetry: null,
      );
    };
  }

  static Widget buildErrorScreen(
    Object error,
    StackTrace? stackTrace, {
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) {
    return AppErrorView(
      error: error,
      stackTrace: stackTrace,
      title: title,
      message: message,
      onRetry: onRetry,
    );
  }
}