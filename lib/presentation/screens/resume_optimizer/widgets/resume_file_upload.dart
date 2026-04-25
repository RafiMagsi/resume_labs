import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../../../core/constants/app_colors.dart';
import '../../../widgets/shared/app_loader.dart';
import '../../../services/document_parser_service.dart';

class ResumeFileUpload extends StatefulWidget {
  final Function(String) onFileSelected;
  final VoidCallback onUploading;
  final Function(String, String) onError; // error message and file name

  const ResumeFileUpload({
    super.key,
    required this.onFileSelected,
    required this.onUploading,
    required this.onError,
  });

  @override
  State<ResumeFileUpload> createState() => _ResumeFileUploadState();
}

class _ResumeFileUploadState extends State<ResumeFileUpload> {
  String? _selectedFileName;
  bool _isProcessing = false;

  Future<void> _pickFile() async {
    try {
      setState(() => _isProcessing = true);
      widget.onUploading();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc'],
        withData: true,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        setState(() => _selectedFileName = fileName);

        // Extract text from file
        String extractedText = '';

        if (fileName.toLowerCase().endsWith('.docx') ||
            fileName.toLowerCase().endsWith('.doc')) {
          extractedText = await DocumentParserService.extractFromDocx(file);
        } else if (fileName.toLowerCase().endsWith('.pdf')) {
          extractedText = await DocumentParserService.extractFromPdf(file);
        }

        if (!mounted) return;

        if (extractedText.isNotEmpty) {
          widget.onFileSelected(extractedText);
        } else {
          widget.onError(
            'Could not extract text from file',
            fileName,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        widget.onError(
          'Error: ${e.toString()}',
          _selectedFileName ?? 'Unknown file',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryLight, width: 2),
            // Dashed effect with gradient
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isProcessing ? null : _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isProcessing)
                      const AppLoader(
                        size: 48,
                        color: AppColors.primary,
                        strokeWidth: 3,
                      )
                    else
                      Icon(
                        Icons.cloud_upload_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedFileName ?? 'Upload Your Resume',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFileName != null
                          ? 'File selected. Tap to choose another.'
                          : 'PDF, DOCX, or DOC file',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Supported formats: PDF, DOCX, DOC',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
