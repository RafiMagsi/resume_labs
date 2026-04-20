import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/entities/resume.dart';
import 'base_resume_template.dart';

class ExecutiveTemplate extends BaseResumeTemplate {
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
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 34),
        build: (context) => [
          pw.Text(
            resume.title.isEmpty ? 'Untitled Resume' : resume.title,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 24,
              color: PdfColors.grey900,
              letterSpacing: -0.2,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Container(height: 1.2, color: PdfColors.grey300),
          pw.SizedBox(height: 14),
          _sectionTitle('Professional Summary', semiBoldFont),
          pw.SizedBox(height: 8),
          bodyText(
            resume.personalSummary.isEmpty
                ? 'No personal summary provided.'
                : resume.personalSummary,
            regularFont,
          ),
          pw.SizedBox(height: 16),
          _sectionTitle('Experience', semiBoldFont),
          pw.SizedBox(height: 8),
          if (resume.workExperiences.isEmpty)
            bodyText('No work experience added.', regularFont)
          else
            ...resume.workExperiences.map(
              (item) => workExperienceItem(
                item,
                regularFont,
                mediumFont,
                semiBoldFont,
                bulletStyle: 'dot',
                accentColor: null,
              ),
            ),
          pw.SizedBox(height: 16),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Education', semiBoldFont),
                    pw.SizedBox(height: 8),
                    if (resume.educations.isEmpty)
                      bodyText('No education added.', regularFont)
                    else
                      ...resume.educations.map(
                        (item) => educationItem(item, regularFont, mediumFont),
                      ),
                  ],
                ),
              ),
              pw.SizedBox(width: 18),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Skills', semiBoldFont),
                    pw.SizedBox(height: 8),
                    if (resume.skills.isEmpty)
                      bodyText('No skills added.', regularFont)
                    else
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: resume.skills
                            .map(
                              (s) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 4),
                                child: pw.Text(
                                  s.category.isEmpty
                                      ? s.name
                                      : '${s.name} • ${s.category}',
                                  style: pw.TextStyle(
                                    font: regularFont,
                                    fontSize: 10.5,
                                    color: PdfColors.grey800,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _sectionTitle(String title, pw.Font font) {
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
}
