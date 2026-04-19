import 'package:flutter/material.dart';

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
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 560),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF6D5EF8),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AI Suggestion',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
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
                color: Color(0xFF0F172A),
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: SelectableText(
                suggestion,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: Color(0xFF334155),
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