import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/entities/education.dart';
import '../../../domain/entities/resume.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/work_experience.dart';

abstract class BaseResumeTemplate {
  void build(
    pw.Document pdf,
    Resume resume, {
    pw.ImageProvider? photoImage,
    required pw.Font regularFont,
    required pw.Font mediumFont,
    required pw.Font semiBoldFont,
    required pw.Font boldFont,
  });

  pw.Widget bodyText(String text, pw.Font font) {
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

  pw.Widget bulletLine(String text, pw.Font font) {
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

  pw.Widget accentBulletLine(String text, pw.Font font, PdfColor color) {
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

  pw.Widget dashLine(String text, pw.Font font) {
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

  pw.Widget skillsWrap(
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

  pw.Widget profilePhoto(
    pw.ImageProvider? photoImage, {
    double size = 80,
  }) {
    if (photoImage == null) {
      return pw.SizedBox(width: 0, height: 0);
    }
    return pw.Container(
      width: size,
      height: size,
      decoration: pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        border: pw.Border.all(color: PdfColors.grey400, width: 1),
      ),
      child: pw.ClipOval(
        child: pw.Image(photoImage, fit: pw.BoxFit.cover),
      ),
    );
  }

  String formatMonthYear(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String formatDateRange(DateTime start, DateTime? end, bool isCurrentRole) {
    final startText = formatMonthYear(start);
    final endText =
        isCurrentRole || end == null ? 'Present' : formatMonthYear(end);
    return '$startText - $endText';
  }

  pw.Widget workExperienceItem(
    WorkExperience item,
    pw.Font regularFont,
    pw.Font mediumFont,
    pw.Font semiBoldFont, {
    required String bulletStyle, // 'dot', 'accent', 'dash'
    required PdfColor? accentColor,
  }) {
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
            style: pw.TextStyle(
                font: mediumFont, fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            formatDateRange(item.startDate, item.endDate, item.isCurrentRole),
            style: pw.TextStyle(
                font: regularFont, fontSize: 10, color: PdfColors.grey600),
          ),
          if (item.bulletPoints.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            ...item.bulletPoints.map(
              (bullet) {
                switch (bulletStyle) {
                  case 'accent':
                    return accentBulletLine(bullet.toString(), regularFont,
                        accentColor ?? PdfColors.black);
                  case 'dash':
                    return dashLine(bullet.toString(), regularFont);
                  case 'dot':
                  default:
                    return bulletLine(bullet.toString(), regularFont);
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget educationItem(
    Education item,
    pw.Font regularFont,
    pw.Font mediumFont,
  ) {
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
            style: pw.TextStyle(
                font: regularFont, fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Graduation: ${formatMonthYear(item.graduationDate)}${item.gpa != null ? ' - GPA: ${item.gpa}' : ''}',
            style: pw.TextStyle(
                font: regularFont, fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }
}
