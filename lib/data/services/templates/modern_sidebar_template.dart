import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/entities/resume.dart';
import 'base_resume_template.dart';

class ModernSidebarTemplate extends BaseResumeTemplate {
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
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 3,
                child: _sidebar(
                  resume,
                  regularFont,
                  mediumFont,
                  semiBoldFont,
                  boldFont,
                  photoImage,
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                flex: 7,
                child: _mainContent(
                  resume,
                  regularFont,
                  mediumFont,
                  semiBoldFont,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _sidebar(
    Resume resume,
    pw.Font regularFont,
    pw.Font mediumFont,
    pw.Font semiBoldFont,
    pw.Font boldFont,
    pw.ImageProvider? photoImage,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF8FAFC),
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE5E7EB)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (photoImage != null) ...[
            profilePhoto(photoImage, size: 80),
            pw.SizedBox(height: 12),
          ],
          pw.Text(
            resume.title.isEmpty ? 'Untitled Resume' : resume.title,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 18,
              color: PdfColors.grey900,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            height: 2,
            width: 36,
            color: const PdfColor.fromInt(0xFF6C5CE7),
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            'Skills',
            style: pw.TextStyle(
              font: semiBoldFont,
              fontSize: 12,
              color: const PdfColor.fromInt(0xFF6C5CE7),
            ),
          ),
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
          pw.SizedBox(height: 14),
          pw.Text(
            'Education',
            style: pw.TextStyle(
              font: semiBoldFont,
              fontSize: 12,
              color: const PdfColor.fromInt(0xFF6C5CE7),
            ),
          ),
          pw.SizedBox(height: 8),
          if (resume.educations.isEmpty)
            bodyText('No education added.', regularFont)
          else
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: resume.educations
                  .map(
                    (e) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            e.degree,
                            style: pw.TextStyle(
                              font: mediumFont,
                              fontSize: 11,
                              color: PdfColors.grey900,
                            ),
                          ),
                          pw.Text(
                            '${e.school} • ${formatMonthYear(e.graduationDate)}',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  pw.Widget _mainContent(
    Resume resume,
    pw.Font regularFont,
    pw.Font mediumFont,
    pw.Font semiBoldFont,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
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
        pw.SizedBox(height: 14),
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
      ],
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
