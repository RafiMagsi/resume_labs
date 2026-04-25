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
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 38),
        build: (context) => [
          _header(
            resume,
            boldFont: boldFont,
            mediumFont: mediumFont,
            regularFont: regularFont,
            photoImage: photoImage,
          ),
          pw.SizedBox(height: 20),
          _section(
            title: 'Professional Summary',
            titleFont: semiBoldFont,
            child: bodyText(
              resume.personalSummary.isEmpty
                  ? 'No personal summary provided.'
                  : resume.personalSummary,
              regularFont,
            ),
          ),
          pw.SizedBox(height: 18),
          _section(
            title: 'Work Experience',
            titleFont: semiBoldFont,
            child: resume.workExperiences.isEmpty
                ? bodyText('No work experience added.', regularFont)
                : pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      ...resume.workExperiences.asMap().entries.map(
                        (entry) {
                          final isLast =
                              entry.key == resume.workExperiences.length - 1;
                          return pw.Padding(
                            padding: pw.EdgeInsets.only(
                              bottom: isLast ? 0 : 14,
                            ),
                            child: workExperienceItem(
                              entry.value,
                              regularFont,
                              mediumFont,
                              semiBoldFont,
                              bulletStyle: 'dot',
                              accentColor: null,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
          ),
          pw.SizedBox(height: 18),
          _section(
            title: 'Education',
            titleFont: semiBoldFont,
            child: resume.educations.isEmpty
                ? bodyText('No education added.', regularFont)
                : pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      ...resume.educations.asMap().entries.map(
                        (entry) {
                          final isLast =
                              entry.key == resume.educations.length - 1;
                          return pw.Padding(
                            padding: pw.EdgeInsets.only(
                              bottom: isLast ? 0 : 12,
                            ),
                            child: educationItem(
                              entry.value,
                              regularFont,
                              mediumFont,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
          ),
          pw.SizedBox(height: 18),
          _section(
            title: 'Skills',
            titleFont: semiBoldFont,
            child: resume.skills.isEmpty
                ? bodyText('No skills added.', regularFont)
                : skillsWrap(
                    resume.skills,
                    font: regularFont,
                    textColor: PdfColors.grey800,
                    background: PdfColors.white,
                    borderColor: PdfColors.grey400,
                  ),
          ),
        ],
      ),
    );
  }

  pw.Widget _header(
    Resume resume, {
    required pw.Font boldFont,
    required pw.Font mediumFont,
    required pw.Font regularFont,
    required pw.ImageProvider? photoImage,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(bottom: 14),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColor.fromInt(0xFFCBD5E1),
            width: 1,
          ),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (photoImage != null) ...[
            profilePhoto(photoImage, size: 64),
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
                    fontSize: 26,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Professional Resume',
                  style: pw.TextStyle(
                    font: mediumFont,
                    fontSize: 10.5,
                    color: PdfColors.grey700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _section({
    required String title,
    required pw.Font titleFont,
    required pw.Widget child,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(
            font: titleFont,
            fontSize: 11,
            color: PdfColors.grey800,
            letterSpacing: 1.2,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Container(
          width: double.infinity,
          height: 1,
          color: const PdfColor.fromInt(0xFFE2E8F0),
        ),
        pw.SizedBox(height: 10),
        child,
      ],
    );
  }
}
