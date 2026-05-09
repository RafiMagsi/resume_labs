import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../widgets/resume/step_cell_widget.dart';

class BuilderStepHeader extends StatelessWidget {
  final int currentStep;

  const BuilderStepHeader({
    super.key,
    required this.currentStep,
  });

  static const _labels = [
    'Personal Info',
    'Work Exp',
    'Education',
    'Skills',
  ];

  @override
  Widget build(BuildContext context) {
    const dotSize = 32.0;
    const lineHeight = 2.0;

    return Column(
      children: [
        SizedBox(
          height: dotSize,
          child: Row(
            children: List.generate(_labels.length, (index) {
              final isCompleted = index < currentStep;
              final isActive = index == currentStep;

              return Expanded(
                child: StepCell(
                  index: index,
                  isActive: isActive,
                  isCompleted: isCompleted,
                  isLast: index == _labels.length - 1,
                  isFirst: index == 0,
                  dotSize: dotSize,
                  lineHeight: lineHeight,
                  currentStep: currentStep,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(_labels.length, (index) {
            final isActive = index == currentStep;
            return Expanded(
              child: Text(
                _labels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
