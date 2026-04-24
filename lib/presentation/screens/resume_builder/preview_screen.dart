import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/entities/education.dart';
import '../../../domain/entities/resume.dart';
import '../../../domain/entities/resume_template.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/work_experience.dart';
import '../../../injection/injection_container.dart';
import '../../providers/pdf/pdf_export_provider.dart';
import '../../providers/docx/docx_export_provider.dart';
import '../../providers/resume/resume_form_provider.dart';
import '../../services/docx_share_service.dart';
import '../../services/pdf_share_service.dart';
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

    ref.listenManual(docxExportProvider, (previous, next) async {
      await next.whenOrNull(
        data: (data) async {
          if (!mounted) return;
          final filePath = data.exportedFilePath;
          if (filePath == null || filePath.trim().isEmpty) return;

          try {
            final shareService = ref.read(docxShareServiceProvider);
            await shareService.shareDocx(filePath: filePath);
          } catch (_) {
            if (!mounted) return;
            await ErrorDialog.show(
              context,
              failure: const ServerFailure(
                'DOCX was exported but could not be shared.',
              ),
              onRetry: _handleExportDocx,
              title: 'Share Failed',
            );
          }
        },
        error: (error, _) async {
          if (!mounted) return;
          await ErrorDialog.show(
            context,
            failure: _mapProviderErrorToFailure(error),
            onRetry: _handleExportDocx,
            title: 'Export Failed',
          );
        },
      );
    });
  }

  Future<void> _handleExport() async {
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

    try {
      final pdfBytes = await firebasePdfService.generateResumePdf(
        resumeData: resumeData,
        template: template.name,
      );

      await Printing.sharePdf(
        bytes: Uint8List.fromList(pdfBytes),
        filename: '${formState.title.trim()}.pdf',
      );
    } catch (e) {
      debugPrint('PDF export error: $e');
      rethrow;
    }
  }

  Future<void> _handleExportDocx() async {
    final formState = ref.read(resumeFormProvider);
    final template = ref.read(selectedResumeTemplateProvider);

    final resume = Resume(
      id: formState.resumeId ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      userId: formState.userId ?? '',
      title: formState.title.trim(),
      personalSummary: formState.personalSummary.trim(),
      photoUrl: formState.photoUrl,
      workExperiences: formState.workExperiences,
      educations: formState.educations,
      skills: formState.skills,
      createdAt: formState.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(docxExportProvider.notifier).exportDocx(
          resume: resume,
          template: template,
        );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(resumeFormProvider);
    final selectedTemplate = ref.watch(selectedResumeTemplateProvider);
    final exportState = ref.watch(pdfExportProvider);
    final docxState = ref.watch(docxExportProvider);
    final isAnyExportLoading = exportState.isLoading || docxState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Preview'),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: isAnyExportLoading,
        message:
            exportState.isLoading ? 'Exporting PDF...' : 'Exporting DOCX...',
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final shortestSide = MediaQuery.sizeOf(context).shortestSide;
              final isWide = constraints.maxWidth >= 900 || shortestSide >= 720;

              final controls = _PreviewControls(
                selectedTemplate: selectedTemplate,
                isLoading: isAnyExportLoading,
                onTemplateChanged: (template) {
                  if (template == null) return;
                  ref.read(selectedResumeTemplateProvider.notifier).state =
                      template;
                },
                onExportPdf: _handleExport,
                onExportDocx: _handleExportDocx,
                onBackToEdit: () {
                  Navigator.of(context).pop();
                },
              );

              final previewWidget = _ResumePdfPreview(
                template: selectedTemplate,
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
  final VoidCallback onExportDocx;
  final VoidCallback onBackToEdit;

  const _PreviewControls({
    required this.selectedTemplate,
    required this.isLoading,
    required this.onTemplateChanged,
    required this.onExportPdf,
    required this.onExportDocx,
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
            text: 'Export DOCX',
            variant: AppButtonVariant.secondary,
            icon: Icons.description_outlined,
            onPressed: isLoading ? null : onExportDocx,
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
      debugPrint('[PreviewScreen._buildPdf] Exception: $e');
      rethrow;
    } catch (e) {
      debugPrint('[PreviewScreen._buildPdf] Unexpected error: $e');
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

    return Stack(
      children: [
        PdfPreview(
          // Force PdfPreview to fully rebuild on template change; otherwise it
          // can keep showing the cached document and never re-call `build`.
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
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !_isGenerating,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: _isGenerating
                  ? Container(
                      color: AppColors.modalBarrier,
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.screenSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadowDialog,
                              blurRadius: 24,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Loading preview...',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}

String _templateLabel(ResumeTemplate template) => template.label;
