import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/entities/resume.dart';
import 'base_resume_template.dart';

class ModernCleanTemplate extends BaseResumeTemplate {
  @override
  void build(
    pw.Document pdf,
    Resume resume, {
    pw.ImageProvider? photoImage,
    required pw.Font regularFont,
    required pw.Font mediumFont,
    required pw.Font semiBoldFont,
    required pw.Font boldFont,
  }) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 34, vertical: 34),
        build: (context) => [
          _header(resume, boldFont, regularFont, photoImage),
          pw.SizedBox(height: 14),
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
          pw.SizedBox(height: 12),
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
          pw.SizedBox(height: 12),
          _section(
            title: 'Education',
            content: resume.educations.isEmpty
                ? [bodyText('No education added.', regularFont)]
                : resume.educations
                    .map((item) => educationItem(item, regularFont, mediumFont))
                    .toList(),
            titleFont: semiBoldFont,
          ),
          pw.SizedBox(height: 12),
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

  pw.Widget _header(
    Resume resume,
    pw.Font boldFont,
    pw.Font regularFont,
    pw.ImageProvider? photoImage,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColor.fromInt(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (photoImage != null) ...[
            profilePhoto(photoImage, size: 70),
            pw.SizedBox(width: 16),
          ],
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  personName(resume),
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 24,
                    color: PdfColors.grey900,
                  ),
                ),
                if (personHeadline(resume).isNotEmpty) ...[
                  pw.SizedBox(height: 3),
                  pw.Text(
                    personHeadline(resume),
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 11.5,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
                if (contactParts(resume).isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  contactLine(
                    resume,
                    regularFont,
                    color: PdfColors.grey600,
                  ),
                ],
              ],
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
    return pw.Inseparable(
      child: pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(10),
          border: pw.Border.all(color: const PdfColor.fromInt(0xFFE5E7EB)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title.toUpperCase(),
              style: pw.TextStyle(
                font: titleFont,
                fontSize: 11,
                color: const PdfColor.fromInt(0xFF6B7280),
                letterSpacing: 1.1,
              ),
            ),
            pw.SizedBox(height: 8),
            ...content,
          ],
        ),
      ),
    );
  }
}
