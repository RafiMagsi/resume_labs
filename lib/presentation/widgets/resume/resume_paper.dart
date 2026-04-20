import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class ResumePaper extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color backgroundColor;
  final double maxWidth;

  const ResumePaper({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.backgroundColor = AppColors.screenSurface,
    this.maxWidth = 700,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1 / 1.414, // A4
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowCard,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: child,
          ),
        ),
      ),
    );
  }
}
