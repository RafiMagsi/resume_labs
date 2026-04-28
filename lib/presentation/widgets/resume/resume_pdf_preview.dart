import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/contact_details.dart';
import '../../../domain/entities/education.dart';
import '../../../domain/entities/resume.dart';
import '../../../domain/entities/resume_template.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/work_experience.dart';
import '../shared/app_loader.dart';

class ResumePdfPreview extends ConsumerStatefulWidget {
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

  const ResumePdfPreview({
    super.key,
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
  ConsumerState<ResumePdfPreview> createState() => _ResumePdfPreviewState();
}

class _ResumePdfPreviewState extends ConsumerState<ResumePdfPreview> {
  var _generationToken = 0;
  var _isGenerating = false;

  @override
  void didUpdateWidget(covariant ResumePdfPreview oldWidget) {
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
      debugPrint('[ResumePdfPreview._buildPdf] Exception: $e');
      rethrow;
    } catch (e) {
      debugPrint('[ResumePdfPreview._buildPdf] Unexpected error: $e');
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
          key: ValueKey('pdf-preview-${widget.template.name}'),
          build: _buildPdf,
          canChangeOrientation: false,
          canChangePageFormat: false,
          canDebug: false,
          allowPrinting: false,
          allowSharing: false,
          pdfFileName: fileName,
          initialPageFormat: PdfPageFormat.a4,
          loadingWidget: const Center(
            child: AppLoader(size: 34, strokeWidth: 3.2),
          ),
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
                            AppLoader(
                              size: 22,
                              color: AppColors.primary,
                              strokeWidth: 2.6,
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
