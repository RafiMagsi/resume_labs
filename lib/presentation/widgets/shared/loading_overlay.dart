import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import 'app_loader.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: isLoading
                ? Semantics(
                    key: const ValueKey('loading-overlay'),
                    label: 'Loading',
                    liveRegion: true,
                    child: AbsorbPointer(
                      absorbing: true,
                      child: Container(
                        color: AppColors.modalBarrier,
                        alignment: Alignment.center,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 240),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.screenSurface,
                            borderRadius:
                                BorderRadius.circular(AppSizes.dialogRadius),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadowDialog,
                                blurRadius: 28,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: 28,
                                width: 28,
                                child: AppLoader(
                                  size: 28,
                                  color: AppColors.primary,
                                  strokeWidth: 3,
                                ),
                              ),
                              if (message != null) ...[
                                const SizedBox(height: 14),
                                Text(
                                  message!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('loading-overlay-off')),
          ),
        ),
      ],
    );
  }
}
