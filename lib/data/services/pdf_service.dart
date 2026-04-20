import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/resume.dart';
import '../../domain/entities/resume_template.dart';
import 'templates/classic_template.dart';
import 'templates/executive_template.dart';
import 'templates/minimal_template.dart';
import 'templates/modern_clean_template.dart';
import 'templates/modern_sidebar_template.dart';
import 'templates/modern_template.dart';

/// Generates a PDF resume from a [Resume] entity using the specified template.
class PdfService {
  /// Generates a resume PDF with the specified template.
  /// Loads fonts from assets and handles fallbacks gracefully.
  Future<Uint8List> generateResumePdf({
    required Resume resume,
    required ResumeTemplate template,
  }) async {
    final regularFont = await _loadFontWithFallback(
      primary: 'assets/fonts/Inter-Regular.ttf',
      fallback: pw.Font.helvetica(),
    );
    final mediumFont = await _loadFontWithFallback(
      primary: 'assets/fonts/Inter-Medium.ttf',
      fallback: pw.Font.helvetica(),
    );
    final semiBoldFont = await _loadFontWithFallback(
      primary: 'assets/fonts/Inter-SemiBold.ttf',
      fallback: pw.Font.helveticaBold(),
    );
    final boldFont = await _loadFontWithFallback(
      primary: 'assets/fonts/Inter-Bold.ttf',
      fallback: pw.Font.helveticaBold(),
    );

    pw.ImageProvider? photoImage;
    if (resume.photoUrl != null && resume.photoUrl!.isNotEmpty) {
      photoImage = await _loadPhotoImage(resume.photoUrl!);
    }

    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
      italic: regularFont,
      boldItalic: boldFont,
    );

    final pdf = pw.Document(
      title: resume.title,
      author: 'Resume Labs AI',
      theme: theme,
    );

    _buildTemplate(
      pdf,
      resume,
      template,
      photoImage: photoImage,
      regularFont: regularFont,
      mediumFont: mediumFont,
      semiBoldFont: semiBoldFont,
      boldFont: boldFont,
    );

    return pdf.save();
  }

  /// Loads a TrueType font from assets, with fallback support.
  Future<pw.Font> _loadFont(String path) async {
    final data = await rootBundle.load(path);
    return pw.Font.ttf(data);
  }

  /// Loads a font with fallback if primary font is unavailable.
  Future<pw.Font> _loadFontWithFallback({
    required String primary,
    required pw.Font fallback,
  }) async {
    try {
      return await _loadFont(primary);
    } catch (_) {
      return fallback;
    }
  }

  /// Loads a profile photo image from a URL.
  Future<pw.ImageProvider?> _loadPhotoImage(String photoUrl) async {
    try {
      if (photoUrl.isEmpty) {
        return null;
      }

      final normalizedPath =
          photoUrl.startsWith('file://') ? photoUrl.substring(7) : photoUrl;

      if (!kIsWeb && !normalizedPath.startsWith('http')) {
        final file = File(normalizedPath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          if (bytes.isNotEmpty) {
            return pw.MemoryImage(bytes);
          }
        }
        return null;
      }

      if (!normalizedPath.startsWith('http')) return null;

      final response = await http.get(Uri.parse(normalizedPath)).timeout(
            const Duration(seconds: 10),
            onTimeout: () => http.Response('timeout', 408),
          );

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return pw.MemoryImage(response.bodyBytes);
      }
      return null;
    } catch (e) {
      debugPrint('Error loading profile photo: $e');
      return null;
    }
  }

  /// Routes to the appropriate template builder based on [ResumeTemplate].
  void _buildTemplate(
    pw.Document pdf,
    Resume resume,
    ResumeTemplate template, {
    pw.ImageProvider? photoImage,
    required pw.Font regularFont,
    required pw.Font mediumFont,
    required pw.Font semiBoldFont,
    required pw.Font boldFont,
  }) {
    switch (template) {
      case ResumeTemplate.classic:
        ClassicTemplate().build(
          pdf,
          resume,
          photoImage: photoImage,
          regularFont: regularFont,
          mediumFont: mediumFont,
          semiBoldFont: semiBoldFont,
          boldFont: boldFont,
        );
      case ResumeTemplate.modern:
        ModernTemplate().build(
          pdf,
          resume,
          photoImage: photoImage,
          regularFont: regularFont,
          mediumFont: mediumFont,
          semiBoldFont: semiBoldFont,
          boldFont: boldFont,
        );
      case ResumeTemplate.modernClean:
        ModernCleanTemplate().build(
          pdf,
          resume,
          photoImage: photoImage,
          regularFont: regularFont,
          mediumFont: mediumFont,
          semiBoldFont: semiBoldFont,
          boldFont: boldFont,
        );
      case ResumeTemplate.modernSidebar:
        ModernSidebarTemplate().build(
          pdf,
          resume,
          photoImage: photoImage,
          regularFont: regularFont,
          mediumFont: mediumFont,
          semiBoldFont: semiBoldFont,
          boldFont: boldFont,
        );
      case ResumeTemplate.minimal:
        MinimalTemplate().build(
          pdf,
          resume,
          photoImage: photoImage,
          regularFont: regularFont,
          mediumFont: mediumFont,
          semiBoldFont: semiBoldFont,
          boldFont: boldFont,
        );
      case ResumeTemplate.executive:
        ExecutiveTemplate().build(
          pdf,
          resume,
          photoImage: photoImage,
          regularFont: regularFont,
          mediumFont: mediumFont,
          semiBoldFont: semiBoldFont,
          boldFont: boldFont,
        );
    }
  }
}
