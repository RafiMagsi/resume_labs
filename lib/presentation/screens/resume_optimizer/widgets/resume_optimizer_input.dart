import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class ResumeOptimizerInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onOptimize;

  const ResumeOptimizerInput({
    super.key,
    required this.controller,
    required this.onOptimize,
  });

  @override
  State<ResumeOptimizerInput> createState() => _ResumeOptimizerInputState();
}

class _ResumeOptimizerInputState extends State<ResumeOptimizerInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Resume',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Paste your existing resume text. Our AI will optimize it for impact.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: widget.controller,
            minLines: 10,
            maxLines: 15,
            decoration: InputDecoration(
              hintText: 'Paste your resume here...',
              hintStyle: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 12),
        _buildCharacterCount(),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: widget.controller.text.trim().isEmpty
                ? null
                : widget.onOptimize,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              AppStrings.optimize,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterCount() {
    final charCount = widget.controller.text.length;
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        '$charCount characters',
        style: TextStyle(
          fontSize: 12,
          color: charCount < 100 ? AppColors.warning : AppColors.textTertiary,
        ),
      ),
    );
  }
}
