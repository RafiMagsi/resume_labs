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
import '../../../domain/entities/contact_details.dart';
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
import '../resume_optimizer/resume_optimizer_screen.dart';

class ResumeDetailScreen extends ConsumerStatefulWidget {
  static const String routeName = 'resume-detail';
  static const String routePath = '/resume-detail';

  const ResumeDetailScreen({super.key});

  @override
  ConsumerState<ResumeDetailScreen> createState() => _ResumeDetailScreenState();
}

class _ResumeDetailScreenState extends ConsumerState<ResumeDetailScreen> {
  bool _isExporting = false;
  var _templateSynced = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_templateSynced) {
        final formState = ref.read(resumeFormProvider);
        if (formState.resumeId != null) {
          ref.read(selectedResumeTemplateProvider.notifier).state =
              formState.template;
          _templateSynced = true;
        }
      }
    });
  }

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
        'contactDetails': {
          'fullName': formState.contactDetails.fullName,
          'email': formState.contactDetails.email,
          'phone': formState.contactDetails.phone,
          'location': formState.contactDetails.location,
          'website': formState.contactDetails.website,
          'linkedin': formState.contactDetails.linkedin,
          'github': formState.contactDetails.github,
          'dateOfBirth': formState.contactDetails.dateOfBirth,
          'nationality': formState.contactDetails.nationality,
        },
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
        'skills': formState.skills.map((s) => {'name': s.name}).toList(),
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding,
                  AppSizes.screenPadding,
                  AppSizes.screenPadding,
                  AppSizes.sm,
                ),
                child: _buildTemplatePickerBar(selectedTemplate),
              ),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.screenPadding,
                    AppSizes.sm,
                    AppSizes.screenPadding,
                    AppSizes.sm,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.secondarySurface,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: _buildPdfPreview(formState, selectedTemplate),
                    ),
                  ),
                ),
              ),
            ],
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

  Widget _buildTemplatePickerBar(ResumeTemplate selectedTemplate) {
    final screenWidth = MediaQuery.sizeOf(context).width;

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
                    _getTemplateName(selectedTemplate),
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
                onPressed: () => _openTemplatePickerSheet(selectedTemplate),
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: const Text('Change'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _getTemplateColor(selectedTemplate),
                  side: BorderSide(color: _getTemplateColor(selectedTemplate)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

  Future<void> _openTemplatePickerSheet(ResumeTemplate selectedTemplate) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.screenSurface,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final currentTemplate = ref.watch(selectedResumeTemplateProvider);

            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding,
                  AppSizes.sm,
                  AppSizes.screenPadding,
                  AppSizes.screenPadding,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTemplateSection(
                        title: 'Tech & IT',
                        templates: [
                          ResumeTemplate.modernClean,
                          ResumeTemplate.modern,
                          ResumeTemplate.minimal,
                        ],
                        selectedTemplate: currentTemplate,
                        onSelected: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: AppSizes.md),
                      _buildTemplateSection(
                        title: 'Business & Management',
                        templates: [
                          ResumeTemplate.executive,
                          ResumeTemplate.modernSidebar,
                          ResumeTemplate.classic,
                        ],
                        selectedTemplate: currentTemplate,
                        onSelected: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: AppSizes.md),
                      _buildTemplateSection(
                        title: 'Sales & Marketing',
                        templates: [
                          ResumeTemplate.sales,
                          ResumeTemplate.marketing,
                        ],
                        selectedTemplate: currentTemplate,
                        onSelected: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: AppSizes.md),
                      _buildTemplateSection(
                        title: 'Specialized',
                        templates: [
                          ResumeTemplate.datascience,
                          ResumeTemplate.finance,
                          ResumeTemplate.creative,
                          ResumeTemplate.academic,
                          ResumeTemplate.healthcare,
                          ResumeTemplate.startup,
                        ],
                        selectedTemplate: currentTemplate,
                        onSelected: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTemplateSection({
    required String title,
    required List<ResumeTemplate> templates,
    required ResumeTemplate selectedTemplate,
    VoidCallback? onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: AppSizes.sm, bottom: AppSizes.sm),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: templates.map((template) {
              final isSelected = selectedTemplate == template;
              return GestureDetector(
                onTap: () {
                  ref.read(selectedResumeTemplateProvider.notifier).state =
                      template;
                  ref
                      .read(resumeFormProvider.notifier)
                      .persistTemplateSelection(template);
                  onSelected?.call();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: AppSizes.md),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getTemplateColor(template).withAlpha(25)
                        : AppColors.secondarySurface,
                    border: Border.all(
                      color: isSelected
                          ? _getTemplateColor(template)
                          : AppColors.border,
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
                                  ? _getTemplateColor(template)
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
      ],
    );
  }

  Widget _buildPdfPreview(
    ResumeFormState formState,
    ResumeTemplate template,
  ) {
    return _ResumePdfPreview(
      template: template,
      title: formState.title,
      personalSummary: formState.personalSummary,
      photoUrl: formState.photoUrl,
      contactDetails: formState.contactDetails,
      workExperiences: formState.workExperiences,
      educations: formState.educations,
      skills: formState.skills,
      buildPdfBytes: (resume, template) async {
        final firebasePdfService = ref.read(firebasePdfServiceProvider);
        final resumeData = {
          'title': resume.title,
          'personalSummary': resume.personalSummary,
          'photoUrl': resume.photoUrl,
          'contactDetails': {
            'fullName': resume.contactDetails.fullName,
            'email': resume.contactDetails.email,
            'phone': resume.contactDetails.phone,
            'location': resume.contactDetails.location,
            'website': resume.contactDetails.website,
            'linkedin': resume.contactDetails.linkedin,
            'github': resume.contactDetails.github,
            'dateOfBirth': resume.contactDetails.dateOfBirth,
            'nationality': resume.contactDetails.nationality,
          },
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
          'skills': resume.skills.map((s) => {'name': s.name}).toList(),
        };

        final pdfBytes = await firebasePdfService.generateResumePdf(
          resumeData: resumeData,
          template: template.name,
        );
        return Uint8List.fromList(pdfBytes);
      },
    );
  }

  Widget _buildActionBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: ElevatedButton.icon(
          onPressed: _showOptionsBottomSheet,
          icon: const Icon(Icons.more_vert, size: 20),
          label: const Text('Options'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSizes.sm,
              children: [
                _buildBottomSheetOption(
                  icon: Icons.edit_outlined,
                  label: 'Edit Resume',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(BuilderScreen.routePath);
                  },
                ),
                _buildBottomSheetOption(
                  icon: Icons.share_outlined,
                  label: 'Export as PDF',
                  onTap: () {
                    Navigator.pop(context);
                    _handleExport();
                  },
                  disabled: _isExporting,
                ),
                _buildBottomSheetOption(
                  icon: Icons.auto_awesome,
                  label: 'Optimize with AI',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(ResumeOptimizerScreen.routePath);
                  },
                ),
                const Divider(height: AppSizes.md),
                _buildBottomSheetOption(
                  icon: Icons.delete_outline,
                  label: 'Delete Resume',
                  onTap: () {
                    Navigator.pop(context);
                    _handleDelete();
                  },
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool disabled = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.lg,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isDestructive
                    ? AppColors.error
                    : (disabled ? AppColors.border : AppColors.primary),
              ),
              const SizedBox(width: AppSizes.lg),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? AppColors.error
                      : (disabled ? AppColors.border : AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTemplateName(ResumeTemplate template) => template.displayName;

  Color _getTemplateColor(ResumeTemplate template) {
    return switch (template) {
      // Tech & IT
      ResumeTemplate.classic => const Color(0xFF0066CC),
      ResumeTemplate.modern => const Color(0xFF2563EB),
      ResumeTemplate.modernClean => const Color(0xFF1a1a1a),
      ResumeTemplate.minimal => const Color(0xFF6B7280),

      // Business & Management
      ResumeTemplate.executive => const Color(0xFF1E3A8A),
      ResumeTemplate.modernSidebar => const Color(0xFF2c3e50),

      // AI & Data Science
      ResumeTemplate.datascience => const Color(0xFF0EA5E9),

      // Sales & Business Development
      ResumeTemplate.sales => const Color(0xFFDC2626),

      // Marketing & Communications
      ResumeTemplate.marketing => const Color(0xFF7C3AED),

      // Finance & Accounting
      ResumeTemplate.finance => const Color(0xFFB8860B),

      // Creative & Design
      ResumeTemplate.creative => const Color(0xFFD946EF),

      // Academic & Research
      ResumeTemplate.academic => const Color(0xFF0369A1),

      // Healthcare & Medical
      ResumeTemplate.healthcare => const Color(0xFF059669),

      // Startup & Entrepreneurship
      ResumeTemplate.startup => const Color(0xFFF97316),
    };
  }
}

class _ResumePdfPreview extends ConsumerStatefulWidget {
  final ResumeTemplate template;
  final String title;
  final String personalSummary;
  final String? photoUrl;
  final ContactDetails contactDetails;
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
    required this.contactDetails,
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
      contactDetails: widget.contactDetails,
      template: widget.template,
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
        padding: const EdgeInsets.all(8),
        previewPageMargin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollViewDecoration: const BoxDecoration(
          color: AppColors.secondarySurface,
        ),
        pdfPreviewPageDecoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
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
