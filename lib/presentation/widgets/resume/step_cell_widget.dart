import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class StepCell extends StatelessWidget {
  final int index;
  final int currentStep;
  final bool isActive;
  final bool isCompleted;
  final bool isFirst;
  final bool isLast;
  final double dotSize;
  final double lineHeight;

  const StepCell({
    super.key,
    required this.index,
    required this.currentStep,
    required this.isActive,
    required this.isCompleted,
    required this.isFirst,
    required this.isLast,
    required this.dotSize,
    required this.lineHeight,
  });

  @override
  Widget build(BuildContext context) {
    final leftColor =
        index - 1 < currentStep ? AppColors.primary : AppColors.border;
    final rightColor =
        index < currentStep ? AppColors.primary : AppColors.border;

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Row(
            children: [
              Expanded(
                child: isFirst
                    ? const SizedBox.shrink()
                    : Container(
                        height: lineHeight,
                        color: leftColor,
                      ),
              ),
              SizedBox(width: dotSize),
              Expanded(
                child: isLast
                    ? const SizedBox.shrink()
                    : Container(
                        height: lineHeight,
                        color: rightColor,
                      ),
              ),
            ],
          ),
        ),
        _StepDot(
          number: index + 1,
          isActive: isActive,
          isCompleted: isCompleted,
          size: dotSize,
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final int number;
  final bool isActive;
  final bool isCompleted;
  final double size;

  const _StepDot({
    required this.number,
    required this.isActive,
    required this.isCompleted,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isActive || isCompleted ? AppColors.primary : AppColors.white,
          shape: BoxShape.circle,
          border: isActive || isCompleted
              ? null
              : Border.all(color: AppColors.inactive),
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              color: isActive || isCompleted
                  ? AppColors.white
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
