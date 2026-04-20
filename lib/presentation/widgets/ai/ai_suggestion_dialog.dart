import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../shared/app_button.dart';

class AiSuggestionDialog extends StatelessWidget {
  final String title;
  final String? description;
  final String suggestion;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;
  final String acceptText;
  final String dismissText;

  const AiSuggestionDialog({
    super.key,
    required this.title,
    required this.suggestion,
    required this.onAccept,
    required this.onDismiss,
    this.description,
    this.acceptText = 'Accept',
    this.dismissText = 'Dismiss',
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String suggestion,
    required VoidCallback onAccept,
    String? description,
    String acceptText = 'Accept',
    String dismissText = 'Dismiss',
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => AiSuggestionDialog(
        title: title,
        suggestion: suggestion,
        description: description,
        acceptText: acceptText,
        dismissText: dismissText,
        onAccept: () {
          Navigator.of(context).pop();
          onAccept();
        },
        onDismiss: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 560),
        decoration: BoxDecoration(
          color: AppColors.screenSurface,
          borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AI Suggestion',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondarySurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: SelectableText(
                suggestion,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: dismissText,
                    variant: AppButtonVariant.secondary,
                    onPressed: onDismiss,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: acceptText,
                    icon: Icons.check_rounded,
                    onPressed: onAccept,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
