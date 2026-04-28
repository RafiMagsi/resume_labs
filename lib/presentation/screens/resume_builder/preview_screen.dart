import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/entities/resume_template.dart';
import '../../../injection/injection_container.dart';
import '../../providers/resume/resume_form_provider.dart';
import '../../widgets/shared/app_button.dart';
import '../../widgets/shared/loading_overlay.dart';
import '../../widgets/resume/resume_pdf_preview.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  const PreviewScreen({super.key});

  static const String routeName = 'preview';
  static const String routePath = '/preview';

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleExport() async {
    if (_isExporting) return;

    setState(() => _isExporting = true);

    try {
      final formState = ref.read(resumeFormProvider);
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
        template: formState.template.name,
      );

      if (!mounted) return;

      await Printing.sharePdf(
        bytes: Uint8List.fromList(pdfBytes),
        filename: '${formState.title.trim()}.pdf',
      );
    } catch (e) {
      debugPrint('PDF export error: $e');
      if (mounted) {
        setState(() => _isExporting = false);
      }
      rethrow;
    }

    if (mounted) {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(resumeFormProvider);
    final selectedTemplate = formState.template;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Preview'),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: _isExporting,
        message: 'Exporting PDF...',
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final shortestSide = MediaQuery.sizeOf(context).shortestSide;
              final isWide = constraints.maxWidth >= 900 || shortestSide >= 720;

              final controls = _PreviewControls(
                selectedTemplate: selectedTemplate,
                isLoading: _isExporting,
                onTemplateChanged: (template) {
                  if (template == null) return;
                  ref
                      .read(resumeFormProvider.notifier)
                      .persistTemplateSelection(template);
                },
                onExportPdf: _handleExport,
                onBackToEdit: () {
                  Navigator.of(context).pop();
                },
              );

              final previewWidget = ResumePdfPreview(
                template: selectedTemplate,
                title: formState.title,
                personalSummary: formState.personalSummary,
                photoUrl: formState.photoUrl,
                contactDetails: formState.contactDetails,
                workExperiences: formState.workExperiences,
                educations: formState.educations,
                skills: formState.skills,
                buildPdfBytes: (resume, template) async {
                  final firebasePdfService =
                      ref.read(firebasePdfServiceProvider);
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
                    'skills':
                        resume.skills.map((s) => {'name': s.name}).toList(),
                  };

                  final pdfBytes = await firebasePdfService.generateResumePdf(
                    resumeData: resumeData,
                    template: template.name,
                  );
                  return Uint8List.fromList(pdfBytes);
                },
              );

              final preview = isWide
                  ? previewWidget
                  : SizedBox(
                      height: (constraints.maxWidth * 1.25).clamp(420.0, 760.0),
                      child: previewWidget,
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

              return _MobilePreviewLayout(
                selectedTemplate: selectedTemplate,
                isLoading: _isExporting,
                preview: previewWidget,
                onTemplateChanged: (template) {
                  if (template == null) return;
                  ref
                      .read(resumeFormProvider.notifier)
                      .persistTemplateSelection(template);
                },
                onExportPdf: _handleExport,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MobilePreviewLayout extends StatelessWidget {
  final ResumeTemplate selectedTemplate;
  final bool isLoading;
  final Widget preview;
  final ValueChanged<ResumeTemplate?> onTemplateChanged;
  final VoidCallback onExportPdf;

  const _MobilePreviewLayout({
    required this.selectedTemplate,
    required this.isLoading,
    required this.preview,
    required this.onTemplateChanged,
    required this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: _PreviewControlsCompact(
              selectedTemplate: selectedTemplate,
              isLoading: isLoading,
              onTemplateChanged: onTemplateChanged,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.secondarySurface,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: preview,
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: AppButton(
                text: 'Export PDF',
                icon: Icons.picture_as_pdf_outlined,
                isLoading: isLoading,
                onPressed: isLoading ? null : onExportPdf,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewControlsCompact extends StatelessWidget {
  final ResumeTemplate selectedTemplate;
  final bool isLoading;
  final ValueChanged<ResumeTemplate?> onTemplateChanged;

  const _PreviewControlsCompact({
    required this.selectedTemplate,
    required this.isLoading,
    required this.onTemplateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.screenSurface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
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
          const Expanded(
            child: Text(
              'Template',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 140, maxWidth: 240),
              child: DropdownButtonFormField<ResumeTemplate>(
                initialValue: selectedTemplate,
                isExpanded: true,
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
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.secondarySurface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            ),
          ),
        ],
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

String _templateLabel(ResumeTemplate template) => template.label;
