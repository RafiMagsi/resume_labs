import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/entities/education.dart';
import '../../../domain/entities/resume.dart';
import '../../../domain/entities/resume_template.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/work_experience.dart';
import '../../providers/pdf/pdf_export_provider.dart';
import '../../providers/resume/resume_form_provider.dart';
import '../../services/pdf_share_service.dart';
import '../../widgets/resume/resume_paper.dart';
import '../../widgets/shared/app_button.dart';
import '../../widgets/shared/loading_overlay.dart';
import '../../../core/errors/failure.dart';
import '../../widgets/shared/error_dialog.dart';

final selectedResumeTemplateProvider =
    StateProvider<ResumeTemplate>((ref) => ResumeTemplate.classic);

class PreviewScreen extends ConsumerStatefulWidget {
  const PreviewScreen({super.key});

  static const String routeName = 'preview';
  static const String routePath = '/preview';

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  Failure _mapProviderErrorToFailure(Object error) {
    if (error is Failure) return error;
    final message = error.toString().replaceFirst('AsyncError: ', '').trim();

    if (message.toLowerCase().contains('timeout')) {
      return const NetworkFailure('Request timed out. Please try again.');
    }

    if (message.toLowerCase().contains('internet') ||
        message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection')) {
      return NetworkFailure(
          message.isEmpty ? 'No internet connection.' : message);
    }

    if (message.toLowerCase().contains('pdf')) {
      return PdfFailure(message.isEmpty ? 'Failed to export PDF.' : message);
    }

    return ServerFailure(
      message.isEmpty
          ? 'Unable to export PDF right now. Please try again.'
          : message,
    );
  }

  @override
  void initState() {
    super.initState();

    ref.listenManual(pdfExportProvider, (previous, next) async {
      await next.whenOrNull(
        data: (data) async {
          if (!mounted) return;
          final filePath = data.exportedFilePath;
          if (filePath == null || filePath.trim().isEmpty) return;

          try {
            final shareService = ref.read(pdfShareServiceProvider);
            await shareService.sharePdf(filePath: filePath);
          } catch (e) {
            if (!mounted) return;
            await ErrorDialog.show(
              context,
              failure:
                  ServerFailure('PDF was exported but could not be shared.'),
              onRetry: _handleExport,
              title: 'Share Failed',
            );
          }
        },
        error: (error, _) async {
          if (!mounted) return;

          await ErrorDialog.show(
            context,
            failure: _mapProviderErrorToFailure(error),
            onRetry: _handleExport,
            title: 'Export Failed',
          );
        },
      );
    });
  }

  Future<void> _handleExport() async {
    final formState = ref.read(resumeFormProvider);
    final template = ref.read(selectedResumeTemplateProvider);

    final resume = Resume(
      id: formState.resumeId ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      userId: formState.userId ?? '',
      title: formState.title.trim(),
      personalSummary: formState.personalSummary.trim(),
      workExperiences: formState.workExperiences,
      educations: formState.educations,
      skills: formState.skills,
      createdAt: formState.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(pdfExportProvider.notifier).exportPdf(
          resume: resume,
          template: template,
        );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(resumeFormProvider);
    final selectedTemplate = ref.watch(selectedResumeTemplateProvider);
    final exportState = ref.watch(pdfExportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Preview'),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: exportState.isLoading,
        message: 'Exporting PDF...',
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final shortestSide = MediaQuery.sizeOf(context).shortestSide;
              final isWide = constraints.maxWidth >= 900 || shortestSide >= 720;

              final controls = _PreviewControls(
                selectedTemplate: selectedTemplate,
                isLoading: exportState.isLoading,
                onTemplateChanged: (template) {
                  if (template == null) return;
                  ref.read(selectedResumeTemplateProvider.notifier).state =
                      template;
                },
                onExportPdf: _handleExport,
                onBackToEdit: () {
                  Navigator.of(context).pop();
                },
              );

              final preview = _ResumePdfPreview(
                template: selectedTemplate,
                title: formState.title,
                personalSummary: formState.personalSummary,
                workExperiences: formState.workExperiences,
                educations: formState.educations,
                skills: formState.skills,
              );

              if (isWide) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 320,
                          child: controls,
                        ),
                        const SizedBox(width: 20),
                        Expanded(child: preview),
                      ],
                    ),
                  ),
                );
              }

              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      controls,
                      const SizedBox(height: 20),
                      preview,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PreviewControls extends StatelessWidget {
  final ResumeTemplate selectedTemplate;
  final bool isLoading;
  final ValueChanged<ResumeTemplate?> onTemplateChanged;
  final VoidCallback onExportPdf;
  final VoidCallback onBackToEdit;

  const _PreviewControls({
    required this.selectedTemplate,
    required this.isLoading,
    required this.onTemplateChanged,
    required this.onExportPdf,
    required this.onBackToEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.screenSurface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowCard,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview Controls',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a resume template and export the final PDF.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Template',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<ResumeTemplate>(
            initialValue: selectedTemplate,
            items: ResumeTemplate.values
                .map(
                  (template) => DropdownMenuItem(
                    value: template,
                    child: Text(_templateLabel(template)),
                  ),
                )
                .toList(),
            onChanged: isLoading ? null : onTemplateChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.secondarySurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            text: 'Export PDF',
            icon: Icons.picture_as_pdf_outlined,
            isLoading: isLoading,
            onPressed: isLoading ? null : onExportPdf,
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'Back to Edit',
            variant: AppButtonVariant.secondary,
            icon: Icons.arrow_back_rounded,
            onPressed: isLoading ? null : onBackToEdit,
          ),
        ],
      ),
    );
  }
}

class _ResumePdfPreview extends StatelessWidget {
  final ResumeTemplate template;
  final String title;
  final String personalSummary;
  final List<WorkExperience> workExperiences;
  final List<Education> educations;
  final List<Skill> skills;

  const _ResumePdfPreview({
    required this.template,
    required this.title,
    required this.personalSummary,
    required this.workExperiences,
    required this.educations,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    final pagePadding = MediaQuery.sizeOf(context).width < 380 ? 16.0 : 28.0;
    return ResumePaper(
      padding: EdgeInsets.all(pagePadding),
      backgroundColor: _backgroundColor(template),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: _buildTemplate(),
      ),
    );
  }

  Widget _buildTemplate() {
    switch (template) {
      case ResumeTemplate.classic:
        return _ClassicResumeLayout(
          title: title,
          personalSummary: personalSummary,
          workExperiences: workExperiences,
          educations: educations,
          skills: skills,
        );
      case ResumeTemplate.modern:
        return _ModernResumeLayout(
          title: title,
          personalSummary: personalSummary,
          workExperiences: workExperiences,
          educations: educations,
          skills: skills,
        );
      case ResumeTemplate.minimal:
        return _MinimalResumeLayout(
          title: title,
          personalSummary: personalSummary,
          workExperiences: workExperiences,
          educations: educations,
          skills: skills,
        );
    }
  }

  Color _backgroundColor(ResumeTemplate template) {
    switch (template) {
      case ResumeTemplate.classic:
        return AppColors.white;
      case ResumeTemplate.modern:
        return const Color(0xFFFCFCFF);
      case ResumeTemplate.minimal:
        return const Color(0xFFFEFEFE);
    }
  }
}

class _ClassicResumeLayout extends StatelessWidget {
  final String title;
  final String personalSummary;
  final List<WorkExperience> workExperiences;
  final List<Education> educations;
  final List<Skill> skills;

  const _ClassicResumeLayout({
    required this.title,
    required this.personalSummary,
    required this.workExperiences,
    required this.educations,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.trim().isEmpty ? 'Untitled Resume' : title.trim(),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Container(height: 1, color: AppColors.divider),
        const SizedBox(height: 16),
        _PreviewSection(
          title: 'Professional Summary',
          color: AppColors.textPrimary,
          child: Text(
            personalSummary.trim().isEmpty
                ? 'Your personal summary will appear here.'
                : personalSummary.trim(),
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _PreviewSection(
          title: 'Work Experience',
          color: AppColors.textPrimary,
          child: workExperiences.isEmpty
              ? const _PreviewEmptyState(
                  message: 'No work experience added yet.',
                )
              : Column(
                  children: workExperiences
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _PreviewWorkItem(item: item),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _PreviewSection(
          title: 'Education',
          color: AppColors.textPrimary,
          child: educations.isEmpty
              ? const _PreviewEmptyState(
                  message: 'No education added yet.',
                )
              : Column(
                  children: educations
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _PreviewEducationItem(item: item),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _PreviewSection(
          title: 'Skills',
          color: AppColors.textPrimary,
          child: _SkillWrap(skills: skills),
        ),
      ],
    );
  }
}

class _ModernResumeLayout extends StatelessWidget {
  final String title;
  final String personalSummary;
  final List<WorkExperience> workExperiences;
  final List<Education> educations;
  final List<Skill> skills;

  const _ModernResumeLayout({
    required this.title,
    required this.personalSummary,
    required this.workExperiences,
    required this.educations,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title.trim().isEmpty ? 'Untitled Resume' : title.trim(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _PreviewSection(
          title: 'Summary',
          color: AppColors.primaryDark,
          child: Text(
            personalSummary.trim().isEmpty
                ? 'Your personal summary will appear here.'
                : personalSummary.trim(),
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _PreviewSection(
          title: 'Experience',
          color: AppColors.primaryDark,
          child: workExperiences.isEmpty
              ? const _PreviewEmptyState(
                  message: 'No work experience added yet.',
                )
              : Column(
                  children: workExperiences
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _PreviewWorkItem(item: item, accent: true),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _PreviewSection(
          title: 'Education',
          color: AppColors.primaryDark,
          child: educations.isEmpty
              ? const _PreviewEmptyState(
                  message: 'No education added yet.',
                )
              : Column(
                  children: educations
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _PreviewEducationItem(item: item),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _PreviewSection(
          title: 'Skills',
          color: AppColors.primaryDark,
          child: _SkillWrap(skills: skills, accent: true),
        ),
      ],
    );
  }
}

class _MinimalResumeLayout extends StatelessWidget {
  final String title;
  final String personalSummary;
  final List<WorkExperience> workExperiences;
  final List<Education> educations;
  final List<Skill> skills;

  const _MinimalResumeLayout({
    required this.title,
    required this.personalSummary,
    required this.workExperiences,
    required this.educations,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.trim().isEmpty ? 'Untitled Resume' : title.trim(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Container(height: 1, color: AppColors.divider),
        const SizedBox(height: 16),
        _PreviewSection(
          title: 'Summary',
          color: AppColors.textSecondary,
          child: Text(
            personalSummary.trim().isEmpty
                ? 'Your personal summary will appear here.'
                : personalSummary.trim(),
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.65,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _PreviewSection(
          title: 'Experience',
          color: AppColors.textSecondary,
          child: workExperiences.isEmpty
              ? const _PreviewEmptyState(
                  message: 'No work experience added yet.',
                )
              : Column(
                  children: workExperiences
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _PreviewWorkItem(item: item, minimal: true),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _PreviewSection(
          title: 'Education',
          color: AppColors.textSecondary,
          child: educations.isEmpty
              ? const _PreviewEmptyState(
                  message: 'No education added yet.',
                )
              : Column(
                  children: educations
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _PreviewEducationItem(item: item),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _PreviewSection(
          title: 'Skills',
          color: AppColors.textSecondary,
          child: _SkillWrap(skills: skills, minimal: true),
        ),
      ],
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final String title;
  final Color color;
  final Widget child;

  const _PreviewSection({
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.divider,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _PreviewEmptyState extends StatelessWidget {
  final String message;

  const _PreviewEmptyState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        fontSize: 13.5,
        height: 1.4,
        color: AppColors.textTertiary,
      ),
    );
  }
}

class _PreviewWorkItem extends StatelessWidget {
  final WorkExperience item;
  final bool accent;
  final bool minimal;

  const _PreviewWorkItem({
    required this.item,
    this.accent = false,
    this.minimal = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = _formatDateRange(
      item.startDate,
      item.endDate,
      item.isCurrentRole,
    );

    final bulletColor = accent ? AppColors.primary : AppColors.textSecondary;
    final bullets = item.bulletPoints
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.role,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${item.company} • ${item.location}',
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateText,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
        if (bullets.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...bullets.map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Icon(
                      minimal ? Icons.remove : Icons.circle,
                      size: minimal ? 14 : 5,
                      color: bulletColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bullet,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PreviewEducationItem extends StatelessWidget {
  final Education item;

  const _PreviewEducationItem({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.degree,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${item.school} • ${item.field}',
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Graduation: ${_formatMonthYear(item.graduationDate)}${item.gpa != null ? ' • GPA: ${item.gpa}' : ''}',
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SkillWrap extends StatelessWidget {
  final List<Skill> skills;
  final bool accent;
  final bool minimal;

  const _SkillWrap({
    required this.skills,
    this.accent = false,
    this.minimal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return const _PreviewEmptyState(
        message: 'No skills added yet.',
      );
    }

    final background = accent
        ? AppColors.primaryLight
        : minimal
            ? AppColors.secondarySurface
            : AppColors.secondarySurface;

    final textColor = accent ? AppColors.primaryDark : AppColors.textSecondary;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            skill.category.trim().isEmpty
                ? skill.name
                : '${skill.name} • ${skill.category}',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        );
      }).toList(),
    );
  }
}

String _templateLabel(ResumeTemplate template) {
  switch (template) {
    case ResumeTemplate.classic:
      return 'Classic';
    case ResumeTemplate.modern:
      return 'Modern';
    case ResumeTemplate.minimal:
      return 'Minimal';
  }
}

String _formatMonthYear(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

String _formatDateRange(DateTime start, DateTime? end, bool isCurrentRole) {
  final startText = _formatMonthYear(start);
  final endText =
      isCurrentRole || end == null ? 'Present' : _formatMonthYear(end);
  return '$startText - $endText';
}
