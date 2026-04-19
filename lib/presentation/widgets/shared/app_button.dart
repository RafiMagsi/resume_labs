import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

enum AppButtonVariant {
  primary,
  secondary,
  text,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expand;
  final IconData? icon;
  final AppButtonVariant variant;
  final double height;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.expand = true,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.height = AppSizes.buttonHeight,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final child = _ButtonContent(
      text: text,
      icon: icon,
      isLoading: isLoading,
      variant: variant,
    );

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(expand ? double.infinity : 0, height),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            disabledBackgroundColor: AppColors.primaryLight,
            disabledForegroundColor: AppColors.textOnPrimary,
            elevation: 0,
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: child,
        );
        break;

      case AppButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(expand ? double.infinity : 0, height),
            foregroundColor: AppColors.textPrimary,
            backgroundColor: AppColors.white,
            side: const BorderSide(color: AppColors.border),
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: child,
        );
        break;

      case AppButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            minimumSize: Size(expand ? double.infinity : 0, height),
            foregroundColor: AppColors.primary,
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: child,
        );
        break;
    }

    return button;
  }
}

class _ButtonContent extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;

  const _ButtonContent({
    required this.text,
    required this.icon,
    required this.isLoading,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = switch (variant) {
      AppButtonVariant.primary => AppColors.textOnPrimary,
      AppButtonVariant.secondary => AppColors.textPrimary,
      AppButtonVariant.text => AppColors.primary,
    };

    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    final textWidget = Text(
      text,
      style: TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );

    if (icon == null) return textWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: textColor),
        const SizedBox(width: 8),
        textWidget,
      ],
    );
  }
}
