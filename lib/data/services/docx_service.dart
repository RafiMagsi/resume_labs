import 'dart:typed_data';

import 'package:docs_gee/docs_gee.dart';

import '../../domain/entities/education.dart';
import '../../domain/entities/resume.dart';
import '../../domain/entities/resume_template.dart';
import '../../domain/entities/skill.dart';
import '../../domain/entities/work_experience.dart';

class DocxService {
  const DocxService();

  Uint8List generateResumeDocx({
    required Resume resume,
    required ResumeTemplate template,
  }) {
    final document = Document(
      title: resume.title.isEmpty ? 'Resume' : resume.title,
      author: 'Resume Labs AI',
    );

    _addHeader(document, resume, template);
    _addSummary(document, resume.personalSummary);
    _addWorkExperience(document, resume.workExperiences);
    _addEducation(document, resume.educations);
    _addSkills(document, resume.skills);

    final bytes = DocxGenerator().generate(document);
    return Uint8List.fromList(bytes);
  }

  void _addHeader(Document document, Resume resume, ResumeTemplate template) {
    final title =
        resume.title.trim().isEmpty ? 'Untitled Resume' : resume.title;
    document.addParagraph(Paragraph.heading(title, level: 1));
    document.addParagraph(
      Paragraph.caption('Template: ${template.name.toUpperCase()}'),
    );
  }

  void _addSummary(Document document, String summary) {
    document.addParagraph(Paragraph.heading('Professional Summary', level: 2));
    document.addParagraph(
      Paragraph.text(
        summary.trim().isEmpty ? 'No personal summary provided.' : summary,
      ),
    );
  }

  void _addWorkExperience(Document document, List<WorkExperience> items) {
    document.addParagraph(Paragraph.heading('Work Experience', level: 2));
    if (items.isEmpty) {
      document.addParagraph(Paragraph.text('No work experience added.'));
      return;
    }

    for (final item in items) {
      document.addParagraph(
        Paragraph(
          runs: [
            TextRun(item.role.trim().isEmpty ? 'Role' : item.role, bold: true),
            TextRun(' — '),
            TextRun(
              item.company.trim().isEmpty ? 'Company' : item.company,
              bold: true,
            ),
            if (item.location.trim().isNotEmpty) TextRun(' • ${item.location}'),
          ],
        ),
      );

      document.addParagraph(
        Paragraph.caption(
          _formatDateRange(item.startDate, item.endDate, item.isCurrentRole),
        ),
      );

      final bullets = item.bulletPoints
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      for (final bullet in bullets) {
        document.addParagraph(Paragraph.bulletItem(bullet));
      }
    }
  }

  void _addEducation(Document document, List<Education> items) {
    document.addParagraph(Paragraph.heading('Education', level: 2));
    if (items.isEmpty) {
      document.addParagraph(Paragraph.text('No education added.'));
      return;
    }

    for (final item in items) {
      document.addParagraph(
        Paragraph(
          runs: [
            TextRun(item.degree.trim().isEmpty ? 'Degree' : item.degree,
                bold: true),
            if (item.field.trim().isNotEmpty) TextRun(' • ${item.field}'),
          ],
        ),
      );

      document.addParagraph(
        Paragraph.text(
          '${item.school.trim().isEmpty ? 'School' : item.school} • ${_formatMonthYear(item.graduationDate)}'
          '${item.gpa != null ? ' • GPA: ${item.gpa}' : ''}',
        ),
      );
    }
  }

  void _addSkills(Document document, List<Skill> skills) {
    document.addParagraph(Paragraph.heading('Skills', level: 2));
    if (skills.isEmpty) {
      document.addParagraph(Paragraph.text('No skills added.'));
      return;
    }

    final lines = skills
        .map((s) =>
            s.category.trim().isEmpty ? s.name : '${s.name} (${s.category})')
        .toList();

    // Keep it readable in Word: one skill per bullet.
    for (final line in lines) {
      document.addParagraph(Paragraph.bulletItem(line));
    }
  }

  String _formatMonthYear(DateTime date) {
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

  String _formatDateRange(DateTime start, DateTime? end, bool isCurrentRole) {
    final startText = _formatMonthYear(start);
    final endText =
        isCurrentRole || end == null ? 'Present' : _formatMonthYear(end);
    return '$startText - $endText';
  }
}
