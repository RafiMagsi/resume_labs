import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/entities/resume.dart';
import 'base_resume_template.dart';

class ModernTemplate extends BaseResumeTemplate {
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
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 30),
        build: (context) => [
          _header(resume, boldFont),
          pw.SizedBox(height: 20),
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
                          bulletStyle: 'accent',
                          accentColor: const PdfColor.fromInt(0xFF6D5EF8),
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
