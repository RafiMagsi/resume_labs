import 'package:flutter/material.dart';

import '../../../domain/entities/education.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/work_experience.dart';

class ResumePreview extends StatelessWidget {
  final String title;
  final String personalSummary;
  final List<WorkExperience> workExperiences;
  final List<Education> educations;
  final List<Skill> skills;

  const ResumePreview({
    super.key,
    required this.title,
    required this.personalSummary,
    required this.workExperiences,
    required this.educations,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.trim().isEmpty ? 'Untitled Resume' : title.trim(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 18),
            _PreviewSection(
              title: 'Professional Summary',
              child: Text(
                personalSummary.trim().isEmpty
                    ? 'Your personal summary will appear here.'
                    : personalSummary.trim(),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Color(0xFF334155),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _PreviewSection(
              title: 'Work Experience',
              child: workExperiences.isEmpty
                  ? const _PreviewEmptyState(
                      message: 'No work experience added yet.',
                    )
                  : Column(
                      children: workExperiences
                          .map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _PreviewWorkExperienceItem(item: item),
                              ))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 18),
            _PreviewSection(
              title: 'Education',
              child: educations.isEmpty
                  ? const _PreviewEmptyState(
                      message: 'No education added yet.',
                    )
                  : Column(
                      children: educations
                          .map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _PreviewEducationItem(item: item),
                              ))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 18),
            _PreviewSection(
              title: 'Skills',
              child: skills.isEmpty
                  ? const _PreviewEmptyState(
                      message: 'No skills added yet.',
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills
                          .map(
                            (skill) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(999),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Text(
                                '${skill.name} • ${skill.category}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _PreviewSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6D5EF8),
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _PreviewEmptyState extends StatelessWidget {
  final String message;

  const _PreviewEmptyState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF94A3B8),
      ),
    );
  }
}

class _PreviewWorkExperienceItem extends StatelessWidget {
  final WorkExperience item;

  const _PreviewWorkExperienceItem({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final dateText =
        _formatDateRange(item.startDate, item.endDate, item.isCurrentRole);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.role,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${item.company} • ${item.location}',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateText,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        if (item.bulletPoints.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...item.bulletPoints.map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: Color(0xFF6D5EF8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bullet,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PreviewEducationItem extends StatelessWidget {
  final Education item;

  const _PreviewEducationItem({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.degree,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${item.school} • ${item.field}',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Graduation: ${_formatMonthYear(item.graduationDate)}${item.gpa != null ? ' • GPA: ${item.gpa}' : ''}',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
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
