import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/entities/resume.dart';
import 'base_resume_template.dart';

class ClassicTemplate extends BaseResumeTemplate {
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
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        build: (context) => [
          _header(resume, boldFont, mediumFont, photoImage),
          pw.SizedBox(height: 18),
          _sectionTitle('Professional Summary', semiBoldFont),
          pw.SizedBox(height: 8),
          bodyText(
            resume.personalSummary.isEmpty
                ? 'No personal summary provided.'
                : resume.personalSummary,
            regularFont,
          ),
          pw.SizedBox(height: 18),
          _sectionTitle('Work Experience', semiBoldFont),
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
              textColor: PdfColors.blueGrey900,
              background: PdfColors.blueGrey50,
              borderColor: PdfColors.blueGrey200,
            ),
        ],
      ),
    );
  }

  pw.Widget _header(
    Resume resume,
    pw.Font boldFont,
    pw.Font mediumFont,
    pw.ImageProvider? photoImage,
  ) {
    return pw.Row(
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
          ),
        ),
      ],
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
