import 'dart:typed_data';

import 'package:docs_gee/docs_gee.dart';

import '../../domain/entities/education.dart';
import '../../domain/entities/resume.dart';
import '../../domain/entities/resume_template.dart';
import '../../domain/entities/skill.dart';
import '../../domain/entities/work_experience.dart';

/// Generates DOCX resume matching PDF output exactly.
/// Content structure and text are identical across all templates.
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

    switch (template) {
      case ResumeTemplate.classic:
        _buildClassic(document, resume);
      case ResumeTemplate.modern:
        _buildModern(document, resume);
      case ResumeTemplate.modernClean:
        _buildModernClean(document, resume);
      case ResumeTemplate.modernSidebar:
        _buildModernSidebar(document, resume);
      case ResumeTemplate.minimal:
        _buildMinimal(document, resume);
      case ResumeTemplate.executive:
        _buildExecutive(document, resume);
      // New templates use Firebase Cloud Functions, fallback to classic for local generation
      case ResumeTemplate.datascience:
      case ResumeTemplate.sales:
      case ResumeTemplate.marketing:
      case ResumeTemplate.finance:
      case ResumeTemplate.creative:
      case ResumeTemplate.academic:
      case ResumeTemplate.healthcare:
      case ResumeTemplate.startup:
        _buildClassic(document, resume);
    }

    final bytes = DocxGenerator().generate(document);
    return Uint8List.fromList(bytes);
  }

  /// Classic template: traditional centered layout
  void _buildClassic(Document document, Resume resume) {
    _addHeader(document, resume.title);
    _addSection(document, 'PROFESSIONAL SUMMARY', resume.personalSummary);
    _addWorkExperienceSection(document, resume.workExperiences);
    _addEducationSection(document, resume.educations);
    _addSkillsSection(document, resume.skills);
  }

  /// Modern template: gradient header style
  void _buildModern(Document document, Resume resume) {
    _addHeader(document, resume.title);
    _addSection(document, 'Summary', resume.personalSummary);
    _addWorkExperienceSection(document, resume.workExperiences);
    _addEducationSection(document, resume.educations);
    _addSkillsSection(document, resume.skills);
  }

  /// Modern Clean template: clean sidebar header
  void _buildModernClean(Document document, Resume resume) {
    _addHeader(document, resume.title);
    _addSection(document, 'Summary', resume.personalSummary);
    _addWorkExperienceSection(document, resume.workExperiences);
    _addEducationSection(document, resume.educations);
    _addSkillsSection(document, resume.skills);
  }

  /// Modern Sidebar template: two-column layout (content-heavy)
  void _buildModernSidebar(Document document, Resume resume) {
    _addHeader(document, resume.title);
    document.addParagraph(Paragraph.heading('Skills', level: 2));
    if (resume.skills.isNotEmpty) {
      for (final skill in resume.skills) {
        final skillText = skill.category.isEmpty
            ? skill.name
            : '${skill.name} • ${skill.category}';
        document.addParagraph(Paragraph.text(skillText));
      }
    } else {
      document.addParagraph(Paragraph.text('No skills added.'));
    }

    document.addParagraph(Paragraph.heading('Education', level: 2));
    if (resume.educations.isNotEmpty) {
      for (final edu in resume.educations) {
        document.addParagraph(
          Paragraph.text(
            edu.degree.isEmpty ? 'Degree' : edu.degree,
          ),
        );
        document.addParagraph(
          Paragraph.text(
            '${edu.school.isEmpty ? 'School' : edu.school} • ${_formatMonthYear(edu.graduationDate)}',
          ),
        );
      }
    } else {
      document.addParagraph(Paragraph.text('No education added.'));
    }

    _addSection(document, 'Summary', resume.personalSummary);
    _addWorkExperienceSection(document, resume.workExperiences);
  }

  /// Minimal template: clean sans-serif, maximalist whitespace
  void _buildMinimal(Document document, Resume resume) {
    _addHeader(document, resume.title);
    _addSection(document, 'Summary', resume.personalSummary);
    _addWorkExperienceDashStyle(document, resume.workExperiences);
    _addEducationSection(document, resume.educations);
    _addSkillsSection(document, resume.skills);
  }

  /// Executive template: professional two-column layout
  void _buildExecutive(Document document, Resume resume) {
    _addHeader(document, resume.title);
    _addSection(document, 'PROFESSIONAL SUMMARY', resume.personalSummary);
    _addWorkExperienceSection(document, resume.workExperiences);

    document.addParagraph(Paragraph.heading('EDUCATION & SKILLS', level: 2));

    document.addParagraph(Paragraph.heading('Education', level: 3));
    if (resume.educations.isEmpty) {
      document.addParagraph(Paragraph.text('No education added.'));
    } else {
      for (final item in resume.educations) {
        document.addParagraph(Paragraph.text(item.degree));
        document.addParagraph(
          Paragraph.text(
            '${item.school} - ${item.field}',
          ),
        );
        document.addParagraph(
          Paragraph.text(
            'Graduation: ${_formatMonthYear(item.graduationDate)}${item.gpa != null ? ' - GPA: ${item.gpa}' : ''}',
          ),
        );
      }
    }

    document.addParagraph(Paragraph.heading('Skills', level: 3));
    if (resume.skills.isEmpty) {
      document.addParagraph(Paragraph.text('No skills added.'));
    } else {
      for (final skill in resume.skills) {
        final skillText = skill.category.isEmpty
            ? skill.name
            : '${skill.name} • ${skill.category}';
        document.addParagraph(Paragraph.text(skillText));
      }
    }
  }

  /// Add title header (same for all templates)
  void _addHeader(Document document, String title) {
    final displayTitle =
        title.trim().isEmpty ? 'Untitled Resume' : title.trim();
    document.addParagraph(Paragraph.heading(displayTitle, level: 1));
  }

  /// Add section with heading and content
  void _addSection(Document document, String heading, String content) {
    document.addParagraph(Paragraph.heading(heading, level: 2));
    final text = content.trim().isEmpty ? 'No content provided.' : content;
    document.addParagraph(Paragraph.text(text));
  }

  /// Work experience with bullet points (standard style)
  void _addWorkExperienceSection(
      Document document, List<WorkExperience> items) {
    document.addParagraph(Paragraph.heading('Work Experience', level: 2));

    if (items.isEmpty) {
      document.addParagraph(Paragraph.text('No work experience added.'));
      return;
    }

    for (final item in items) {
      _addWorkExperienceItem(document, item, 'bullet');
    }
  }

  /// Work experience with dash style (for minimal template)
  void _addWorkExperienceDashStyle(
      Document document, List<WorkExperience> items) {
    document.addParagraph(Paragraph.heading('Experience', level: 2));

    if (items.isEmpty) {
      document.addParagraph(Paragraph.text('No work experience added.'));
      return;
    }

    for (final item in items) {
      _addWorkExperienceItem(document, item, 'dash');
    }
  }

  /// Add individual work experience entry
  void _addWorkExperienceItem(
    Document document,
    WorkExperience item,
    String bulletStyle,
  ) {
    document.addParagraph(
      Paragraph(
        runs: [
          TextRun(item.role.isEmpty ? 'Role' : item.role, bold: true),
        ],
      ),
    );

    document.addParagraph(
      Paragraph.text(
        '${item.company.isEmpty ? 'Company' : item.company} - ${item.location.isEmpty ? 'Location' : item.location}',
      ),
    );

    document.addParagraph(
      Paragraph.text(
        _formatDateRange(item.startDate, item.endDate, item.isCurrentRole),
      ),
    );

    final bullets = item.bulletPoints
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();

    for (final bullet in bullets) {
      if (bulletStyle == 'dash') {
        document.addParagraph(Paragraph.text('• $bullet'));
      } else {
        document.addParagraph(Paragraph.bulletItem(bullet));
      }
    }
  }

  /// Education section
  void _addEducationSection(Document document, List<Education> items) {
    document.addParagraph(Paragraph.heading('Education', level: 2));

    if (items.isEmpty) {
      document.addParagraph(Paragraph.text('No education added.'));
      return;
    }

    for (final item in items) {
      document.addParagraph(
        Paragraph(
          runs: [
            TextRun(item.degree.isEmpty ? 'Degree' : item.degree, bold: true),
          ],
        ),
      );

      document.addParagraph(
        Paragraph.text(
          '${item.school.isEmpty ? 'School' : item.school} - ${item.field.isEmpty ? 'Field' : item.field}',
        ),
      );

      document.addParagraph(
        Paragraph.text(
          'Graduation: ${_formatMonthYear(item.graduationDate)}${item.gpa != null ? ' - GPA: ${item.gpa}' : ''}',
        ),
      );
    }
  }

  /// Skills section
  void _addSkillsSection(Document document, List<Skill> skills) {
    document.addParagraph(Paragraph.heading('Skills', level: 2));

    if (skills.isEmpty) {
      document.addParagraph(Paragraph.text('No skills added.'));
      return;
    }

    for (final skill in skills) {
      final skillText = skill.category.isEmpty
          ? skill.name
          : '${skill.name} - ${skill.category}';
      document.addParagraph(Paragraph.bulletItem(skillText));
    }
  }

  /// Format date as "Mon Year"
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

  /// Format date range
  String _formatDateRange(DateTime start, DateTime? end, bool isCurrentRole) {
    final startText = _formatMonthYear(start);
    final endText =
        isCurrentRole || end == null ? 'Present' : _formatMonthYear(end);
    return '$startText - $endText';
  }
}
