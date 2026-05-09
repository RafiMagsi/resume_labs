import 'package:flutter/material.dart';

import '../../../widgets/shared/app_button.dart';

class BuilderActions extends StatelessWidget {
  final int currentStep;
  final bool isLoading;
  final VoidCallback onBack;
  final Future<void> Function() onNext;
  final Future<void> Function() onSave;

  const BuilderActions({
    super.key,
    required this.currentStep,
    required this.isLoading,
    required this.onBack,
    required this.onNext,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep == 3;

    return Row(
      children: [
        if (currentStep > 0)
          Expanded(
            child: AppButton(
              text: 'Back',
              variant: AppButtonVariant.secondary,
              onPressed: isLoading ? null : onBack,
            ),
          ),
        if (currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: AppButton(
            text: isLastStep ? 'Save Resume' : 'Next',
            isLoading: isLoading,
            onPressed: isLoading
                ? null
                : () async {
                    if (isLastStep) {
                      await onSave();
                    } else {
                      await onNext();
                    }
                  },
          ),
        ),
      ],
    );
  }
}
