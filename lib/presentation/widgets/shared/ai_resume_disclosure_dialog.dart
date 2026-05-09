import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class AiResumeDisclosureDialog {
  static const _privacyUrl =
      'https://nextfictiongames.com/resume-labs-privacy-policy/';

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _AiResumeDisclosureDialog(),
    );
    return result ?? false;
  }

  static Future<void> openPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse(_privacyUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched) {
      await Clipboard.setData(const ClipboardData(text: _privacyUrl));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open link. URL copied.')),
      );
    }
  }
}

class _AiResumeDisclosureDialog extends StatelessWidget {
  const _AiResumeDisclosureDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('AI Resume Optimization'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To optimize your resume, Resume Labs will send the selected resume content to OpenAI for AI processing.\n',
            ),
            const Text('This may include:\n'),
            const _Bullet('Professional summary'),
            const _Bullet('Work experience text'),
            const _Bullet('Skills'),
            const _Bullet('Qualifications'),
            const _Bullet('Optional instructions you enter'),
            const SizedBox(height: 12),
            Text(
              'This does not include direct contact information such as your name, email address, phone number, address, or profile photo by default.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'By continuing, you agree to send this content to our AI provider for the requested optimization.',
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () =>
                    AiResumeDisclosureDialog.openPrivacyPolicy(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.secondarySurface,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.dialogRadius),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.dialogRadius),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
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

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
