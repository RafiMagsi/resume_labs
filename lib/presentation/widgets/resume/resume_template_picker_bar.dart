import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/resume_template.dart';

class ResumeTemplatePickerBar extends StatelessWidget {
  const ResumeTemplatePickerBar({
    super.key,
    required this.selectedTemplate,
    required this.onChangeTap,
    required this.getTemplateName,
    required this.getTemplateColor,
  });

  final ResumeTemplate selectedTemplate;
  final VoidCallback onChangeTap;
  final String Function(ResumeTemplate template) getTemplateName;
  final Color Function(ResumeTemplate template) getTemplateColor;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final templateColor = getTemplateColor(selectedTemplate);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: screenWidth),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.screenSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowCard,
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Template',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    getTemplateName(selectedTemplate),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44, maxWidth: 140),
              child: OutlinedButton.icon(
                onPressed: onChangeTap,
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: const Text('Change'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: templateColor,
                  side: BorderSide(color: templateColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}