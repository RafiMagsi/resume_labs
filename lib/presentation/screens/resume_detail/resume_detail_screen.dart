import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/failure.dart';
import '../../../domain/entities/resume.dart';
import '../../../domain/entities/resume_template.dart';
import '../../../domain/entities/work_experience.dart';
import '../../../domain/entities/education.dart';
import '../../../domain/entities/skill.dart';
import '../../../injection/injection_container.dart';
import '../../providers/resume/resume_form_provider.dart';
import '../../providers/resume/resume_list_provider.dart';
import '../../widgets/shared/error_dialog.dart';
import '../../widgets/shared/loading_overlay.dart';
import '../history/history_screen.dart';
import '../resume_builder/builder_screen.dart';

class ResumeDetailScreen extends ConsumerStatefulWidget {
  static const String routeName = 'resume-detail';
  static const String routePath = '/resume-detail';

  const ResumeDetailScreen({super.key});

  @override
  ConsumerState<ResumeDetailScreen> createState() => _ResumeDetailScreenState();
}

class _ResumeDetailScreenState extends ConsumerState<ResumeDetailScreen> {
  bool _isExporting = false;

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);

    try {
      final formState = ref.read(resumeFormProvider);
      final template = ref.read(selectedResumeTemplateProvider);
      final firebasePdfService = ref.read(firebasePdfServiceProvider);

      final resumeData = {
        'title': formState.title,
        'personalSummary': formState.personalSummary,
        'photoUrl': formState.photoUrl,
        'workExperiences': formState.workExperiences
            .map((e) => {
              'role': e.role,
              'company': e.company,
              'location': e.location,
              'startDate': e.startDate.toString(),
              'endDate': e.endDate?.toString(),
              'bulletPoints': e.bulletPoints,
            })
            .toList(),
        'educations': formState.educations
            .map((e) => {
              'degree': e.degree,
              'field': e.field,
              'school': e.school,
              'graduationDate': e.graduationDate.toString(),
              'gpa': e.gpa,
            })
            .toList(),
        'skills': formState.skills
            .map((s) => {'name': s.name})
            .toList(),
      };

      final pdfBytes = await firebasePdfService.generateResumePdf(
        resumeData: resumeData,
        template: template.name,
      );

      if (!mounted) return;

      try {
        await Printing.sharePdf(
          bytes: Uint8List.fromList(pdfBytes),
          filename: '${formState.title}.pdf',
        );
      } catch (e) {
        if (mounted) {
          ErrorDialog.show(
            context,
            failure: ServerFailure('Failed to share PDF: $e'),
            title: 'Share Error',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(
          context,
          failure: ServerFailure('Export failed: $e'),
          title: 'Export Error',
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _handleDelete() async {
    final formState = ref.read(resumeFormProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resume?'),
        content: Text(
          'Are you sure you want to delete "${formState.title}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final useCase = ref.read(deleteResumeUseCaseProvider);
    final result = await useCase(formState.resumeId!);

    if (!mounted) return;

    result.fold(
      (failure) => ErrorDialog.show(
        context,
        failure: failure,
        title: 'Delete Failed',
      ),
      (_) {
        ref.invalidate(resumeListProvider);
        context.go(HistoryScreen.routePath);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(resumeFormProvider);
    final selectedTemplate = ref.watch(selectedResumeTemplateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          formState.title.isEmpty ? 'Resume Preview' : formState.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildTemplateSelector(selectedTemplate),
                const Divider(height: 1),
                SizedBox(
                  height: 600,
                  child: _buildPdfPreview(formState, selectedTemplate),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          if (_isExporting)
            LoadingOverlay(
              isLoading: true,
              child: const SizedBox.expand(),
            ),
        ],
      ),
      bottomNavigationBar: _buildActionBar(),
    );
  }

  Widget _buildTemplateSelector(ResumeTemplate selectedTemplate) {
    return SizedBox(
      height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPadding,
          vertical: AppSizes.md,
        ),
        child: Row(
          children: ResumeTemplate.values.map((template) {
            final isSelected = selectedTemplate == template;
            return GestureDetector(
              onTap: () => ref
                  .read(selectedResumeTemplateProvider.notifier)
                  .state = template,
              child: Container(
                margin: const EdgeInsets.only(right: AppSizes.md),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryLight
                      : AppColors.secondarySurface,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getTemplateName(template),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 30,
                      height: 3,
                      decoration: BoxDecoration(
                        color: _getTemplateColor(template),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPdfPreview(
    ResumeFormState formState,
    ResumeTemplate template,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      child: _ResumePdfPreview(
        template: template,
        title: formState.title,
        personalSummary: formState.personalSummary,
        photoUrl: formState.photoUrl,
        workExperiences: formState.workExperiences,
        educations: formState.educations,
        skills: formState.skills,
        buildPdfBytes: (resume, template) async {
          final firebasePdfService = ref.read(firebasePdfServiceProvider);
          final resumeData = {
            'title': resume.title,
            'personalSummary': resume.personalSummary,
            'photoUrl': resume.photoUrl,
            'workExperiences': resume.workExperiences
                .map((e) => {
                  'role': e.role,
                  'company': e.company,
                  'location': e.location,
                  'startDate': e.startDate.toString(),
                  'endDate': e.endDate?.toString(),
                  'bulletPoints': e.bulletPoints,
                })
                .toList(),
            'educations': resume.educations
                .map((e) => {
                  'degree': e.degree,
                  'field': e.field,
                  'school': e.school,
                  'graduationDate': e.graduationDate.toString(),
                  'gpa': e.gpa,
                })
                .toList(),
            'skills': resume.skills
                .map((s) => {'name': s.name})
                .toList(),
          };

          final pdfBytes = await firebasePdfService.generateResumePdf(
            resumeData: resumeData,
            template: template.name,
          );
          return Uint8List.fromList(pdfBytes);
        },
      ),
    );
  }

  Widget _buildActionBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: SizedBox(
          height: 48,
          width: 400,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                message: 'Delete this resume',
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                  onPressed: _handleDelete,
                ),
              ),
              SizedBox(
                  height: 48,
                  width: 300,
                  child: Row(
                    children: [
                      SizedBox(
                        height: 48,
                        width: 100,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              context.push(BuilderScreen.routePath),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      SizedBox(
                        height: 48,
                        width: 120,
                        child: ElevatedButton.icon(
                          onPressed: _isExporting ? null : _handleExport,
                          icon: const Icon(Icons.share),
                          label: const Text('Export'),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  String _getTemplateName(ResumeTemplate template) {
    switch (template) {
      case ResumeTemplate.classic:
        return 'Classic';
      case ResumeTemplate.modern:
        return 'Modern';
      case ResumeTemplate.modernClean:
        return 'Clean';
      case ResumeTemplate.modernSidebar:
        return 'Sidebar';
      case ResumeTemplate.minimal:
        return 'Minimal';
      case ResumeTemplate.executive:
        return 'Executive';
    }
  }

  Color _getTemplateColor(ResumeTemplate template) {
    switch (template) {
      case ResumeTemplate.classic:
        return AppColors.primary;
      case ResumeTemplate.modern:
        return AppColors.templateModern;
      case ResumeTemplate.modernClean:
        return AppColors.templateModernClean;
      case ResumeTemplate.modernSidebar:
        return AppColors.templateModernSidebar;
      case ResumeTemplate.minimal:
        return AppColors.templateMinimal;
      case ResumeTemplate.executive:
        return AppColors.templateExecutive;
    }
  }
}

class _ResumePdfPreview extends ConsumerStatefulWidget {
  final ResumeTemplate template;
  final String title;
  final String personalSummary;
  final String? photoUrl;
  final List<WorkExperience> workExperiences;
  final List<Education> educations;
  final List<Skill> skills;
  final Future<Uint8List> Function(Resume resume, ResumeTemplate template)
      buildPdfBytes;

  const _ResumePdfPreview({
    required this.template,
    required this.title,
    required this.personalSummary,
    required this.photoUrl,
    required this.workExperiences,
    required this.educations,
    required this.skills,
    required this.buildPdfBytes,
  });

  @override
  ConsumerState<_ResumePdfPreview> createState() => _ResumePdfPreviewState();
}

class _ResumePdfPreviewState extends ConsumerState<_ResumePdfPreview> {
  var _generationToken = 0;
  var _isGenerating = false;

  @override
  void didUpdateWidget(covariant _ResumePdfPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.template != widget.template) {
      setState(() => _isGenerating = true);
    }
  }

  Future<Uint8List> _buildPdf(PdfPageFormat _) async {
    final resume = Resume(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: '',
      title: widget.title.trim(),
      personalSummary: widget.personalSummary.trim(),
      photoUrl: widget.photoUrl,
      workExperiences: widget.workExperiences,
      educations: widget.educations,
      skills: widget.skills,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final token = ++_generationToken;
    if (!_isGenerating && mounted) {
      setState(() => _isGenerating = true);
    }

    try {
      return await widget.buildPdfBytes(resume, widget.template);
    } on Exception catch (e) {
      debugPrint('[ResumeDetailScreen._buildPdf] Exception: $e');
      rethrow;
    } catch (e) {
      debugPrint('[ResumeDetailScreen._buildPdf] Unexpected error: $e');
      throw Exception('Failed to generate PDF: ${e.toString()}');
    } finally {
      if (mounted && token == _generationToken) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.title.trim().isEmpty
        ? 'resume.pdf'
        : '${widget.title.trim()}.pdf';

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: PdfPreview(
        key: ValueKey('pdf-preview-${widget.template.name}'),
        build: _buildPdf,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        allowPrinting: false,
        allowSharing: false,
        pdfFileName: fileName,
        initialPageFormat: PdfPageFormat.a4,
        padding: EdgeInsets.zero,
        onError: (context, error) {
          debugPrint('[PdfPreview] Error: $error');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.description,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Preview not available for large resumes.\nUse Export button to view the full PDF.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

final selectedResumeTemplateProvider =
    StateProvider<ResumeTemplate>((ref) => ResumeTemplate.classic);
