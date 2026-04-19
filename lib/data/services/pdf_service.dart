import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/education.dart';
import '../../domain/entities/resume.dart';
import '../../domain/entities/resume_template.dart';
import '../../domain/entities/skill.dart';
import '../../domain/entities/work_experience.dart';

class PdfService {
  PdfService();

  Future<Uint8List> generateResumePdf({
    required Resume resume,
    required ResumeTemplate template,
  }) async {
    final regularFont = await _loadFont('assets/fonts/Inter-Regular.ttf');
    final mediumFont = await _loadFont('assets/fonts/Inter-Medium.ttf');
    final semiBoldFont = await _loadFont('assets/fonts/Inter-SemiBold.ttf');
    final boldFont = await _loadFont('assets/fonts/Inter-Bold.ttf');

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

    switch (template) {
      case ResumeTemplate.classic:
        _buildClassicTemplate(
          pdf,
          resume,
          regularFont: regularFont,
          mediumFont: mediumFont,
          semiBoldFont: semiBoldFont,
          boldFont: boldFont,
        );
        break;
      case ResumeTemplate.modern:
        _buildModernTemplate(
          pdf,
          resume,
          regularFont: regularFont,
          mediumFont: mediumFont,
          semiBoldFont: semiBoldFont,
          boldFont: boldFont,
        );
        break;
      case ResumeTemplate.minimal:
        _buildMinimalTemplate(
          pdf,
          resume,
          regularFont: regularFont,
          mediumFont: mediumFont,
          semiBoldFont: semiBoldFont,
          boldFont: boldFont,
        );
        break;
    }

    return pdf.save();
  }

  Future<pw.Font> _loadFont(String path) async {
    final data = await rootBundle.load(path);
    return pw.Font.ttf(data);
  }

  void _buildClassicTemplate(
    pw.Document pdf,
    Resume resume, {
    required pw.Font regularFont,
    required pw.Font mediumFont,
    required pw.Font semiBoldFont,
    required pw.Font boldFont,
  }) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        build: (context) => [
          _classicHeader(resume, boldFont, mediumFont),
          pw.SizedBox(height: 18),
          _classicSectionTitle('Professional Summary', semiBoldFont),
          pw.SizedBox(height: 8),
          _bodyText(
            resume.personalSummary.isEmpty
                ? 'No personal summary provided.'
                : resume.personalSummary,
            regularFont,
          ),
          pw.SizedBox(height: 18),
          _classicSectionTitle('Work Experience', semiBoldFont),
          pw.SizedBox(height: 8),
          if (resume.workExperiences.isEmpty)
            _bodyText('No work experience added.', regularFont)
          else
            ...resume.workExperiences.map(
              (item) => _classicWorkExperience(item, regularFont, mediumFont, semiBoldFont),
            ),
          pw.SizedBox(height: 18),
          _classicSectionTitle('Education', semiBoldFont),
          pw.SizedBox(height: 8),
          if (resume.educations.isEmpty)
            _bodyText('No education added.', regularFont)
          else
            ...resume.educations.map(
              (item) => _classicEducation(item, regularFont, mediumFont),
            ),
          pw.SizedBox(height: 18),
          _classicSectionTitle('Skills', semiBoldFont),
          pw.SizedBox(height: 8),
          if (resume.skills.isEmpty)
            _bodyText('No skills added.', regularFont)
          else
            _skillsWrap(
              resume.skills,
              font: regularFont,
              textColor: PdfColors.blueGrey900,
              background: PdfColors.blueGrey50,
              borderColor: PdfColors.blueGrey200,
            ),
        ],
      ),
    );
  }

  void _buildModernTemplate(
    pw.Document pdf,
    Resume resume, {
    required pw.Font regularFont,
    required pw.Font mediumFont,
    required pw.Font semiBoldFont,
    required pw.Font boldFont,
  }) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 30),
        build: (context) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(14),
              gradient: const pw.LinearGradient(
                colors: [
                  PdfColor.fromInt(0xFF6D5EF8),
                  PdfColor.fromInt(0xFF8B7CFF),
                ],
              ),
            ),
            child: pw.Text(
              resume.title.isEmpty ? 'Untitled Resume' : resume.title,
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 24,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          _modernSection(
            title: 'Summary',
            content: [
              _bodyText(
                resume.personalSummary.isEmpty
                    ? 'No personal summary provided.'
                    : resume.personalSummary,
                regularFont,
              ),
            ],
            titleFont: semiBoldFont,
          ),
          pw.SizedBox(height: 16),
          _modernSection(
            title: 'Experience',
            content: resume.workExperiences.isEmpty
                ? [_bodyText('No work experience added.', regularFont)]
                : resume.workExperiences
                    .map((item) => _modernWorkExperience(item, regularFont, mediumFont, semiBoldFont))
                    .toList(),
            titleFont: semiBoldFont,
          ),
          pw.SizedBox(height: 16),
          _modernSection(
            title: 'Education',
            content: resume.educations.isEmpty
                ? [_bodyText('No education added.', regularFont)]
                : resume.educations
                    .map((item) => _modernEducation(item, regularFont, mediumFont))
                    .toList(),
            titleFont: semiBoldFont,
          ),
          pw.SizedBox(height: 16),
          _modernSection(
            title: 'Skills',
            content: [
              if (resume.skills.isEmpty)
                _bodyText('No skills added.', regularFont)
              else
                _skillsWrap(
                  resume.skills,
                  font: regularFont,
                  textColor: const PdfColor.fromInt(0xFF5B21B6),
                  background: const PdfColor.fromInt(0xFFEDE9FE),
                  borderColor: const PdfColor.fromInt(0xFFD8B4FE),
                ),
            ],
            titleFont: semiBoldFont,
          ),
        ],
      ),
    );
  }

  void _buildMinimalTemplate(
    pw.Document pdf,
    Resume resume, {
    required pw.Font regularFont,
    required pw.Font mediumFont,
    required pw.Font semiBoldFont,
    required pw.Font boldFont,
  }) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
        build: (context) => [
          pw.Text(
            resume.title.isEmpty ? 'Untitled Resume' : resume.title,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 22,
              color: PdfColors.grey900,
            ),
          ),
          pw.SizedBox(height: 20),
          _minimalSectionTitle('Summary', semiBoldFont),
          pw.SizedBox(height: 8),
          _bodyText(
            resume.personalSummary.isEmpty
                ? 'No personal summary provided.'
                : resume.personalSummary,
            regularFont,
          ),
          pw.SizedBox(height: 18),
          _minimalSectionTitle('Experience', semiBoldFont),
          pw.SizedBox(height: 8),
          if (resume.workExperiences.isEmpty)
            _bodyText('No work experience added.', regularFont)
          else
            ...resume.workExperiences.map(
              (item) => _minimalWorkExperience(item, regularFont, mediumFont),
            ),
          pw.SizedBox(height: 18),
          _minimalSectionTitle('Education', semiBoldFont),
          pw.SizedBox(height: 8),
          if (resume.educations.isEmpty)
            _bodyText('No education added.', regularFont)
          else
            ...resume.educations.map(
              (item) => _minimalEducation(item, regularFont, mediumFont),
            ),
          pw.SizedBox(height: 18),
          _minimalSectionTitle('Skills', semiBoldFont),
          pw.SizedBox(height: 8),
          if (resume.skills.isEmpty)
            _bodyText('No skills added.', regularFont)
          else
            _skillsWrap(
              resume.skills,
              font: regularFont,
              textColor: PdfColors.grey800,
              background: PdfColors.grey100,
              borderColor: PdfColors.grey300,
            ),
        ],
      ),
    );
  }

  pw.Widget _classicHeader(Resume resume, pw.Font boldFont, pw.Font mediumFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          resume.title.isEmpty ? 'Untitled Resume' : resume.title,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 24,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Container(height: 1.2, color: PdfColors.grey400),
      ],
    );
  }

  pw.Widget _classicSectionTitle(String title, pw.Font font) {
    return pw.Text(
      title.toUpperCase(),
      style: pw.TextStyle(
        font: font,
        fontSize: 12,
        letterSpacing: 1,
        color: PdfColors.black,
      ),
    );
  }

  pw.Widget _minimalSectionTitle(String title, pw.Font font) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        font: font,
        fontSize: 14,
        color: PdfColors.grey800,
      ),
    );
  }

  pw.Widget _modernSection({
    required String title,
    required List<pw.Widget> content,
    required pw.Font titleFont,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF8FAFC),
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: titleFont,
              fontSize: 13,
              color: const PdfColor.fromInt(0xFF6D5EF8),
            ),
          ),
          pw.SizedBox(height: 10),
          ...content,
        ],
      ),
    );
  }

  pw.Widget _classicWorkExperience(
    WorkExperience item,
    pw.Font regularFont,
    pw.Font mediumFont,
    pw.Font semiBoldFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            item.role,
            style: pw.TextStyle(font: semiBoldFont, fontSize: 13),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            '${item.company} - ${item.location}',
            style: pw.TextStyle(font: mediumFont, fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            _formatDateRange(item.startDate, item.endDate, item.isCurrentRole),
            style: pw.TextStyle(font: regularFont, fontSize: 10, color: PdfColors.grey600),
          ),
          if (item.bulletPoints.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            ...item.bulletPoints.map(
              (bullet) => _bulletLine(bullet.toString(), regularFont),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _modernWorkExperience(
    WorkExperience item,
    pw.Font regularFont,
    pw.Font mediumFont,
    pw.Font semiBoldFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            item.role,
            style: pw.TextStyle(font: semiBoldFont, fontSize: 13, color: PdfColors.grey900),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            '${item.company} - ${item.location}',
            style: pw.TextStyle(font: mediumFont, fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            _formatDateRange(item.startDate, item.endDate, item.isCurrentRole),
            style: pw.TextStyle(font: regularFont, fontSize: 10, color: PdfColors.grey600),
          ),
          if (item.bulletPoints.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            ...item.bulletPoints.map(
              (bullet) => _accentBulletLine(
                bullet.toString(),
                regularFont,
                const PdfColor.fromInt(0xFF6D5EF8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _minimalWorkExperience(
    WorkExperience item,
    pw.Font regularFont,
    pw.Font mediumFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            item.role,
            style: pw.TextStyle(font: mediumFont, fontSize: 13, color: PdfColors.grey900),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            '${item.company} - ${item.location}',
            style: pw.TextStyle(font: regularFont, fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            _formatDateRange(item.startDate, item.endDate, item.isCurrentRole),
            style: pw.TextStyle(font: regularFont, fontSize: 10, color: PdfColors.grey600),
          ),
          if (item.bulletPoints.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            ...item.bulletPoints.map(
              (bullet) => _dashLine(bullet.toString(), regularFont),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _classicEducation(Education item, pw.Font regularFont, pw.Font mediumFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            item.degree,
            style: pw.TextStyle(font: mediumFont, fontSize: 12),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            '${item.school} - ${item.field}',
            style: pw.TextStyle(font: regularFont, fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Graduation: ${_formatMonthYear(item.graduationDate)}${item.gpa != null ? ' - GPA: ${item.gpa}' : ''}',
            style: pw.TextStyle(font: regularFont, fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  pw.Widget _modernEducation(Education item, pw.Font regularFont, pw.Font mediumFont) {
    return _classicEducation(item, regularFont, mediumFont);
  }

  pw.Widget _minimalEducation(Education item, pw.Font regularFont, pw.Font mediumFont) {
    return _classicEducation(item, regularFont, mediumFont);
  }

  pw.Widget _skillsWrap(
    List<Skill> skills, {
    required pw.Font font,
    required PdfColor textColor,
    required PdfColor background,
    required PdfColor borderColor,
  }) {
    return pw.Wrap(
      spacing: 6,
      runSpacing: 6,
      children: skills.map((skill) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: background,
            borderRadius: pw.BorderRadius.circular(20),
            border: pw.Border.all(color: borderColor),
          ),
          child: pw.Text(
            '${skill.name} - ${skill.category}',
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: textColor,
            ),
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _bodyText(String text, pw.Font font) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        font: font,
        fontSize: 11,
        lineSpacing: 3,
        color: PdfColors.grey800,
      ),
    );
  }

  pw.Widget _bulletLine(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 5),
            child: pw.Container(
              width: 4,
              height: 4,
              decoration: const pw.BoxDecoration(
                color: PdfColors.black,
                shape: pw.BoxShape.circle,
              ),
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(font: font, fontSize: 10.5, lineSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _accentBulletLine(String text, pw.Font font, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 5),
            child: pw.Container(
              width: 4,
              height: 4,
              decoration: pw.BoxDecoration(
                color: color,
                shape: pw.BoxShape.circle,
              ),
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(font: font, fontSize: 10.5, lineSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _dashLine(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '- ',
            style: pw.TextStyle(font: font, fontSize: 10.5),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(font: font, fontSize: 10.5, lineSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDateRange(DateTime start, DateTime? end, bool isCurrentRole) {
    final startText = _formatMonthYear(start);
    final endText = isCurrentRole || end == null ? 'Present' : _formatMonthYear(end);
    return '$startText - $endText';
  }
}