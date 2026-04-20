import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/entities/resume.dart';
import 'base_resume_template.dart';

class MinimalTemplate extends BaseResumeTemplate {
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
          _sectionTitle('Summary', semiBoldFont),
          pw.SizedBox(height: 8),
          bodyText(
            resume.personalSummary.isEmpty
                ? 'No personal summary provided.'
                : resume.personalSummary,
            regularFont,
          ),
          pw.SizedBox(height: 18),
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
                bulletStyle: 'dash',
                accentColor: null,
              ),
            ),
          pw.SizedBox(height: 18),
          _sectionTitle('Education', semiBoldFont),
          pw.SizedBox(height: 8),
          if (resume.educations.isEmpty)
            bodyText('No education added.', regularFont)
          else
            ...resume.educations.map(
              (item) => educationItem(item, regularFont, mediumFont),
            ),
          pw.SizedBox(height: 18),
          _sectionTitle('Skills', semiBoldFont),
          pw.SizedBox(height: 8),
          if (resume.skills.isEmpty)
            bodyText('No skills added.', regularFont)
          else
            skillsWrap(
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

  pw.Widget _sectionTitle(String title, pw.Font font) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        font: font,
        fontSize: 14,
        color: PdfColors.grey800,
      ),
    );
  }
}
