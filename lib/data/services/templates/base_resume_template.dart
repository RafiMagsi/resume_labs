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

  String personName(Resume resume) {
    final name = resume.contactDetails.fullName?.trim() ?? '';
    if (name.isNotEmpty) return name;
    final title = resume.title.trim();
    return title.isEmpty ? 'Untitled Resume' : title;
  }

  String personHeadline(Resume resume) {
    final name = resume.contactDetails.fullName?.trim() ?? '';
    return name.isEmpty ? '' : resume.title.trim();
  }

  List<String> contactParts(Resume resume) {
    final contact = resume.contactDetails;
    return [
      contact.email,
      contact.phone,
      contact.location,
      contact.website,
      contact.linkedin,
      contact.github,
    ]
        .map((value) => value?.trim() ?? '')
        .where((value) => value.isNotEmpty)
        .toList();
  }

  pw.Widget contactLine(
    Resume resume,
    pw.Font font, {
    required PdfColor color,
    double fontSize = 9.5,
    pw.TextAlign textAlign = pw.TextAlign.left,
  }) {
    final parts = contactParts(resume);
    if (parts.isEmpty) return pw.SizedBox();
    return pw.Text(
      parts.join('  •  '),
      textAlign: textAlign,
      style: pw.TextStyle(
        font: font,
        fontSize: fontSize,
        color: color,
        lineSpacing: 2,
      ),
    );
  }

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
    final rows = <pw.Widget>[];
    for (var index = 0; index < skills.length; index += 2) {
      final first = skills[index];
      final second = index + 1 < skills.length ? skills[index + 1] : null;
      rows.add(
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: _skillChip(
                first,
                font: font,
                textColor: textColor,
                background: background,
                borderColor: borderColor,
              ),
            ),
            pw.SizedBox(width: 6),
            pw.Expanded(
              child: second == null
                  ? pw.SizedBox()
                  : _skillChip(
                      second,
                      font: font,
                      textColor: textColor,
                      background: background,
                      borderColor: borderColor,
                    ),
            ),
          ],
        ),
      );
      if (index + 2 < skills.length) {
        rows.add(pw.SizedBox(height: 6));
      }
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: rows,
    );
  }

  pw.Widget _skillChip(
    Skill skill, {
    required pw.Font font,
    required PdfColor textColor,
    required PdfColor background,
    required PdfColor borderColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: pw.BoxDecoration(
        color: background,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: borderColor, width: 0.5),
      ),
      child: pw.Text(
        skill.category.isEmpty
            ? skill.name
            : '${skill.name} · ${skill.category}',
        style: pw.TextStyle(font: font, fontSize: 9.5, color: textColor),
      ),
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
