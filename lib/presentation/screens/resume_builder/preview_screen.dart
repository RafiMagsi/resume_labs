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
import '../../widgets/resume/resume_template_picker_bar.dart';

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

String _getTemplateName(ResumeTemplate template) => template.displayName;

Color _getTemplateColor(ResumeTemplate template) {
  switch (template.name) {
    case 'classic':
      return const Color(0xFF0066CC);
    case 'modern':
      return const Color(0xFF2563EB);
    case 'modernClean':
      return const Color(0xFF1A1A1A);
    case 'minimal':
      return const Color(0xFF6B7280);
    case 'executive':
      return const Color(0xFF1E3A8A);
    case 'modernSidebar':
      return const Color(0xFF2C3E50);
    case 'datascience':
      return const Color(0xFF0EA5E9);
    case 'sales':
      return const Color(0xFFDC2626);
    case 'marketing':
      return const Color(0xFF7C3AED);
    case 'finance':
      return const Color(0xFFB8860B);
    case 'creative':
      return const Color(0xFFD946EF);
    case 'academic':
      return const Color(0xFF0369A1);
    case 'healthcare':
      return const Color(0xFF059669);
    case 'startup':
      return const Color(0xFFF97316);
    default:
      return AppColors.primary;
  }
}

Widget _buildTemplateSection({
    required BuildContext context,
    required String title,
    required List<ResumeTemplate> templates,
    required ResumeTemplate selectedTemplate,
    VoidCallback? onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.sm,
            bottom: AppSizes.sm,
          ),
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
              final templateColor = _getTemplateColor(template);

              return GestureDetector(
                onTap: () {
                  onTemplateChanged(template);
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
                        ? templateColor.withValues(alpha: 0.10)
                        : AppColors.secondarySurface,
                    border: Border.all(
                      color: isSelected ? templateColor : AppColors.border,
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
                                  ? templateColor
                                  : AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 30,
                        height: 3,
                        decoration: BoxDecoration(
                          color: templateColor,
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
  
Future<void> _openTemplatePickerSheet(
  BuildContext context,
  ResumeTemplate selectedTemplate,
) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: AppColors.screenSurface,
    builder: (context) {
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
                  context: context,
                  title: 'Tech & IT',
                  templates: [
                    ResumeTemplate.modernClean,
                    ResumeTemplate.modern,
                    ResumeTemplate.minimal,
                  ],
                  selectedTemplate: selectedTemplate,
                  onSelected: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: AppSizes.md),
                _buildTemplateSection(
                  context: context,
                  title: 'Business & Management',
                  templates: [
                    ResumeTemplate.executive,
                    ResumeTemplate.modernSidebar,
                    ResumeTemplate.classic,
                  ],
                  selectedTemplate: selectedTemplate,
                  onSelected: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: AppSizes.md),
                _buildTemplateSection(
                  context: context,
                  title: 'Sales & Marketing',
                  templates: [
                    ResumeTemplate.sales,
                    ResumeTemplate.marketing,
                  ],
                  selectedTemplate: selectedTemplate,
                  onSelected: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: AppSizes.md),
                _buildTemplateSection(
                  context: context,
                  title: 'Specialized',
                  templates: [
                    ResumeTemplate.datascience,
                    ResumeTemplate.finance,
                    ResumeTemplate.creative,
                    ResumeTemplate.academic,
                    ResumeTemplate.healthcare,
                    ResumeTemplate.startup,
                  ],
                  selectedTemplate: selectedTemplate,
                  onSelected: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: ResumeTemplatePickerBar(
              selectedTemplate: selectedTemplate,
              onChangeTap: () {
                if (isLoading) return;
                _openTemplatePickerSheet(context, selectedTemplate);
              },
              getTemplateName: _getTemplateName,
              getTemplateColor: _getTemplateColor,
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
