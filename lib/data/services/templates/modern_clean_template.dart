import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/entities/resume.dart';
import 'base_resume_template.dart';

class ModernCleanTemplate extends BaseResumeTemplate {
  @override
  void build(
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
        margin: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 32),
        build: (context) => [
          _header(resume, boldFont),
          pw.SizedBox(height: 18),
          _section(
            title: 'Summary',
            content: [
              bodyText(
                resume.personalSummary.isEmpty
                    ? 'No personal summary provided.'
                    : resume.personalSummary,
                regularFont,
              ),
            ],
            titleFont: semiBoldFont,
          ),
          pw.SizedBox(height: 16),
          _section(
            title: 'Experience',
            content: resume.workExperiences.isEmpty
                ? [bodyText('No work experience added.', regularFont)]
                : resume.workExperiences
                    .map((item) => workExperienceItem(
                          item,
                          regularFont,
                          mediumFont,
                          semiBoldFont,
                          bulletStyle: 'dot',
                          accentColor: null,
                        ))
                    .toList(),
            titleFont: semiBoldFont,
          ),
          pw.SizedBox(height: 16),
          _section(
            title: 'Education',
            content: resume.educations.isEmpty
                ? [bodyText('No education added.', regularFont)]
                : resume.educations
                    .map((item) =>
                        educationItem(item, regularFont, mediumFont))
                    .toList(),
            titleFont: semiBoldFont,
          ),
          pw.SizedBox(height: 16),
          _section(
            title: 'Skills',
            content: [
              if (resume.skills.isEmpty)
                bodyText('No skills added.', regularFont)
              else
                skillsWrap(
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

  pw.Widget _header(Resume resume, pw.Font boldFont) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF5F3FF),
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE5E7EB)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 6,
            height: 56,
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFF6C5CE7),
              borderRadius: pw.BorderRadius.circular(99),
            ),
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Text(
              resume.title.isEmpty ? 'Untitled Resume' : resume.title,
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 22,
                color: PdfColors.grey900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _section({
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
}
